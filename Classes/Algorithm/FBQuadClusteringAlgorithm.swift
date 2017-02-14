//
//  FBQuadClusteringManager.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import MapKit

public class FBQuadClusteringAlgorithm: FBBaseQuadTreeClusteringAlgorithm
{
    override public func clusters(for visibleMapRect: MKMapRect, step: Double, zoomLevel: ZoomLevel) -> FBClusteringAlgorithmResult
    {
        let allAnnotationsInBucket = self.tree?.annotations(inBox: FBBoundingBox(mapRect: visibleMapRect)) ?? []
        
        guard zoomLevel < self.maxClusteringZoomLevel else
        {
            return .annotations(allAnnotationsInBucket)
        }
        
        let minX = Int(MKMapRectGetMinX(visibleMapRect).floorTo(alignment: step))
        let maxX = Int(MKMapRectGetMaxX(visibleMapRect).ceilTo(alignment: step))
        let minY = Int(MKMapRectGetMinY(visibleMapRect).floorTo(alignment: step))
        let maxY = Int(MKMapRectGetMaxY(visibleMapRect).ceilTo(alignment: step))
        
        var clusters = [FBAnnotationCluster]()
        
        // for each square in our grid, pick one annotation to show
        for x in stride(from: minX, through: maxX, by: Int(step))
        {
            for y in stride(from: minY, through: maxY, by: Int(step))
            {
                let mapPoint = MKMapPoint(x: Double(x), y: Double(y))
                let mapRect = MKMapRect(origin: mapPoint, size: MKMapSize(width: step, height: step))
                let mapBox = FBBoundingBox(mapRect: mapRect)
                
                let allAnnotationsInBucket = self.tree?.annotations(inBox: mapBox) ?? []
                
                guard (allAnnotationsInBucket.count > 0) else
                {
                    continue
                }
                
                let cluster = FBAnnotationCluster()
                
                // give the annotationForGrid a reference to all the annotations it will represent
                cluster.annotations = allAnnotationsInBucket
                
                for annotation in allAnnotationsInBucket
                {
                    // give all the other annotations a reference to the one which is representing them
                    annotation.parentCluster = cluster
                }
             
                clusters.append(cluster)
            }
        }
        
        return .clusters(clusters)
    }
}
