//
//  FBAnnotation.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

open class FBAnnotation: MKPointAnnotation
{
    private (set) open var actualCoordinate: CLLocationCoordinate2D
    private (set) open var clusterCoordinate: CLLocationCoordinate2D
    
    open var parentCluster: FBAnnotation?
    
    open var annotations = [FBAnnotation]()
    {
        didSet
        {
            var totalLatitude: Double = 0
            var totalLongitude: Double = 0
            
            let allAnnotations = self.annotations + [self]
            
            allAnnotations.forEach
            {
                (annotation: FBAnnotation) in
                
                totalLatitude += annotation.actualCoordinate.latitude
                totalLongitude += annotation.actualCoordinate.longitude
            }
            
            self.clusterCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(totalLatitude)/CLLocationDegrees(allAnnotations.count),
                                                            longitude: CLLocationDegrees(totalLongitude)/CLLocationDegrees(allAnnotations.count))
        }
    }
    
    public required init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?)
    {
        self.actualCoordinate = coordinate
        self.clusterCoordinate = coordinate
        
        super.init()
        
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    open var region: MKCoordinateRegion
    {
        var minLatitude = self.actualCoordinate.latitude
        var maxLatitude = self.actualCoordinate.latitude
        var minLongutude = self.actualCoordinate.longitude
        var maxLongutude = self.actualCoordinate.longitude
        
        for annotation in self.annotations
        {
            minLatitude = min(minLatitude, annotation.actualCoordinate.latitude)
            maxLatitude = max(maxLatitude, annotation.actualCoordinate.latitude)
            
            minLongutude = min(minLongutude, annotation.actualCoordinate.longitude)
            maxLongutude = max(maxLongutude, annotation.actualCoordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(latitude: (maxLatitude + minLatitude)/2, longitude: (maxLongutude + minLongutude)/2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLatitude - minLatitude), longitudeDelta: (maxLongutude - minLongutude))
        return MKCoordinateRegion(center: center, span: span)
    }
}
