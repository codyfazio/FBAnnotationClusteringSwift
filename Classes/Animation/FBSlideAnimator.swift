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
    public let animationDuration: TimeInterval
    
    public init(animationDuration: TimeInterval = 0.2)
    {
        self.animationDuration = animationDuration
    }
    
    public func show(annotation: FBAnnotation, from coordinate: CLLocationCoordinate2D?, in mapView: MKMapView, animated: Bool)
    {
        if let coordinate = coordinate, animated
        {
            annotation.coordinate = coordinate
            
            annotation.animation =
            {
                (annotationView: MKAnnotationView?) in
                
                annotationView?.alpha = 0
                
                UIView.animate(withDuration: self.animationDuration, animations:
                {
                    annotation.coordinate = annotation.actualCoordinate
                    annotationView?.alpha = 1
                }, completion: nil)
            }
        }
        else
        {
            annotation.coordinate = annotation.actualCoordinate
            
            annotation.animation =
            {
                (annotationView: MKAnnotationView?) in
                
                annotationView?.alpha = 1
            }
        }
        
        mapView.addAnnotation(annotation)
    }
    
    public func show(cluster: FBAnnotationCluster, from coordinate: CLLocationCoordinate2D?, in mapView: MKMapView, animated: Bool)
    {
        if let coordinate = coordinate, animated
        {
            cluster.coordinate = coordinate
            
            cluster.animation =
            {
                (annotationView: MKAnnotationView?) in
                
                annotationView?.alpha = 0
                
                UIView.animate(withDuration: self.animationDuration, animations:
                {
                    cluster.coordinate = cluster.actualCoordinate
                    annotationView?.alpha = 1
                    annotationView?.layer.zPosition = CGFloat(cluster.annotations.count)
                }, completion: nil)
            }
        }
        else
        {
            cluster.coordinate = cluster.actualCoordinate
            
            cluster.animation =
            {
                (annotationView: MKAnnotationView?) in
                
                annotationView?.alpha = 1
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
                if let coordinate = coordinate
                {
                    annotation.coordinate = coordinate
                }
                
                annotationView?.alpha = 0
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
                if let coordinate = coordinate
                {
                    cluster.coordinate = coordinate
                }
                
                annotationView?.alpha = 0
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
