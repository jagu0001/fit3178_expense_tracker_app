//
//  MapViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 6/7/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set map delegate as self
        mapView.delegate = self
        
        var locationList: [LocationAnnotation] = []
        var location = LocationAnnotation(title: "Monash Uni - Caulfield", subtitle: "The Caulfield Campus of the Uni", lat: -37.9105238, lon: 145.045374)
        locationList.append(location)
        location = LocationAnnotation(title: "Monash Uni - Clayton", subtitle: "The Clayton Campus of the Uni", lat: -37.9105238, lon: 145.1362182)
        locationList.append(location)
        
        mapView.addAnnotations(locationList)
        focusOn(annotation: locationList[0])
    }
    
    func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    // MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "aaa"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .contactAdd)
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
