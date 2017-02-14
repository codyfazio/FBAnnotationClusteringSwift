//
//  FBAllMapRenderer.swift
//  FBAnnotationClusteringSwift
//
//  Created by Nikita Ivaniushchenko on 2/14/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

open class FBAllMapRenderer: FBRenderer
{
    override func shouldRedraw(mapView: MKMapView) -> Bool
    {
        let zoomLevel = mapView.zoomLevel()
        
        return abs(zoomLevel - self.previousZoom) > 0.001
    }
}
