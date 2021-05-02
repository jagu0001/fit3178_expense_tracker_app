//
//  CoreDataController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/2/21.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol {
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "FIT3178-ExpenseApp-DataModel")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data with error: \(error)")
            }
        }
        super.init()
    }
    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            }
            catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .expense || listener.listenerType == .all {
            listener.onExpenseChange(change: .update, expenses: fetchAllExpenses())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addExpense(name: String, tag: String, amount: Float, description: String, date: Date) {
        let expense = NSEntityDescription.insertNewObject(forEntityName: "Expense", into: persistentContainer.viewContext) as! Expense
        
        expense.name = name
        expense.tag = tag
        expense.amount = amount
        expense.expenseDescription = description
        expense.date = date
    }
    
    func deleteExpense(expense: Expense) {
        persistentContainer.viewContext.delete(expense)
    }
    
    func fetchAllExpenses() -> [Expense] {
        var expenses = [Expense]()
        
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        
        do {
            try expenses = persistentContainer.viewContext.fetch(request)
        }
        catch {
            print("Fetch request failed with error: \(error)")
        }
        
        return expenses
    }
}
