//
//  FBClusteringManager.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import MapKit

public protocol FBClusteringManagerDelegate: NSObjectProtocol
{
    func cellSizeFactor(forCoordinator coordinator: FBClusteringManager) -> CGFloat
    func cellSize(forCoordinator coordinator: FBClusteringManager, zoomLevel: ZoomLevel) -> CGFloat
}

public protocol FBClusteringManager
{
    weak var delegate: FBClusteringManagerDelegate? { get set }
    var animator: FBAnimator { get }
    var maxClusteringZoomLevel: UInt  { get }
    
	func add(annotations: [FBAnnotation], to mapView: MKMapView)

	func removeAll(from mapView: MKMapView)

	func replace(annotations:[FBAnnotation], in mapView: MKMapView)

	func allAnnotations() -> [FBAnnotation]
    
    func updateAnnotations(in mapView: MKMapView)
}
