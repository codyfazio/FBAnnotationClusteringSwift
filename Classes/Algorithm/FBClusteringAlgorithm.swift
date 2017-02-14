//
//  FBAlgorithm.swift
//  FBAnnotationClusteringSwift
//
//  Created by Nikita Ivaniushchenko on 2/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import MapKit

public enum FBClusteringAlgorithmResult
{
    case annotations([FBAnnotation])
    case clusters([FBAnnotationCluster])
}

public protocol FBClusteringAlgorithm
{
    var maxClusteringZoomLevel: ZoomLevel  { get set }
    
    func add(annotations: [FBAnnotation])
    func clear()
    
    func allAnnotations() -> [FBAnnotation]
    func allAnnotations(for visibleMapRect: MKMapRect) -> [FBAnnotation]

    func clusters(for visibleMapRect: MKMapRect, step: Double, zoomLevel: ZoomLevel) -> FBClusteringAlgorithmResult
}
