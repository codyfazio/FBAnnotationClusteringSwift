//
//  FBZoomLevel.swift
//  Pods
//
//  Created by Antoine Lamy on 25/9/2016.
//
//

import Foundation
import MapKit

public typealias ZoomLevel = Double

public extension ZoomLevel {
	func cellSize() -> CGFloat {
		switch (UInt(self)) {
		case 13...15:
			return 64
		case 16...18:
			return 32
		case 18 ..< UInt.max:
			return 16
		default:
			return 88 // Less than 13
		}
	}
}
