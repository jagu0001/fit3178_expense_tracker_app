//
//  MapAnnotation+CoreDataProperties.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 6/10/21.
//
//

import Foundation
import CoreData


extension MapAnnotation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MapAnnotation> {
        return NSFetchRequest<MapAnnotation>(entityName: "MapAnnotation")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var title: String?
    @NSManaged public var subtitle: String?

}

extension MapAnnotation : Identifiable {

}
