//
//  FBRenderer.swift
//  FBAnnotationClusteringSwift
//
//  Created by Nikita Ivaniushchenko on 2/13/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

protocol FBRendererDelegate: class
{
    func renderer(_ renderer: FBRenderer, willRender annotation: FBAnnotation)
    func renderer(_ renderer: FBRenderer, willRender cluster: FBAnnotationCluster)
    
    func renderer(_ renderer: FBRenderer, didRender annotation: FBAnnotation)
    func renderer(_ renderer: FBRenderer, didRender cluster: FBAnnotationCluster)
}

class FBRenderer
{
    var animationDuration: TimeInterval = 0.5
    
    private var previousZoom = ZoomLevel(0)
    
    weak var delegate: FBRendererDelegate?
    
    private var renderedAnnotations: [FBAnnotation] = []
    private var renderedClusters: [FBAnnotationCluster] = []
    
    private var annotations: [FBAnnotation] = []
    private var clusters: [FBAnnotationCluster] = []
    
    // Lookup map from cluster item to an old cluster.
    private var itemToOldClusterMap: [CLLocationCoordinate2D: FBAnnotationCluster] = [:]
    
    // Lookup map from cluster item to a new cluster.
    private var itemToNewClusterMap: [CLLocationCoordinate2D: FBAnnotationCluster] = [:]
    
    func render(annotations: [FBAnnotation], clusters: [FBAnnotationCluster], in mapView: MKMapView)
    {
        let zoomLevel = mapView.zoomLevel()
        let zoomingIn = (zoomLevel > self.previousZoom)
        
        self.renderedAnnotations.removeAll()
        self.renderedClusters.removeAll()
        
        self.prepareAnimation(for: clusters, zoomingIn: zoomingIn)
        
        let oldClusters = self.clusters
        self.clusters = clusters
        
        let oldAnnotations = self.annotations
        self.annotations = annotations
        
        self.addOrUpdate(clusters: clusters, in: mapView, animated: zoomingIn)
        self.addOrUpdate(annotations: annotations, in: mapView, animated: zoomingIn)
        
        if (zoomingIn)
        {
            self.clear(annotations: oldAnnotations, clusters: oldClusters, in: mapView)
        }
        else
        {
            self.clearAnimated(annotations: oldAnnotations, clusters: oldClusters, in: mapView)
        }
        
        self.previousZoom = zoomLevel
    }

    private func prepareAnimation(for clusters: [FBAnnotationCluster], zoomingIn: Bool)
    {
        self.itemToOldClusterMap.removeAll()
        self.itemToNewClusterMap.removeAll()
        
        if (zoomingIn)
        {
            for cluster in self.clusters
            {
                for clusterItem in cluster.annotations
                {
                    self.itemToOldClusterMap[clusterItem.actualCoordinate] = cluster
                }
            }
        }
        else
        {
            for cluster in clusters
            {
                for clusterItem in cluster.annotations
                {
                    self.itemToNewClusterMap[clusterItem.actualCoordinate] = cluster
                }
            }
        }
    }
    
    // Goes through each cluster and adds a marker for it if it is:
    // - inside the visible region of the camera.
    // - not yet already added.
    private func addOrUpdate(clusters: [FBAnnotationCluster], in mapView: MKMapView, animated: Bool)
    {
        let visibleMapRegion = mapView.region
        
        for cluster in clusters
        {
            if self.renderedClusters.contains(cluster)
            {
                continue
            }
            
            var shouldShowCluster = visibleMapRegion.contains(cluster.actualCoordinate)
            
            if (!shouldShowCluster && animated)
            {
                for annotation in cluster.annotations
                {
                    if let oldCluster = self.itemToOldClusterMap[annotation.actualCoordinate], visibleMapRegion.contains(oldCluster.actualCoordinate)
                    {
                        shouldShowCluster = true
                        break
                    }
                }
                
            }
            
            if (shouldShowCluster)
            {
                self.render(cluster: cluster, in: mapView, animated: animated)
                self.renderedClusters.append(cluster)
            }
        }
    }
    
    // Goes through each annotation and adds a marker for it if it is:
    // - inside the visible region of the camera.
    // - not yet already added.
    private func addOrUpdate(annotations: [FBAnnotation], in mapView: MKMapView, animated: Bool)
    {
        let visibleMapRegion = mapView.region
        
        for annotation in annotations
        {
            if self.renderedAnnotations.contains(annotation)
            {
                continue
            }
            
            var shouldShowAnnotation = visibleMapRegion.contains(annotation.actualCoordinate)
            
            if (!shouldShowAnnotation && animated)
            {
                if let oldCluster = self.itemToOldClusterMap[annotation.actualCoordinate], visibleMapRegion.contains(oldCluster.actualCoordinate)
                {
                    shouldShowAnnotation = true
                    break
                }
                
            }
            
            if (shouldShowAnnotation)
            {
                self.render(annotation: annotation, in: mapView, animated: animated)
                self.renderedAnnotations.append(annotation)
            }
        }
    }
    
