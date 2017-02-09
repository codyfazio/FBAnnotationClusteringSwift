//
//  MKUtils.swift
//  FBAnnotationClusteringSwift
//
//  Created by Nikita Ivaniushchenko on 2/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import MapKit

public extension MKMapRect{
    
    public init(center: MKMapPoint, size: MKMapSize)
    {
        let origin = MKMapPoint(x: center.x - size.width/2, y: center.y - size.height/2)
        self.init(origin: origin, size: size)
    }
}
