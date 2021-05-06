//
//  ImageMetaData+CoreDataProperties.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/6/21.
//
//

import Foundation
import CoreData


extension ImageMetaData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageMetaData> {
        return NSFetchRequest<ImageMetaData>(entityName: "ImageMetaData")
    }

    @NSManaged public var filename: String?

}

extension ImageMetaData : Identifiable {

}
