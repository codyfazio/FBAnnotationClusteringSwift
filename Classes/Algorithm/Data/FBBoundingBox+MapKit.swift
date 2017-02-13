//
//  FBBoundingBox+MapKit.swift
//  Pods
//
//  Created by Antoine Lamy on 23/9/2016.
//
//

import Foundation
import MapKit

extension FBBoundingBox {

    init(mapRect: MKMapRect) {
        self.init(coordinateRegion: MKCoordinateRegionForMapRect(mapRect))
	}
    
    init(coordinateRegion: MKCoordinateRegion) {
        let minLat = coordinateRegion.center.latitude - coordinateRegion.span.latitudeDelta/2
        let maxLat = coordinateRegion.center.latitude + coordinateRegion.span.latitudeDelta/2
        
        let minLon = coordinateRegion.center.longitude - coordinateRegion.span.longitudeDelta/2
        let maxLon = coordinateRegion.center.longitude + coordinateRegion.span.longitudeDelta/2
        
        self.init(x0: CGFloat(minLat), y0: CGFloat(minLon), xf: CGFloat(maxLat), yf: CGFloat(maxLon))
    }

	func contains(coordinate: CLLocationCoordinate2D) -> Bool {
		let containsX = (x0 <= CGFloat(coordinate.latitude)) && (CGFloat(coordinate.latitude) <= xf)
		let containsY = (y0 <= CGFloat(coordinate.longitude)) && (CGFloat(coordinate.longitude) <= yf)
		return (containsX && containsY)
	}

	func mapRect() -> MKMapRect {
		let topLeft  = MKMapPointForCoordinate(CLLocationCoordinate2DMake(CLLocationDegrees(x0), CLLocationDegrees(y0)))
		let botRight  = MKMapPointForCoordinate(CLLocationCoordinate2DMake(CLLocationDegrees(xf), CLLocationDegrees(yf)))
		return MKMapRectMake(topLeft.x, botRight.y, fabs(botRight.x - topLeft.x), fabs(botRight.y - topLeft.y))
	}
}
