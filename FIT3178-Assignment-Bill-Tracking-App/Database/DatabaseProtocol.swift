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
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onExpenseChange(change: DatabaseChange, expenses: [Expense])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addExpense(name: String, tag: String, amount: Float, description: String, date: Date)
    func deleteExpense(expense: Expense)
}

