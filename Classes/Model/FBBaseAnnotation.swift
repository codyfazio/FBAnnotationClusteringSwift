//
//  FBBaseAnnotation.swift
//  FBAnnotationClusteringSwift
//
//  Created by Nikita Ivaniushchenko on 2/13/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

typealias FBAnimation = (MKAnnotationView?) -> Void

open class FBBaseAnnotation: MKPointAnnotation
{
    internal var actualCoordinate: CLLocationCoordinate2D
    internal var animation: FBAnimation?
    
    public required init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?)
    {
        self.actualCoordinate = coordinate
        
        super.init()
        
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    public func animate(annotationView: MKAnnotationView?)
    {
        self.animation?(annotationView)
    }
}
