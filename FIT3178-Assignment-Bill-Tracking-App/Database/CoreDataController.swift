//
//  CoreDataController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/2/21.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    let PAID_EXPENSE_GROUP_NAME = "Paid Expense"
    let UNPAID_EXPENSE_GROUP_NAME = "Unpaid Expense"
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    var allExpensesFetchedResultsController: NSFetchedResultsController<Expense>?
    var paidExpenseGroupFetchedResultsController: NSFetchedResultsController<Expense>?
    var unpaidExpenseGroupFetchedResultsController: NSFetchedResultsController<Expense>?
    
    lazy var paidExpenseGroup: ExpenseGroup = {
        var expenseGroups = [ExpenseGroup]()
        
        let request: NSFetchRequest<ExpenseGroup> = ExpenseGroup.fetchRequest()
        let predicate = NSPredicate(format: "name = %@", PAID_EXPENSE_GROUP_NAME)
        request.predicate = predicate
        
        do {
            try expenseGroups = persistentContainer.viewContext.fetch(request)
        }
        catch {
            print("Fetch request failed: \(error)")
        }
        
        if let firstGroup = expenseGroups.first {
            return firstGroup
        }
        return addExpenseGroup(name: PAID_EXPENSE_GROUP_NAME)
    }()
    
    lazy var unpaidExpenseGroup: ExpenseGroup = {
        var expenseGroups = [ExpenseGroup]()
        
        let request: NSFetchRequest<ExpenseGroup> = ExpenseGroup.fetchRequest()
        let predicate = NSPredicate(format: "name = %@", UNPAID_EXPENSE_GROUP_NAME)
        request.predicate = predicate
        
        do {
            try expenseGroups = persistentContainer.viewContext.fetch(request)
        }
        catch {
            print("Fetch request failed: \(error)")
        }
        
        if let firstGroup = expenseGroups.first {
            return firstGroup
        }
        return addExpenseGroup(name: UNPAID_EXPENSE_GROUP_NAME)
    }()
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "FIT3178-ExpenseApp-DataModel")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data with error: \(error)")
            }
        }
        
        super.init()
    }
    
    func testAddExpense() {
        let expense1 = self.addExpense(name: "Test Paid Expense", tag: "Food", amount: 20.5, description: "This is a test expense", date: Date())
        addExpenseToGroup(expense: expense1, group: paidExpenseGroup)
        
        let expense2 = self.addExpense(name: "Test Paid Expense 2", tag: "Drink", amount: 11.2, description: "This is a second test expense", date: Date())
        addExpenseToGroup(expense: expense2, group: paidExpenseGroup)
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
        
        if listener.listenerType == .paidGroup || listener.listenerType == .all {
            listener.onPaidExpenseGroupChange(change: .update, expenses: fetchPaidExpenses())
        }
        
        if listener.listenerType == .unpaidGroup || listener.listenerType == .all {
            listener.onUnpaidExpenseGroupChange(change: .update, expenses: fetchUnpaidExpenses())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addExpense(name: String, tag: String, amount: Float, description: String, date: Date) -> Expense {
        let expense = NSEntityDescription.insertNewObject(forEntityName: "Expense", into: persistentContainer.viewContext) as! Expense
        
        expense.name = name
        expense.tag = tag
        expense.amount = amount
        expense.expenseDescription = description
        expense.date = date
        
        return expense
    }
    
    func deleteExpense(expense: Expense) {
        persistentContainer.viewContext.delete(expense)
    }
    
    func addExpenseGroup(name: String) -> ExpenseGroup {
        let group = NSEntityDescription.insertNewObject(forEntityName: "ExpenseGroup", into: persistentContainer.viewContext) as! ExpenseGroup
        group.name = name
        return group
    }
    
    func getContextExpense(expense: Expense?) -> Expense {
        if let expense = expense {
            return persistentContainer.viewContext.object(with: expense.objectID) as! Expense
        }
        let expense = NSEntityDescription.insertNewObject(forEntityName: "Expense", into: persistentContainer.viewContext) as! Expense
        return expense
    }
    
    func deleteExpenseGroup(expenseGroup: ExpenseGroup) {
        persistentContainer.viewContext.delete(expenseGroup)
    }
    
    func addExpenseToGroup(expense: Expense, group: ExpenseGroup) {
        group.addToExpenses(expense)
    }
    
    func removeExpenseFromGroup(expense: Expense, group: ExpenseGroup) {
        group.removeFromExpenses(expense)
    }
    
    func fetchAllExpenses() -> [Expense] {
        if allExpensesFetchedResultsController == nil {
            let request: NSFetchRequest<Expense> = Expense.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            // Initialize Fetched Results Controller
            allExpensesFetchedResultsController = NSFetchedResultsController<Expense>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            // Set this class to be the results delegate
            allExpensesFetchedResultsController?.delegate = self
            
            do {
                try allExpensesFetchedResultsController?.performFetch()
            }
            catch {
                print("Fetch request failed: \(error)")
            }
        }
        
        if let expenses = allExpensesFetchedResultsController?.fetchedObjects {
            return expenses
        }
        return [Expense]()
    }
    
    func fetchPaidExpenses() -> [Expense] {
        if paidExpenseGroupFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            let predicate = NSPredicate(format: "ANY expenseGroup.name == %@", PAID_EXPENSE_GROUP_NAME)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            fetchRequest.predicate = predicate
            
            // Initialize Fetched Results Controller
            paidExpenseGroupFetchedResultsController = NSFetchedResultsController<Expense>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            // Set this class to be the results delegate
            paidExpenseGroupFetchedResultsController?.delegate = self
            
            do {
                try paidExpenseGroupFetchedResultsController?.performFetch()
            }
            catch {
                print("Fetch request failed: \(error)")
            }
        }
        var expenses = [Expense]()
        if paidExpenseGroupFetchedResultsController?.fetchedObjects != nil {
            expenses = (paidExpenseGroupFetchedResultsController?.fetchedObjects)!
        }
        return expenses
    }
    
    func fetchUnpaidExpenses() -> [Expense] {
        if unpaidExpenseGroupFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            let predicate = NSPredicate(format: "ANY expenseGroup.name == %@", UNPAID_EXPENSE_GROUP_NAME)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            fetchRequest.predicate = predicate
            
            // Initialize Fetched Results Controller
            unpaidExpenseGroupFetchedResultsController = NSFetchedResultsController<Expense>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            // Set this class to be the results delegate
            unpaidExpenseGroupFetchedResultsController?.delegate = self
            
            do {
                try unpaidExpenseGroupFetchedResultsController?.performFetch()
            }
            catch {
                print("Fetch request failed: \(error)")
            }
        }
        var expenses = [Expense]()
        if unpaidExpenseGroupFetchedResultsController?.fetchedObjects != nil {
            expenses = (unpaidExpenseGroupFetchedResultsController?.fetchedObjects)!
        }
        return expenses
    }
    
    // MARK: - Fetched Results Controller Protocol Methods
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allExpensesFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .expense || listener.listenerType == .all {
                    listener.onExpenseChange(change: .update, expenses: fetchAllExpenses())
                }
            }
        }
        else if controller == paidExpenseGroupFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .paidGroup || listener.listenerType == .all {
                    listener.onPaidExpenseGroupChange(change: .update, expenses: fetchPaidExpenses())
                }
            }
        }
        else if controller == unpaidExpenseGroupFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .unpaidGroup || listener.listenerType == .all {
                    listener.onUnpaidExpenseGroupChange(change: .update, expenses: fetchUnpaidExpenses())
                }
            }
        }
    }
}
