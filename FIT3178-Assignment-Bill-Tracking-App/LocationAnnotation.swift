//
//  LocationAnnotation.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 6/7/21.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(title: String, subtitle: String, lat: Double, lon: Double) {
        self.title = title
        self.subtitle = subtitle
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
}
