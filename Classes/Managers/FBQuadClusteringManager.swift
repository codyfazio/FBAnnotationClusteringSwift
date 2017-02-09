//
//  FBQuadClusteringManager.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import MapKit

public class FBQuadClusteringManager: FBClusteringManager
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
    
    private func gridAnnotation(from visibleAnnotations: [FBAnnotation], for gridMapRect:MKMapRect, allAnnotations: [FBAnnotation]) -> FBAnnotation?
    {
        // first, see if one of the annotations we were already showing is in this mapRect
        for annotation in allAnnotations
        {
            if let annotationForGridSet = visibleAnnotations.first(where: { annotation === $0 } )
            {
                return annotationForGridSet
            }
        }
        
        // otherwise, get the cluster with most of points
        // then choose the one closest to the center to show
        let centerMapPoint = MKMapPointMake(MKMapRectGetMidX(gridMapRect), MKMapRectGetMidY(gridMapRect))
        let sortedAnnotations = allAnnotations.sorted
        {
            (annotation1: FBAnnotation, annotation2: FBAnnotation) -> Bool in
            
            let mapPoint1 = MKMapPointForCoordinate(annotation1.actualCoordinate)
            let mapPoint2 = MKMapPointForCoordinate(annotation2.actualCoordinate)
            
            let distance1 = MKMetersBetweenMapPoints(mapPoint1, centerMapPoint)
            let distance2 = MKMetersBetweenMapPoints(mapPoint2, centerMapPoint)
            
            return (distance1 < distance2)
        }
        
        return sortedAnnotations.first
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

        let scale = (Double(mapViewSize.width) / rect.size.width).roundTo(places: 1)
        
        let scaleFactor = scale/Double(cellSize)
        let step = ceil(1.0/scaleFactor)
        
        let visibleAnnotationsInBucket = self.annotations(of: FBAnnotation.self, in: mapView, for: rect)
        
        guard zoomLevel < self.maxClusteringZoomLevel else
        {
            let allMapBox = FBBoundingBox(mapRect: rect)
            
            let allAnnotationsInBucket = tree?.annotations(inBox: allMapBox) ?? []
            
            for annotation in allAnnotationsInBucket
            {
                let annotationsCount = annotation.annotations.count
                annotation.annotations = []
                
                if visibleAnnotationsInBucket.contains(annotation)
                {
                    if (annotationsCount > 0)
                    {
                        // Annotation was visible clustered, remove and add it again
                        mapView.removeAnnotation(annotation)
                        mapView.addAnnotation(annotation)
                    }
                    
                    // Annotation is not clustered and already visible, do nothing
                    continue
                }
                
                mapView.addAnnotation(annotation)
            }
            
            self.findAndResetAnnotationsOther(than: allAnnotationsInBucket)
            return
        }
        
        let minX = Int(MKMapRectGetMinX(rect).floorTo(alignment: step))
        let maxX = Int(MKMapRectGetMaxX(rect).ceilTo(alignment: step))
        let minY = Int(MKMapRectGetMinY(rect).floorTo(alignment: step))
        let maxY = Int(MKMapRectGetMaxY(rect).ceilTo(alignment: step))
        
        var visibleAnnotations = [FBAnnotation]()
        
        // for each square in our grid, pick one annotation to show
        for x in stride(from: minX, through: maxX, by: Int(step))
        {
            for y in stride(from: minY, through: maxY, by: Int(step))
            {
                let mapPoint = MKMapPoint(x: Double(x), y: Double(y))
                let mapRect = MKMapRect(origin: mapPoint, size: MKMapSize(width: step, height: step))
                let mapBox = FBBoundingBox(mapRect: mapRect)
                
                var allAnnotationsInBucket = tree?.annotations(inBox: mapBox) ?? []
                
                visibleAnnotations.append(contentsOf: allAnnotationsInBucket)
                
                if (allAnnotationsInBucket.count > 0)
                {
                    if let annotationForGrid = self.gridAnnotation(from: visibleAnnotationsInBucket, for: mapRect, allAnnotations: allAnnotationsInBucket),
                        let annotationForGridIndex = allAnnotationsInBucket.index(of: annotationForGrid)
                    {
                        allAnnotationsInBucket.remove(at: annotationForGridIndex)
                        mapView.removeAnnotation(annotationForGrid)
                        
                        // give the annotationForGrid a reference to all the annotations it will represent
                        annotationForGrid.annotations = allAnnotationsInBucket
                        
                        mapView.addAnnotation(annotationForGrid)
                        
                        for annotation in allAnnotationsInBucket
                        {
                            // give all the other annotations a reference to the one which is representing them
                            annotation.annotations = []
                            annotation.parentCluster = annotationForGrid
                            
                            // remove annotations which we've decided to cluster
                            if let annotationView = mapView.view(for: annotation)
                            {
                                self.animator.hide(annotationView: annotationView, in: mapView)
                            }
                        }
                    }
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
}
