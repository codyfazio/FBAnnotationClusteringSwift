//
//  FBAllMapDistanceBasedClusteringAlgorithm.swift
//  FBAnnotationClusteringSwift
//
//  Created by Nikita Ivaniushchenko on 2/14/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

open class FBAllMapDistanceBasedClusteringAlgorithm: FBDistanceBasedClusteringAlgorithm
{
    override public func clusters(for visibleMapRect: MKMapRect, step: Double, zoomLevel: ZoomLevel) -> FBClusteringAlgorithmResult
    {
        return super.clusters(for: MKMapRectWorld, step: step, zoomLevel: zoomLevel)
    }
}
