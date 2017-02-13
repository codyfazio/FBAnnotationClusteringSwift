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

    let numberOfLocations = 5
    
    let clusteringManager = FBClusteringManager(algorithm: FBDistanceBasedClusteringAlgorithm(), animator: FBSlideAnimator())
    
    fileprivate lazy var configuration: FBAnnotationClusterViewConfiguration =
    {
        let color = UIColor.blue
        
        var smallTemplate = FBAnnotationClusterTemplate(range: Range(uncheckedBounds: (lower: 0, upper: 6)), displayMode: .SolidColor(sideLength: 48, color: color))
        smallTemplate.borderWidth = 2
        smallTemplate.font = UIFont.boldSystemFont(ofSize: 13)
        
        var mediumTemplate = FBAnnotationClusterTemplate(range: Range(uncheckedBounds: (lower: 6, upper: 15)), displayMode: .SolidColor(sideLength: 56, color: color))
        mediumTemplate.borderWidth = 3
        mediumTemplate.font = UIFont.boldSystemFont(ofSize: 13)
        
        var largeTemplate = FBAnnotationClusterTemplate(range: nil, displayMode: .SolidColor(sideLength: 64, color: color))
        largeTemplate.borderWidth = 4
        largeTemplate.font = UIFont.boldSystemFont(ofSize: 13)
        
        return FBAnnotationClusterViewConfiguration(templates: [smallTemplate, mediumTemplate], defaultTemplate: largeTemplate)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clusteringManager.delegate = self
        self.reloadData()

        mapView.centerCoordinate = CLLocationCoordinate2DMake(0, 0);
    }

    // MARK: - Utility
    
    func randomLocationsWithCount(_ count:Int) -> [FBAnnotation] {
        
        let center = CLLocationCoordinate2D(latitude: 51.925, longitude: 4.4737)
        let span = Double(0.2)
        var array:[FBAnnotation] = []
        for _ in 0...count - 1 {
            let randomCoordinate = CLLocationCoordinate2D(latitude: center.latitude + drand48() * span - span/2, longitude: center.longitude + drand48() * span - span/2 )
            let a = FBAnnotation(coordinate: randomCoordinate, title: nil, subtitle: nil)
            array.append(a)
        }
        return array
    }

}

extension FBViewController : FBClusteringManagerDelegate
{
    func cellSizeFactor(for manager: FBClusteringManager) -> CGFloat
    {
        return 2
    }
    
    func cellSize(for manager: FBClusteringManager, zoomLevel: ZoomLevel) -> CGFloat
    {
        return 64
    }
}


extension FBViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.clusteringManager.updateAnnotations(in: self.mapView)
//        
//		DispatchQueue.global(qos: .userInitiated).async {
//            let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect,
//                                                                              size: self.mapView.bounds.size,
//                                                                              zoomLevel:self.mapView.zoomLevel())
//
//			DispatchQueue.main.async {
//				self.clusteringManager.display(annotations: annotationArray, onMapView:self.mapView)
//			}
//		}

    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        guard let annotation = view.annotation as? FBAnnotationCluster else
        {
            return
        }
        
        var region = annotation.region
        
        // Make span a bit bigger so there are no points on the edges of the map
        let smallSpan = region.span
        region.span = MKCoordinateSpan(latitudeDelta: smallSpan.latitudeDelta * 1.3, longitudeDelta: smallSpan.longitudeDelta * 1.3)
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var reuseId = ""
        
        switch annotation
        {
            case _ as FBAnnotationCluster:
                reuseId = "Cluster"
                var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
                if clusterView == nil {
                    clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: self.configuration)
                } else {
                    clusterView?.annotation = annotation
                }
                
                return clusterView
            
            case _ as FBAnnotation:
                reuseId = "Pin"
                var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
                if pinView == nil {
                    pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                    pinView?.pinTintColor = UIColor.green
                } else {
                    pinView?.annotation = annotation
                }
                
                return pinView
            
            default:
                return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView])
    {
        for view in views
        {
            switch (view.annotation)
            {
                case let annotation as FBBaseAnnotation:
                    annotation.animate()
                
                default: ()
            }
        }
    }
    
    @IBAction fileprivate func reloadData()
    {
        clusteringManager.replace(annotations: randomLocationsWithCount(numberOfLocations), in: mapView)
    }
}
