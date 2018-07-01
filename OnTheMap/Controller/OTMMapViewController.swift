//
//  OTMMapViewController.swift
//  OnTheMap
//
//  Created by Ping Wu on 1/7/18.
//  Copyright © 2018 . All rights reserved.
//

import UIKit
import MapKit

// MARK: - OTMMapViewController: UIViewController

class OTMMapViewController: UIViewController {
    
    // MARK: Properties
    let locations = LocationStore.sharedInstance().allLocations
    var annotations: [MKPointAnnotation]!
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareUI()
        setUIWhileLoading(false)
        loadMapLocations()
    }
    
    
    // MARK: Actions
    
    @objc func loadMapLocations() {
        setUIWhileLoading(true)
        
        PARSEClient.sharedInstance().getAllLocations { (success, locations, error) in
        
            if success,
                let locations = locations {
                
                let newAnnotations = self.makeAnnotations(locations)
            
                performUIUpdatesOnMain {
                    if let oldAnnotations = self.annotations {
                        self.mapView.removeAnnotations(oldAnnotations)
                    }
                    self.annotations = newAnnotations
                    self.mapView.addAnnotations(newAnnotations)
                    self.setUIWhileLoading(false)
                }
            } else {
                performUIUpdatesOnMain {
                    self.setUIWhileLoading(false)
                    errorAlertView(error!.userInfo[NSLocalizedDescriptionKey] as! String, self)
                }
            }
        }
    }
}

// MARK: - OTMMapViewController (Helpers)

extension OTMMapViewController {
    
    func makeAnnotations(_ locations: [PARSEUserLocation]) -> [MKPointAnnotation] {
        var annotations: [MKPointAnnotation] = [MKPointAnnotation]()
        
        for location in locations {
            if let lat = location.latitude,
                let long = location.longitude {
                
                let latDegress = CLLocationDegrees(lat)
                let longDegress = CLLocationDegrees(long)
                
                let coordinate = CLLocationCoordinate2D(latitude: latDegress, longitude: longDegress)
                
                let annotation = MKPointAnnotation()
                
                if let mediaURL = location.mediaURL,
                    let firstName = location.firstName,
                    let lastName = location.lastName {
                    
                    annotation.coordinate = coordinate
                    annotation.title = "\(firstName)\(lastName)"
                    annotation.subtitle = mediaURL
                }
                annotations.append(annotation)
            }
        }
        return annotations
    }
}

// MARK: - OTMMapViewController (UI)

extension OTMMapViewController {
    
    func prepareUI() {
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = true
        
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func setUIWhileLoading(_ isLoading: Bool) {
        isLoading ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        
        self.dimView.isHidden = !isLoading
        self.activityIndicatorView.isHidden = !isLoading
    }
}


// MARK: OTMMapViewController: MKMapViewDelegate

extension OTMMapViewController: MKMapViewDelegate {
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        setUIWhileLoading(true)
    }
    
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        setUIWhileLoading(!fullyRendered)
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle, toOpen != "" {
                app.open(URL(string: toOpen!)!, options: [:], completionHandler: nil)
            } else {
                errorAlertView("Cannot open URL", self)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reusedId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusedId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusedId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
}
