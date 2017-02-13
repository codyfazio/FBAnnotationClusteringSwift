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
//        annotationView.alpha = 1
//        
//        guard let annotation = annotationView.annotation as? FBAnnotation else
//        {
//            return
//        }
//        
//        guard let clusterAnnotation = annotation.parentCluster else
//        {
//            annotation.coordinate = (annotation.annotations.count > 0) ? annotation.clusterCoordinate : annotation.actualCoordinate
//            annotationView.layer.zPosition = CGFloat(annotation.annotations.count)
//            return
//        }
//        
//        // since it's displayed on the map, it is no longer contained by another annotation,
//        // (We couldn't reset this in -updateVisibleAnnotations because we needed the reference to it here
//        // to get the containerCoordinate)
//        annotation.parentCluster = nil
//        
//        // animate the annotation from it's old container's coordinate, to its actual coordinate
//        annotation.coordinate = clusterAnnotation.coordinate
//        
//        UIView.animate(withDuration: self.animatationDuration)
//        {
//            annotation.coordinate = (annotation.annotations.count > 0) ? annotation.clusterCoordinate : annotation.actualCoordinate
//            annotationView.layer.zPosition = CGFloat(annotation.annotations.count)
//        }
    }
    
    open func hide(annotationView: MKAnnotationView, in mapView: MKMapView)
    {
//        guard let annotation = annotationView.annotation as? FBAnnotation else
//        {
//            return
//        }
//        
//        guard let parentClusterCoordinate = annotation.parentCluster?.clusterCoordinate else
//        {
//            mapView.removeAnnotation(annotation)
//            return
//        }
//        
//        let actualCoordinate = annotation.coordinate
//            
//        UIView.animate(withDuration: self.animatationDuration, animations:
//        {
//            annotation.coordinate = parentClusterCoordinate
//            annotationView.alpha = 0
//        }, completion:
//        {
//            (finished: Bool) in
//            annotation.coordinate = actualCoordinate
//            mapView.removeAnnotation(annotation)
//        })
    }
}
