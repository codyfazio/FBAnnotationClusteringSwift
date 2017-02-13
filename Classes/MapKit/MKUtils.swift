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

/* Standardises and angle to [-180 to 180] degrees */
func standardAngle(_ angle: CLLocationDegrees) -> CLLocationDegrees {
    let angle = angle.truncatingRemainder(dividingBy: 360)
    if (angle < -180)
    {
        return (360 + angle)
    }
    
    if (angle > 180)
    {
        return (angle - 360)
    }
    
    return angle
}

public extension MKCoordinateRegion
{
    /* confirms that a region contains a location */
    public func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let deltaLat = abs(standardAngle(self.center.latitude - coordinate.latitude))
        let deltalong = abs(standardAngle(self.center.longitude - coordinate.longitude))
        return self.span.latitudeDelta >= deltaLat && self.span.longitudeDelta >= deltalong
    }
}
