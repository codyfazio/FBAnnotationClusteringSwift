//
//  FBClusteringManager.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import MapKit

public protocol FBClusteringManagerDelegate: NSObjectProtocol {
    func cellSizeFactor(forCoordinator coordinator: FBClusteringManager) -> CGFloat
    func cellSize(forCoordinator coordinator: FBClusteringManager, zoomLevel: ZoomLevel) -> CGFloat
}

public class FBClusteringManager {

    public weak var delegate: FBClusteringManagerDelegate? = nil
    
    public let animator: FBAnimator
    public let maxClusteringZoomLevel: UInt
	private var backingTree: FBQuadTree?
	private var tree: FBQuadTree? {
		set {
			backingTree = newValue
		}
		get {
			if backingTree == nil {
				backingTree = FBQuadTree()
			}
			return backingTree
		}
    }
    
    public init(animator: FBAnimator, maxClusteringZoomLevel: UInt = 15) {
        self.animator = animator
        self.maxClusteringZoomLevel = maxClusteringZoomLevel
    }
    	
	public func add(annotations:[FBAnnotation]) {
        for annotation in annotations {
			tree?.insert(annotation: annotation)
        }
    }

	public func removeAll() {
		tree = nil
	}

	public func replace(annotations:[FBAnnotation]){
		removeAll()
		add(annotations: annotations)
	}

	public func allAnnotations() -> [FBAnnotation] {
		var annotations = [FBAnnotation]()
		tree?.enumerateAnnotationsUsingBlock(){ obj in
			annotations.append(obj)
		}
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
        
        // otherwise, sort the annotations based on their distance from the center of the grid square,
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
        let mapSize = mapView.bounds.size
        let zoomLevel = mapView.zoomLevel()
        
        guard zoomLevel < UInt.max else { return }
        
        var cellSize = zoomLevel.cellSize()
        
        if let delegate = delegate {
            cellSize = delegate.cellSize(forCoordinator: self, zoomLevel: zoomLevel)
			cellSize *= delegate.cellSizeFactor(forCoordinator: self)
        }

        let scale = Double(mapSize.width) / rect.size.width
        
        let scaleFactor = scale/Double(cellSize)
        
        let minX = Int(floor(MKMapRectGetMinX(rect) * scaleFactor))
        let maxX = Int(floor(MKMapRectGetMaxX(rect) * scaleFactor))
        let minY = Int(floor(MKMapRectGetMinY(rect) * scaleFactor))
        let maxY = Int(floor(MKMapRectGetMaxY(rect) * scaleFactor))
        
        guard zoomLevel < self.maxClusteringZoomLevel else
        {
            let allMapBox = FBBoundingBox(mapRect: rect)
            
            let visibleAnnotationsInBucket = self.annotations(of: FBAnnotation.self, in: mapView, for: rect)
            var allAnnotationsInBucket = [FBAnnotation]()
            
            tree?.enumerateAnnotations(inBox: allMapBox) { obj in
                allAnnotationsInBucket.append(obj)
            }
            
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
            
            return
        }
        
        // for each square in our grid, pick one annotation to show
        for i in minX...maxX {
            for j in minY...maxY {

                let mapPoint = MKMapPoint(x: Double(i) / scaleFactor, y: Double(j) / scaleFactor)
                let mapSize = MKMapSize(width: 1.0 / scaleFactor, height: 1.0 / scaleFactor)
                let mapRect = MKMapRect(origin: mapPoint, size: mapSize)
                let mapBox = FBBoundingBox(mapRect: mapRect)
                
                let visibleAnnotationsInBucket = self.annotations(of: FBAnnotation.self, in: mapView, for: rect)
                var allAnnotationsInBucket = [FBAnnotation]()

				tree?.enumerateAnnotations(inBox: mapBox) { obj in
                    allAnnotationsInBucket.append(obj)
                }
                
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
    }
}
