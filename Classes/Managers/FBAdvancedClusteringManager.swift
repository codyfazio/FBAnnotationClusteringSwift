//
//  FBAdvancedClusteringManager.swift
//  FBAnnotationClusteringSwift
//
//  Created by Nikita Ivaniushchenko on 2/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

public class FBAdvancedClusteringManager: FBClusteringManager
{
    public weak var delegate: FBClusteringManagerDelegate?
    public let animator: FBAnimator
    public let maxClusteringZoomLevel: UInt
    
    private var backingTree: FBQuadTree?
    private var tree: FBQuadTree?
    {
        set
        {
            backingTree = newValue
        }
        
        get
        {
            if backingTree == nil
            {
                backingTree = FBQuadTree()
            }
            
            return backingTree
        }
    }
    
    public init(animator: FBAnimator, maxClusteringZoomLevel: UInt = 15)
    {
        self.animator = animator
        self.maxClusteringZoomLevel = maxClusteringZoomLevel
    }
    
    public func add(annotations: [FBAnnotation], to mapView: MKMapView)
    {
        for annotation in annotations
        {
            tree?.insert(annotation: annotation)
        }
        
        self.updateAnnotations(in: mapView)
    }
    
    public func removeAll(from mapView: MKMapView)
    {
        let allAnnotations = self.allAnnotations()
        
        for annotation in allAnnotations
        {
            if let annotationView = mapView.view(for: annotation)
            {
                self.animator.hide(annotationView: annotationView, in: mapView)
            }
            else
            {
                mapView.removeAnnotation(annotation)
            }
        }
        
        tree = nil
    }
    
    public func replace(annotations:[FBAnnotation], in mapView: MKMapView)
    {
        removeAll(from: mapView)
        add(annotations: annotations, to: mapView)
    }
    
    public func allAnnotations() -> [FBAnnotation]
    {
        let annotations = tree?.annotations() ?? []
        return annotations
    }
    
    private func annotations<T: MKAnnotation>(of: T.Type, in mapView: MKMapView, for mapRect: MKMapRect) -> [T]
    {
        let annotationSet = mapView.annotations(in: mapRect)
        let allAnnotations = Array(annotationSet) as [AnyObject]
        let filteredAnnotations = allAnnotations.flatMap
        {
            (annotation: AnyObject) -> T? in
            return annotation as? T
        }
        
        return filteredAnnotations
    }
    
    public func updateAnnotations(in mapView: MKMapView)
    {
        let rect = mapView.visibleMapRect
        let mapViewSize = mapView.bounds.size
        let zoomLevel = mapView.zoomLevel()
        
        guard zoomLevel < UInt.max else
        {
            return
        }
        
        var cellSize = zoomLevel.cellSize()
        
        if let delegate = delegate
        {
            cellSize = delegate.cellSize(forCoordinator: self, zoomLevel: zoomLevel)
            cellSize *= delegate.cellSizeFactor(forCoordinator: self)
        }
        
        let scale = Double(mapViewSize.width) / rect.size.width
        let scaleFactor = scale/Double(cellSize)
        let step = ceil(1.0/scaleFactor)
        
        let visibleMapBox = FBBoundingBox(mapRect: rect)
        
        let nonClusteredAnnotationsInBucket = tree?.annotations(inBox: visibleMapBox) ?? []

        let visibleAnnotationsInBucket = self.annotations(of: FBAnnotation.self, in: mapView, for: rect)
        
        guard zoomLevel < self.maxClusteringZoomLevel else
        {
            for nonClusteredAnnotation in nonClusteredAnnotationsInBucket
            {
                let annotationsCount = nonClusteredAnnotation.annotations.count
                nonClusteredAnnotation.annotations = []
                
                if visibleAnnotationsInBucket.contains(nonClusteredAnnotation)
                {
                    if (annotationsCount > 0)
                    {
                        // Annotation was visible clustered, remove and add it again
                        mapView.removeAnnotation(nonClusteredAnnotation)
                        mapView.addAnnotation(nonClusteredAnnotation)
                    }
                    
                    // Annotation is not clustered and already visible, do nothing
                    continue
                }
                
                mapView.addAnnotation(nonClusteredAnnotation)
            }
            
            self.findAndResetAnnotationsOther(than: nonClusteredAnnotationsInBucket)
            return
        }
        
        var processedItems = Set<FBAnnotation>()
        var itemToClusterDistanceMap = [CLLocationCoordinate2D: CLLocationDistance]()
        var visibleAnnotations = [FBAnnotation]()
        
        for nonClusteredAnnotation in nonClusteredAnnotationsInBucket
        {
            nonClusteredAnnotation.annotations = []
            
            guard !processedItems.contains(nonClusteredAnnotation) else
            {
                // Already processed
                continue
            }
            
            // Query for items within a fixed point distance from the current item to make up a cluster around it.
            
            let centerPoint = MKMapPointForCoordinate(nonClusteredAnnotation.actualCoordinate)
            let mapRect = MKMapRect(center: centerPoint, size: MKMapSize(width: step, height: step))
            let mapBox = FBBoundingBox(mapRect: mapRect)
            
            let nearbyItems = tree?.annotations(inBox: mapBox) ?? []
            
            for nearbyItem in nearbyItems
            {
                guard nonClusteredAnnotation != nearbyItem else
                {
                    continue
                }
                
                processedItems.insert(nearbyItem)
                
                let distanceSquared = self.distanceSquared(between: nonClusteredAnnotation.actualCoordinate, and: nearbyItem.actualCoordinate)
                
                if let existingDistance = itemToClusterDistanceMap[nearbyItem.actualCoordinate]
                {
                    if (existingDistance < distanceSquared)
                    {
                        // Already belongs to a closer cluster.
                        continue
                    }
                    
                    nearbyItem.parentCluster?.annotations.remove(element: nearbyItem)
                }
                
                itemToClusterDistanceMap[nearbyItem.actualCoordinate] = distanceSquared
                
                nonClusteredAnnotation.annotations.append(nearbyItem)
                nearbyItem.parentCluster = nonClusteredAnnotation
            }
            
            visibleAnnotations.append(nonClusteredAnnotation)
        }
        
        for visibleAnnotation in visibleAnnotations
        {
            mapView.removeAnnotation(visibleAnnotation)
            mapView.addAnnotation(visibleAnnotation)
            
            for childAnnotation in visibleAnnotation.annotations
            {
                // remove annotations which we've decided to cluster
                if let childAnnotationView = mapView.view(for: childAnnotation)
                {
                    self.animator.hide(annotationView: childAnnotationView, in: mapView)
                }
            }
        }
        
        self.findAndResetAnnotationsOther(than: visibleAnnotations)
    }
    
    private func findAndResetAnnotationsOther(than annotations: [FBAnnotation])
    {
        let allAnnotations = tree?.annotations() ?? []
        let allAnnotationsSet = Set(allAnnotations)
        
        let invisibleAnnotations = allAnnotationsSet.subtracting(annotations)
        invisibleAnnotations.forEach { $0.reset() }
    }
    
    private func distanceSquared(between point1: CLLocationCoordinate2D, and point2: CLLocationCoordinate2D) -> CLLocationDistance
    {
        let latitudeDelta = (point1.latitude - point2.latitude)
        let longitudeDelta = (point1.longitude - point2.longitude)
        return latitudeDelta * latitudeDelta + longitudeDelta * longitudeDelta
    }
}
