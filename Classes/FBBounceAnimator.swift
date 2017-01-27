//
//  FBFadeAnimator.swift
//  FBAnnotationClusteringSwift
//
//  Created by Nikita Ivaniushchenko on 1/27/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

open class FBBounceAnimator: FBAnimator
{
    public let animatationDuration: TimeInterval
    
    public init(animatationDuration: TimeInterval = 0.2)
    {
        self.animatationDuration = animatationDuration
    }
    
    open func animateShow(annotationView: MKAnnotationView, in mapView: MKMapView)
    {
        guard let annotation = annotationView.annotation as? FBAnnotation else
        {
            return
        }
        
        annotation.coordinate = annotation.actualCoordinate
        
        // since it's displayed on the map, it is no longer contained by another annotation,
        // (We couldn't reset this in -updateVisibleAnnotations because we needed the reference to it here
        // to get the containerCoordinate)
        annotation.parentCluster = nil
        
        annotationView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        
        UIView.animate(withDuration: self.animatationDuration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 2, options: [], animations:
        {
            annotationView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
    
    open func hide(annotationView: MKAnnotationView, in mapView: MKMapView)
    {
        guard let annotation = annotationView.annotation as? FBAnnotation else
        {
            return
        }
        
        UIView.animate(withDuration: self.animatationDuration, animations:
        {
            annotationView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        }, completion:
        {
            (finished: Bool) in
            mapView.removeAnnotation(annotation)
        })
    }
}
