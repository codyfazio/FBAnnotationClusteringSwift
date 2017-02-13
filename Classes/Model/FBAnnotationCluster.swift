//
//  FBAnnotationCluster.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import MapKit

open class FBAnnotationCluster: FBBaseAnnotation
{
    private (set) open var region = MKCoordinateRegion(center: kCLLocationCoordinate2DInvalid, span: MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0))
    
    internal (set) open var annotations = [FBAnnotation]()
    
    public required init(coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid, title: String? = nil, subtitle: String? = nil)
    {
        super.init(coordinate: coordinate, title: title, subtitle: subtitle)
    }
    
    func recalculateData()
    {
        self.recalculateActualCoordinate()
        self.recalculateRegion()
    }
    
    private func recalculateActualCoordinate()
    {
        var totalLatitude: Double = 0
        var totalLongitude: Double = 0
        
        self.annotations.forEach
        {
            (annotation: FBAnnotation) in
            
            totalLatitude += annotation.actualCoordinate.latitude
            totalLongitude += annotation.actualCoordinate.longitude
        }
        
        self.actualCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(totalLatitude)/CLLocationDegrees(self.annotations.count),
                                                       longitude: CLLocationDegrees(totalLongitude)/CLLocationDegrees(self.annotations.count))
        
        self.coordinate = actualCoordinate
    }
    
    private func recalculateRegion()
    {
        var minLatitude = CLLocationDegrees.infinity
        var maxLatitude = -CLLocationDegrees.infinity
        var minLongutude = CLLocationDegrees.infinity
        var maxLongutude = -CLLocationDegrees.infinity
        
        for annotation in self.annotations
        {
            minLatitude = min(minLatitude, annotation.actualCoordinate.latitude)
            maxLatitude = max(maxLatitude, annotation.actualCoordinate.latitude)
            
            minLongutude = min(minLongutude, annotation.actualCoordinate.longitude)
            maxLongutude = max(maxLongutude, annotation.actualCoordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(latitude: (maxLatitude + minLatitude)/2, longitude: (maxLongutude + minLongutude)/2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLatitude - minLatitude), longitudeDelta: (maxLongutude - minLongutude))
        
        self.region = MKCoordinateRegion(center: center, span: span)
    }
}
