//
//  FBAlgorithm.swift
//  FBAnnotationClusteringSwift
//
//  Created by Nikita Ivaniushchenko on 2/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import MapKit

public protocol FBClusteringAlgorithmDelegate: class
{
    func cellSizeFactor(for algorithm: FBClusteringAlgorithm) -> CGFloat
    func cellSize(for algorithm: FBClusteringAlgorithm, zoomLevel: ZoomLevel) -> CGFloat
}

public enum FBClusteringAlgorithmResult
{
    case annotations([FBAnnotation])
    case clusters([FBAnnotationCluster])
}

public protocol FBClusteringAlgorithm
{
    weak var delegate: FBClusteringAlgorithmDelegate? { get set }
    var maxClusteringZoomLevel: ZoomLevel  { get set }
    
    func add(annotations: [FBAnnotation])
    func clear()
    
    func allAnnotations() -> [FBAnnotation]
    func allAnnotations(for visibleMapRect: MKMapRect) -> [FBAnnotation]

    func clusters(for visibleMapRect: MKMapRect, size: CGSize, zoomLevel: ZoomLevel) -> FBClusteringAlgorithmResult
}
