//
//  FBSlideAnimator.swift
//  FBAnnotationClusteringSwift
//
//  Created by Nikita Ivaniushchenko on 1/27/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

open class FBSlideAnimator: FBAnimator
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
        
        guard let clusterAnnotation = annotation.parentCluster else
        {
            return
        }
        
        // since it's displayed on the map, it is no longer contained by another annotation,
        // (We couldn't reset this in -updateVisibleAnnotations because we needed the reference to it here
        // to get the containerCoordinate)
        annotation.parentCluster = nil
        
        // animate the annotation from it's old container's coordinate, to its actual coordinate
        annotation.coordinate = clusterAnnotation.coordinate
        
        UIView.animate(withDuration: 0.2)
        {
            annotation.coordinate = annotation.actualCoordinate
        }
    }
    
    open func hide(annotationView: MKAnnotationView, in mapView: MKMapView)
    {
        guard let annotation = annotationView.annotation as? FBAnnotation else
        {
            return
        }
        
        guard let parentClusterCoordinate = annotation.parentCluster?.coordinate else
        {
            mapView.removeAnnotation(annotation)
            return
        }
        
        let actualCoordinate = annotation.coordinate
            
        UIView.animate(withDuration: 0.2, animations:
        {
            annotation.coordinate = parentClusterCoordinate
        }, completion:
        {
            (finished: Bool) in
            annotation.coordinate = actualCoordinate
            mapView.removeAnnotation(annotation)
        })
    }
}
