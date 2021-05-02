//
//  Expense+CoreDataProperties.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/1/21.
//
//

import Foundation
import CoreData


extension Expense {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        return NSFetchRequest<Expense>(entityName: "Expense")
    }

    @NSManaged public var name: String?
    @NSManaged public var date: Date?
    @NSManaged public var expenseDescription: String?
    @NSManaged public var amount: Float
    @NSManaged public var tag: String?

}

extension Expense : Identifiable {

}
