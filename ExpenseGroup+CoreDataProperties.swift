//
//  ExpenseGroup+CoreDataProperties.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/3/21.
//
//

import Foundation
import CoreData


extension ExpenseGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExpenseGroup> {
        return NSFetchRequest<ExpenseGroup>(entityName: "ExpenseGroup")
    }

    @NSManaged public var name: String?
    @NSManaged public var expenses: NSSet?

}

// MARK: Generated accessors for expenses
extension ExpenseGroup {

    @objc(addExpensesObject:)
    @NSManaged public func addToExpenses(_ value: Expense)

    @objc(removeExpensesObject:)
    @NSManaged public func removeFromExpenses(_ value: Expense)

    @objc(addExpenses:)
    @NSManaged public func addToExpenses(_ values: NSSet)

    @objc(removeExpenses:)
    @NSManaged public func removeFromExpenses(_ values: NSSet)

}

extension ExpenseGroup : Identifiable {

}
