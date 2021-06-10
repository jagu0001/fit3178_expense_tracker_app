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
    weak var databaseController: DatabaseProtocol?
    var focusLocation: LocationAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Setup MapView
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // Add default annotations
        addDefaultAnnotations()
        
        // If a location was selected from previous screen, zoom in there
        if let focusLocation = self.focusLocation {
            focusOn(annotation: focusLocation)
        }
    }
    
    func addDefaultAnnotations() {
        // Default Annotations are added for now;
        // The full NAB API for obtaining ATM coordinates
        // requires Production Access, which will be obtained
        // and implemented at a later date
        var defaultLocationList: [LocationAnnotation] = []
        
        let southernCross = LocationAnnotation(title: "Southern Cross Station", subtitle: "NAB ATM", lat: -37.8184, lon: 144.9525)
        defaultLocationList.append(southernCross)
        
        let melbCentral = LocationAnnotation(title: "Melbourne Central Station", subtitle: "NAB ATM", lat: -37.8102, lon: 144.9628)
        defaultLocationList.append(melbCentral)
        
        let collinsStreet = LocationAnnotation(title: "330 Collins Street", subtitle: "NAB SmartATM", lat: -37.8161, lon: 144.9637)
        defaultLocationList.append(collinsStreet)
        
        let carlton = LocationAnnotation(title: "288 Lygon Street", subtitle: "NAB SmartATM", lat: -37.780484, lon: 144.969417)
        defaultLocationList.append(carlton)
        
        let queenVictoriaMarket = LocationAnnotation(title: "Queen Victoria Market", subtitle: "NAB ATM", lat: -37.8076, lon: 144.9568)
        defaultLocationList.append(queenVictoriaMarket)
        
        let oxfordSquare = LocationAnnotation(title: "Oxford Square", subtitle: "NAB SmartATM", lat: -33.8790, lon: 151.2149)
        defaultLocationList.append(oxfordSquare)
        
        let harbourSide = LocationAnnotation(title: "Harbourside Shopping Centre", subtitle: "NAB ATM", lat: -33.8718, lon: 151.1989)
        defaultLocationList.append(harbourSide)
        
        let booragoon = LocationAnnotation(title: "Booragoon", subtitle: "NAB ATM" , lat: -32.0364, lon: 115.8380)
        defaultLocationList.append(booragoon)
        
        mapView.addAnnotations(defaultLocationList)
    }
    
    func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    // MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "atmLocations"
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotationInfo = view.annotation
        
        let added = databaseController?.addAnnotation(latitude: (annotationInfo?.coordinate.latitude)!, longitude: (annotationInfo?.coordinate.longitude)!, title: (annotationInfo?.title)!!, subtitle: (annotationInfo?.subtitle)!!)
        
        if !added! {
            displayMessage(title: "Error", message: "Location has already been added")
            return
        }
        
        // Return to list screen
        self.navigationController?.popViewController(animated: true)
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
