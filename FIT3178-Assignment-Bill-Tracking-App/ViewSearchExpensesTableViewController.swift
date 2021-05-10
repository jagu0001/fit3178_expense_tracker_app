//
//  ViewSearchExpensesTableViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/10/21.
//

import UIKit

class ViewSearchExpensesTableViewController: UITableViewController, DatabaseListener {
    let SECTION_UNPAID = 0
    let SECTION_PAID = 1
    
    let CELL_UNPAID = "cellUnpaid"
    let CELL_PAID = "cellPaid"
    
    var paidExpenses: [Expense] = []
    var unpaidExpenses: [Expense] = []
    
    var listenerType: ListenerType = .all
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case SECTION_UNPAID:
                return unpaidExpenses.count
            case SECTION_PAID:
                return paidExpenses.count
            default:
                return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let paidCell = tableView.dequeueReusableCell(withIdentifier: CELL_PAID, for: indexPath)
        let expense = paidExpenses[indexPath.row]
        
        paidCell.textLabel?.text = expense.name
        paidCell.detailTextLabel?.text = String(format: "$%.2f", expense.amount)
        return paidCell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case SECTION_UNPAID:
                if unpaidExpenses.count > 0 {
                    return "Unpaid Bills"
                }
                return nil
            case SECTION_PAID:
                if paidExpenses.count > 0 {
                    return "Paid Bills"
                }
                return nil
            default:
                return nil
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == SECTION_PAID {
                databaseController?.deleteExpense(expense: paidExpenses[indexPath.row])
            }
            else if indexPath.section == SECTION_UNPAID {
                databaseController?.deleteExpense(expense: unpaidExpenses[indexPath.row])
            }
        }
    }
    
    // MARK: - DatabaseListener Protocol Methods
    func onExpenseChange(change: DatabaseChange, expenses: [Expense]) {
        // Do nothing
    }
    
    func onPaidExpenseGroupChange(change: DatabaseChange, expenses: [Expense]) {
        paidExpenses = expenses
        tableView.reloadData()
        
    }
    
    func onUnpaidExpenseGroupChange(change: DatabaseChange, expenses: [Expense]) {
        unpaidExpenses = expenses
        tableView.reloadData()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "viewUnpaidExpenseDetailsSegue" {
            let destination = segue.destination as! ExpenseDetailsTableViewController
            let indexPath = tableView.indexPathForSelectedRow
            destination.expense = unpaidExpenses[indexPath!.row]
        }
        else if segue.identifier == "viewPaidExpenseDetailsSegue" {
            let destination = segue.destination as! ExpenseDetailsTableViewController
            let indexPath = tableView.indexPathForSelectedRow
            destination.expense = paidExpenses[indexPath!.row]
        }
    }
}
