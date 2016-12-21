//
//  ViewController.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import UIKit
import MapKit
import FBAnnotationClusteringSwift

class FBViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    let numberOfLocations = 1000
    
    let clusteringManager = FBClusteringManager()
    
    lazy var configuration: FBAnnotationClusterViewConfiguration =
    {
        var smallTemplate = FBAnnotationClusterTemplate(range: Range(uncheckedBounds: (lower: 0, upper: 6)), sideLength: 48)
        smallTemplate.borderWidth = 2
        smallTemplate.fontSize = 13
        
        var mediumTemplate = FBAnnotationClusterTemplate(range: Range(uncheckedBounds: (lower: 6, upper: 15)), sideLength: 56)
        mediumTemplate.borderWidth = 3
        mediumTemplate.fontSize = 13
        
        var largeTemplate = FBAnnotationClusterTemplate(range: nil, sideLength: 64)
        largeTemplate.borderWidth = 4
        largeTemplate.fontSize = 13
        
        return FBAnnotationClusterViewConfiguration(templates: [smallTemplate, mediumTemplate], defaultTemplate: largeTemplate)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        clusteringManager.add(annotations: randomLocationsWithCount(numberOfLocations))
        clusteringManager.delegate = self;

        mapView.centerCoordinate = CLLocationCoordinate2DMake(0, 0);
    }

    // MARK: - Utility
    
    func randomLocationsWithCount(_ count:Int) -> [FBAnnotation] {
        var array:[FBAnnotation] = []
        for _ in 0...count - 1 {
            let a:FBAnnotation = FBAnnotation()
            a.coordinate = CLLocationCoordinate2D(latitude: drand48() * 40 - 20, longitude: drand48() * 80 - 40 )
            array.append(a)
        }
        return array
    }

}

extension FBViewController : FBClusteringManagerDelegate {
 
    func cellSizeFactor(forCoordinator coordinator:FBClusteringManager) -> CGFloat {
        return 1.5
    }
    
    func cellSize(forCoordinator coordinator: FBClusteringManager, zoomLevel: ZoomLevel) -> CGFloat {
        return 64
    }
}


extension FBViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

		DispatchQueue.global(qos: .userInitiated).async {
            let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect,
                                                                              size: self.mapView.bounds.size,
                                                                              zoomLevel:self.mapView.zoomLevel())

			DispatchQueue.main.async {
				self.clusteringManager.display(annotations: annotationArray, onMapView:self.mapView)
			}
		}

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var reuseId = ""
        
        if annotation is FBAnnotationCluster {
            
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
			if clusterView == nil {
				clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: self.configuration)
			} else {
				clusterView?.annotation = annotation
			}

            return clusterView
            
        } else {
        
            reuseId = "Pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
			if pinView == nil {
				pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
				pinView?.pinTintColor = UIColor.green
			} else {
				pinView?.annotation = annotation
			}
            
            return pinView
        }
        
    }
    
}
