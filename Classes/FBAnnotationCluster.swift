//
//  FBAnnotationCluster.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import MapKit

open class FBAnnotationCluster: NSObject {
    
    private (set) open var coordinate: CLLocationCoordinate2D
    private (set) open var title: String?
    private (set) open var subtitle: String?
    private (set) open var annotations: [MKAnnotation]
    private (set) open var region: MKCoordinateRegion
    
    public required init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, annotations: [MKAnnotation]) {
        
        guard (annotations.count > 0) else {
            fatalError("number of annotations must be more than zero")
        }
        
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.annotations = annotations
        
        var minLatitude = CLLocationDegrees.infinity
        var maxLatitude = -CLLocationDegrees.infinity
        var minLongutude = CLLocationDegrees.infinity
        var maxLongutude = -CLLocationDegrees.infinity
        
        for annotation in annotations {
            
            minLatitude = min(minLatitude, annotation.coordinate.latitude)
            maxLatitude = max(maxLatitude, annotation.coordinate.latitude)
            
            minLongutude = min(minLongutude, annotation.coordinate.longitude)
            maxLongutude = max(maxLongutude, annotation.coordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(latitude: (maxLatitude + minLatitude)/2, longitude: (maxLongutude + minLongutude)/2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLatitude - minLatitude), longitudeDelta: (maxLongutude - minLongutude))
        self.region = MKCoordinateRegion(center: center, span: span)
        
        super.init()
    }
}

extension FBAnnotationCluster : MKAnnotation { }
