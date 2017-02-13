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
    func cellSizeFactor(for manager: FBClusteringManager) -> CGFloat
    func cellSize(for manager: FBClusteringManager, zoomLevel: ZoomLevel) -> CGFloat
}

open class FBClusteringManager
{
    public weak var delegate: FBClusteringManagerDelegate?
    public let algorithm: FBClusteringAlgorithm
    public let animator: FBAnimator
    
    let renderer = FBRenderer()
        
    public init(algorithm: FBClusteringAlgorithm, animator: FBAnimator)
    {
        self.algorithm = algorithm
        self.animator = animator
        
        self.algorithm.delegate = self
    }
    
	public func add(annotations: [FBAnnotation], to mapView: MKMapView)
    {
        self.algorithm.add(annotations: annotations)
        
        self.updateAnnotations(in: mapView)
    }

	public func removeAll(from mapView: MKMapView)
    {
        self.algorithm.clear()
        
        self.updateAnnotations(in: mapView)
    }

	public func replace(annotations:[FBAnnotation], in mapView: MKMapView)
    {
        self.algorithm.clear()
        self.algorithm.add(annotations: annotations)
        
        self.updateAnnotations(in: mapView)
    }
    
    public func updateAnnotations(in mapView: MKMapView)
    {
        let mapRect = mapView.visibleMapRect
        let mapSize = mapView.bounds.size
        let zoomLevel = mapView.zoomLevel()
        
        var annotations = [FBAnnotation]()
        var clusters = [FBAnnotationCluster]()
        
        let result = self.algorithm.clusters(for: mapRect, size: mapSize, zoomLevel: zoomLevel)
        
        switch (result)
        {
            case .annotations(let resultAnnotations):
                annotations = resultAnnotations
            
            case .clusters(let resultClusters):
                for resultCluster in resultClusters
                {
                    if (resultCluster.annotations.count > 1)
                    {
                        clusters.append(resultCluster)
                    }
                    else
                    {
                        annotations.append(contentsOf: resultCluster.annotations)
                    }
                }
                
                clusters.forEach { $0.recalculateData() }
        }
        
        self.renderer.render(annotations: annotations, clusters: clusters, in: mapView)
    }
}

extension FBClusteringManager: FBClusteringAlgorithmDelegate
{
    public func cellSizeFactor(for algorithm: FBClusteringAlgorithm) -> CGFloat
    {
        return self.delegate?.cellSizeFactor(for: self) ?? 1
    }
    
    public func cellSize(for algorithm: FBClusteringAlgorithm, zoomLevel: ZoomLevel) -> CGFloat
    {
        return self.delegate?.cellSize(for: self, zoomLevel: zoomLevel) ?? zoomLevel.cellSize()
    }
}
