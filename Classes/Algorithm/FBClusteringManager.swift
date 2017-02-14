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
    
    let renderer: FBRenderer
        
    public init(algorithm: FBClusteringAlgorithm, renderer: FBRenderer)
    {
        self.algorithm = algorithm
        self.renderer = renderer
    }
    
	public func add(annotations: [FBAnnotation], to mapView: MKMapView)
    {
        self.algorithm.add(annotations: annotations)
        
        self.updateAnnotations(in: mapView, force: true)
    }

	public func removeAll(from mapView: MKMapView)
    {
        self.algorithm.clear()
        
        self.updateAnnotations(in: mapView, force: true)
    }

	public func replace(annotations:[FBAnnotation], in mapView: MKMapView)
    {
        self.algorithm.clear()
        self.algorithm.add(annotations: annotations)
        
        self.updateAnnotations(in: mapView, force: true)
    }
    
    public func updateAnnotations(in mapView: MKMapView)
    {
        self.updateAnnotations(in: mapView, force: false)
    }
    
    private func updateAnnotations(in mapView: MKMapView, force: Bool)
    {
        guard (self.renderer.shouldRedraw(mapView: mapView) || force) else
        {
            return
        }
        
        let mapRect = mapView.visibleMapRect
        let mapSize = mapView.bounds.size
        let zoomLevel = mapView.zoomLevel()
        
        var cellSize = zoomLevel.cellSize()
        
        if let delegate = self.delegate
        {
            cellSize = delegate.cellSize(for: self, zoomLevel: zoomLevel)
            cellSize *= delegate.cellSizeFactor(for: self)
        }
        
        let scale = Double(mapSize.width) / mapRect.size.width
        let scaleFactor = scale/Double(cellSize)
        let step = ceil(1.0/scaleFactor)
        
        var annotations = [FBAnnotation]()
        var clusters = [FBAnnotationCluster]()
        
        let result = self.algorithm.clusters(for: mapRect, step: step, zoomLevel: zoomLevel)
        
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
