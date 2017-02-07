//
//  FBUtils.swift
//  FBAnnotationClusteringSwift
//
//  Created by Nikita Ivaniushchenko on 2/7/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

extension Double {
    // Rounds the double to 'places' significant digits
    // Double(0.123456789).roundTo(places: 2) = 0.12
    // Double(1.23456789).roundTo(places: 2) = 1.2
    // Double(1234.56789).roundTo(places: 2) = 1200
    func roundTo(places:Int) -> Double {
        guard self != 0.0 else {
            return 0
        }
        let divisor = pow(10.0, Double(places) - ceil(log10(fabs(self))))
        return (self * divisor).rounded() / divisor
    }
}

