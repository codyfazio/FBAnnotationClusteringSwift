//
//  FBUtils.swift
//  FBAnnotationClusteringSwift
//
//  Created by Nikita Ivaniushchenko on 2/7/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

extension Double
{
    // Rounds the double to 'places' significant digits
    // Double(0.123456789).roundTo(places: 2) = 0.12
    // Double(1.23456789).roundTo(places: 2) = 1.2
    // Double(1234.56789).roundTo(places: 2) = 1200
    func roundTo(places:Int) -> Double
    {
        guard self != 0.0 else
        {
            return 0
        }
        
        let divisor = pow(10.0, Double(places) - ceil(log10(fabs(self))))
        return (self * divisor).rounded() / divisor
    }
    
    // Ceils number to be aligned to 'alignment'
    // Double(1025).ceilTo(alignment: 512) = 1536
    // Double(1023).ceilTo(alignment: 512) = 1024
    // Double(127).ceilTo(alignment: 512) = 512
    func ceilTo(alignment: Double) -> Double
    {
        let i = ceil(self/alignment)
        return i * alignment
    }
    
    // Floors number to be aligned to 'alignment'
    // Double(1025).ceilTo(alignment: 512) = 1024
    // Double(1023).ceilTo(alignment: 512) = 512
    // Double(511).ceilTo(alignment: 512) = 0
    func floorTo(alignment: Double) -> Double
    {
        let i = floor(self/alignment)
        return i * alignment
    }
}

extension CLLocationCoordinate2D: Hashable {
    
    public var hashValue: Int
    {
        get
        {
            // Add the hash value of lat and long, taking care of overlfolow. Here we are muliplying by an aribtrary number. Just in case.
            let latHash = latitude.hashValue&*257
            let longHash = longitude.hashValue
            return latHash &+ longHash
        }
    }
}

// Conform to the Equatable protocol.
public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool
{
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

extension RangeReplaceableCollection where Iterator.Element : Equatable
{
    mutating func remove(element: Iterator.Element)
    {
        if let index = self.index(of: element)
        {
            self.remove(at: index)
        }
    }
    
    mutating func remove<C : Collection>(contentsOf elementsToRemove: C) where C.Iterator.Element == Iterator.Element
    {
        for elementToRemove in elementsToRemove
        {
            self.remove(element: elementToRemove)
        }
    }
}
