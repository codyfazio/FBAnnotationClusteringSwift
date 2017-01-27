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
    var animatationDuration: TimeInterval { get }
    
    func animateShow(annotationView: MKAnnotationView, in mapView: MKMapView)
    func hide(annotationView: MKAnnotationView, in mapView: MKMapView)
}
