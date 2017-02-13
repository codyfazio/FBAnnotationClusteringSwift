//
//  FBDistanceBasedClusteringAlgorithm.swift
//  FBAnnotationClusteringSwift
//
//  Created by Nikita Ivaniushchenko on 2/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

public class FBDistanceBasedClusteringAlgorithm: FBBaseQuadTreeClusteringAlgorithm
{
    override public func clusters(for visibleMapRect: MKMapRect, size: CGSize, zoomLevel: ZoomLevel) -> FBClusteringAlgorithmResult
    {
        let allAnnotationsInBucket = self.tree?.annotations(inBox: FBBoundingBox(mapRect: visibleMapRect)) ?? []
        
        guard zoomLevel < self.maxClusteringZoomLevel else
        {
            return .annotations(allAnnotationsInBucket)
        }
        
        var cellSize = zoomLevel.cellSize()
        
        if let delegate = self.delegate
        {
            cellSize = delegate.cellSize(for: self, zoomLevel: zoomLevel)
            cellSize *= delegate.cellSizeFactor(for: self)
        }
        
        let scale = Double(size.width) / visibleMapRect.size.width
        let scaleFactor = scale/Double(cellSize)
        let step = ceil(1.0/scaleFactor)
        
        var processedItems = Set<FBAnnotation>()
        var itemToClusterDistanceMap = [CLLocationCoordinate2D: CLLocationDistance]()
        
        var clusters = [FBAnnotationCluster]()
        
        for annotation in allAnnotationsInBucket
        {
            guard !processedItems.contains(annotation) else
            {
                // Already processed
                continue
            }
            
            let cluster = FBAnnotationCluster()
            
            // Query for items within a fixed point distance from the current item to make up a cluster around it.
            
            let centerPoint = MKMapPointForCoordinate(annotation.actualCoordinate)
            let mapRect = MKMapRect(center: centerPoint, size: MKMapSize(width: step, height: step))
            let mapBox = FBBoundingBox(mapRect: mapRect)
            
            let nearbyItems = self.tree?.annotations(inBox: mapBox) ?? []
            
            for nearbyItem in nearbyItems
            {
                processedItems.insert(nearbyItem)
                
                let distanceSquared = self.distanceSquared(between: annotation.actualCoordinate, and: nearbyItem.actualCoordinate)
                
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
                cluster.annotations.append(nearbyItem)
                nearbyItem.parentCluster = cluster
            }
            
            clusters.append(cluster)
        }
        
        return .clusters(clusters)
    }
    
    private func distanceSquared(between point1: CLLocationCoordinate2D, and point2: CLLocationCoordinate2D) -> CLLocationDistance
    {
        let latitudeDelta = (point1.latitude - point2.latitude)
        let longitudeDelta = (point1.longitude - point2.longitude)
        return latitudeDelta * latitudeDelta + longitudeDelta * longitudeDelta
    }
}
