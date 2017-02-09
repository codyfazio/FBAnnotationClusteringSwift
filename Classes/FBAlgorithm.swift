//
//  FBAlgorithm.swift
//  FBAnnotationClusteringSwift
//
//  Created by Nikita Ivaniushchenko on 2/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

protocol FBAlgorithmDelegate
{
    func algorithm(_ algorithm: FBAlgorithm, willAdd: FBAnnotation)
    func algorithm(_ algorithm: FBAlgorithm, willRemove: FBAnnotation)
}

protocol FBAlgorithm
{
    func add(annotations: [FBAnnotation])
    func remove(annotations: [FBAnnotation])
    func clear()
}
