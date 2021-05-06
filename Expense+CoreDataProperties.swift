//
//  Expense+CoreDataProperties.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/6/21.
//
//

import Foundation
import CoreData


extension Expense {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        return NSFetchRequest<Expense>(entityName: "Expense")
    }

    @NSManaged public var amount: Float
    @NSManaged public var date: Date?
    @NSManaged public var expenseDescription: String?
    @NSManaged public var name: String?
    @NSManaged public var tag: String?
    @NSManaged public var expenseGroup: NSSet?
    @NSManaged public var image: ImageMetaData?

}

// MARK: Generated accessors for expenseGroup
extension Expense {

    @objc(addExpenseGroupObject:)
    @NSManaged public func addToExpenseGroup(_ value: ExpenseGroup)

    @objc(removeExpenseGroupObject:)
    @NSManaged public func removeFromExpenseGroup(_ value: ExpenseGroup)

    @objc(addExpenseGroup:)
    @NSManaged public func addToExpenseGroup(_ values: NSSet)

    @objc(removeExpenseGroup:)
    @NSManaged public func removeFromExpenseGroup(_ values: NSSet)

}

extension Expense : Identifiable {

}
