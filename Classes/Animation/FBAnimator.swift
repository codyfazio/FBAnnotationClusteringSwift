//
//  FBAnimator.swift
//  FBAnnotationClusteringSwift
//
//  Created by Nikita Ivaniushchenko on 1/27/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import MapKit

public protocol FBAnimator
{
    var animationDuration: TimeInterval { get }
    
    func show(annotation: FBAnnotation, from coordinate: CLLocationCoordinate2D?, in mapView: MKMapView, animated: Bool)
    func show(cluster: FBAnnotationCluster, from coordinate: CLLocationCoordinate2D?, in mapView: MKMapView, animated: Bool)
    
    func hide(annotation: FBAnnotation, to coordinate: CLLocationCoordinate2D?, in mapView: MKMapView, animated: Bool)
    func hide(cluster: FBAnnotationCluster, to coordinate: CLLocationCoordinate2D?, in mapView: MKMapView, animated: Bool)
}