    private func render(cluster: FBAnnotationCluster, in mapView: MKMapView, animated: Bool)
    {
        var animated = animated
        var fromPosition = kCLLocationCoordinate2DInvalid
        
        if (animated)
        {
            if let fromCluster = self.overlappingCluster(for: cluster, itemMap: self.itemToOldClusterMap)
            {
                fromPosition = fromCluster.actualCoordinate
            }
            else
            {
                animated = false
            }
        }
        
        cluster.coordinate = animated ? fromPosition: cluster.actualCoordinate
        
        self.delegate?.renderer(self, willRender: cluster)
        
        if (animated)
        {
            cluster.animation = FBAnimation(duration: self.animationDuration, animation:
            {
                cluster.coordinate = cluster.actualCoordinate
            }, completion: nil)
        }
        else
        {
            cluster.animation = nil
        }
        
        mapView.addAnnotation(cluster)
        
        self.delegate?.renderer(self, didRender: cluster)
        
        self.renderedClusters.append(cluster)
    }
        
    private func render(annotation: FBAnnotation, in mapView: MKMapView, animated: Bool)
    {
        var animated = animated
        var fromPosition = kCLLocationCoordinate2DInvalid
        
        if (animated)
        {
            if let fromCluster = self.itemToOldClusterMap[annotation.actualCoordinate]
            {
                fromPosition = fromCluster.actualCoordinate
            }
            else
            {
                animated = false
            }
        }
        
        annotation.coordinate = animated ? fromPosition: annotation.actualCoordinate
        
        self.delegate?.renderer(self, willRender: annotation)
        
        if (animated)
        {
            annotation.animation = FBAnimation(duration: self.animationDuration, animation:
            {
                annotation.coordinate = annotation.actualCoordinate
            }, completion: nil)
        }
        else
        {
            annotation.animation = nil
        }
        
        mapView.addAnnotation(annotation)
        
        self.delegate?.renderer(self, didRender: annotation)
        
        self.renderedAnnotations.append(annotation)
    }
    
    // Remove existing markers: animate to nearest new cluster.
    private func clear(annotations: [FBAnnotation], clusters: [FBAnnotationCluster], in mapView: MKMapView)
    {
        let notRenderedAnnotations = annotations.filter { !self.renderedAnnotations.contains($0) }
        mapView.removeAnnotations(notRenderedAnnotations)
        
        let notRenderedClusters = clusters.filter { !self.renderedClusters.contains($0) }
        mapView.removeAnnotations(notRenderedClusters)
    }
    
    private func clearAnimated(annotations: [FBAnnotation], clusters: [FBAnnotationCluster], in mapView: MKMapView)
    {
        // Remove existing markers: animate to nearest new cluster.
        
        let visibleMapRegion = mapView.region
        
        for annotation in annotations
        {
            // If the marker has just been added, do not perform animation.
            if self.renderedAnnotations.contains(annotation)
            {
                continue
            }
            
            // If the marker is outside the visible view port, do not perform animation.
            if !visibleMapRegion.contains(annotation.actualCoordinate)
            {
                mapView.removeAnnotation(annotation)
                continue
            }
            
            // Find a candidate cluster to animate to.
            let toCluster = self.itemToNewClusterMap[annotation.actualCoordinate]
            self.animateRemove(annotation: annotation, to: toCluster?.actualCoordinate, from: mapView)
        }
        
        for cluster in clusters
        {
            // Find a candidate cluster to animate to.
            let toCluster = self.overlappingCluster(for: cluster, itemMap: self.itemToNewClusterMap)
            
            self.animateRemove(annotation: cluster, to: toCluster?.actualCoordinate, from: mapView)
        }
    }
    
    private func animateRemove(annotation: FBBaseAnnotation, to coordinate: CLLocationCoordinate2D?, from mapView: MKMapView)
    {
        if let coordinate = coordinate
        {
            // All is good, perform the animation.
            UIView.animate(withDuration: self.animationDuration, animations:
            {
                annotation.coordinate = coordinate
            }, completion:
            {
                (finished: Bool) in
                mapView.removeAnnotation(annotation)
            })
        }
        else
        {
            // If there is not near by cluster to animate to, do not perform animation.
            mapView.removeAnnotation(annotation)
        }
    }
    
    private func overlappingCluster(for cluster: FBAnnotationCluster, itemMap: [CLLocationCoordinate2D: FBAnnotationCluster]) -> FBAnnotationCluster?
    {
        for annotation in cluster.annotations
        {
            if let candidate = itemMap[annotation.actualCoordinate]
            {
                return candidate
            }
        }
        
        return nil
    }

}
