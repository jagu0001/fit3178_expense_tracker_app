//
//  DatabaseProtocol.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/1/21.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case expense
    case unpaidGroup
    case paidGroup
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onExpenseChange(change: DatabaseChange, expenses: [Expense])
    func onPaidExpenseGroupChange(change: DatabaseChange, expenses: [Expense])
    func onUnpaidExpenseGroupChange(change: DatabaseChange, expenses: [Expense])
}

protocol DatabaseProtocol: AnyObject {
    var paidExpenseGroup: ExpenseGroup {get}
    var unpaidExpenseGroup: ExpenseGroup {get}
    
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addExpense(name: String, tag: String, amount: Float, description: String, date: Date) -> Expense
    func deleteExpense(expense: Expense)
    
    func addExpenseGroup(name: String) -> ExpenseGroup
    func deleteExpenseGroup(expenseGroup: ExpenseGroup)
    func addExpenseToGroup(expense: Expense, group: ExpenseGroup)
    func removeExpenseFromGroup(expense: Expense, group: ExpenseGroup)
}
