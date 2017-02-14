//
//  FBBaseQuadTreeClusteringAlgorithm.swift
//  FBAnnotationClusteringSwift
//
//  Created by Nikita Ivaniushchenko on 2/13/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

open class FBBaseQuadTreeClusteringAlgorithm: FBClusteringAlgorithm
{
    public var maxClusteringZoomLevel: ZoomLevel = 16
    
    private var backingTree: FBQuadTree?
    var tree: FBQuadTree?
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
    
    public init()
    {
        
    }
    
    public func add(annotations: [FBAnnotation])
    {
        for annotation in annotations
        {
            self.tree?.insert(annotation: annotation)
        }
    }
    
    public func clear()
    {
        self.tree = nil
    }
    
    public func allAnnotations() -> [FBAnnotation]
    {
        return self.allAnnotations(for: MKMapRectWorld)
    }
    
    public func allAnnotations(for visibleMapRect: MKMapRect) -> [FBAnnotation]
    {
        let annotations = self.tree?.annotations(inBox: FBBoundingBox(mapRect: visibleMapRect)) ?? []
        return annotations
    }
    
    public func clusters(for visibleMapRect: MKMapRect, step: Double, zoomLevel: ZoomLevel) -> FBClusteringAlgorithmResult
    {
        return .annotations(self.allAnnotations(for: visibleMapRect))
    }
    
    private func distanceSquared(between point1: CLLocationCoordinate2D, and point2: CLLocationCoordinate2D) -> CLLocationDistance
    {
        let latitudeDelta = (point1.latitude - point2.latitude)
        let longitudeDelta = (point1.longitude - point2.longitude)
        return latitudeDelta * latitudeDelta + longitudeDelta * longitudeDelta
    }
}
