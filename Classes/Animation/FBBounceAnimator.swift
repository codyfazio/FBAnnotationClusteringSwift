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
    public let animationDuration: TimeInterval
    
    public init(animationDuration: TimeInterval = 0.2)
    {
        self.animationDuration = animationDuration
    }
    
    public func show(annotation: FBAnnotation, from _: CLLocationCoordinate2D?, in mapView: MKMapView, animated: Bool)
    {
        annotation.coordinate = annotation.actualCoordinate
        
        if (animated)
        {
            annotation.animation =
            {
                (annotationView: MKAnnotationView?) in
                
                annotationView?.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
                
                UIView.animate(withDuration: self.animationDuration, animations:
                {
                    annotationView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: nil)
            }
        }
        else
        {
            annotation.animation =
            {
                (annotationView: MKAnnotationView?) in
                
                annotationView?.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
        
        mapView.addAnnotation(annotation)
    }
    
    public func show(cluster: FBAnnotationCluster, from _: CLLocationCoordinate2D?, in mapView: MKMapView, animated: Bool)
    {
        cluster.coordinate = cluster.actualCoordinate
        
        if (animated)
        {
            cluster.animation =
            {
                (annotationView: MKAnnotationView?) in
                
                annotationView?.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
                
                UIView.animate(withDuration: self.animationDuration, animations:
                {
                    annotationView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                    annotationView?.layer.zPosition = CGFloat(cluster.annotations.count)
                }, completion: nil)
            }
        }
        else
        {
            cluster.animation =
            {
                (annotationView: MKAnnotationView?) in
                
                annotationView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                annotationView?.layer.zPosition = CGFloat(cluster.annotations.count)
            }
        }
        
        mapView.addAnnotation(cluster)
    }
    
    public func hide(annotation: FBAnnotation, to coordinate: CLLocationCoordinate2D?, in mapView: MKMapView, animated: Bool)
    {
        if (animated)
        {
            let annotationView = mapView.view(for: annotation)
            
            // All is good, perform the animation.
            UIView.animate(withDuration: self.animationDuration, animations:
            {
                annotationView?.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
            }, completion:
            {
                (finished: Bool) in
                mapView.removeAnnotation(annotation)
            })
        }
        else
        {
            mapView.removeAnnotation(annotation)
        }
    }
    
    public func hide(cluster: FBAnnotationCluster, to coordinate: CLLocationCoordinate2D?, in mapView: MKMapView, animated: Bool)
    {
        if (animated)
        {
            let annotationView = mapView.view(for: cluster)
            
            // All is good, perform the animation.
            UIView.animate(withDuration: self.animationDuration, animations:
            {
                annotationView?.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
            }, completion:
            {
                (finished: Bool) in
                mapView.removeAnnotation(cluster)
            })
        }
        else
        {
            mapView.removeAnnotation(cluster)
        }
    }
}
