//
//  MyBillsMainViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 4/27/21.
//

import UIKit

class MyBillsMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatabaseListener {
    var listenerType: ListenerType = .all
    
    let SECTION_UNPAID = 0
    let SECTION_PAID = 1
    
    let CELL_UNPAID = "cellUnpaid"
    let CELL_PAID = "cellPaid"
    
    var paidExpenses: [Expense] = []
    var unpaidExpenses: [Expense] = []

    @IBOutlet weak var tableView: UITableView!
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        //Initialize database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case SECTION_UNPAID:
                return unpaidExpenses.count
            case SECTION_PAID:
                return paidExpenses.count
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_PAID {
            let paidCell = tableView.dequeueReusableCell(withIdentifier: CELL_PAID, for: indexPath)
            let expense = paidExpenses[indexPath.row]
            
            paidCell.textLabel?.text = expense.name
            paidCell.detailTextLabel?.text = String(format: "$%.2f", expense.amount)
            return paidCell
        }
        
        // Otherwise, configure unpaid bills cell
        let unpaidCell = tableView.dequeueReusableCell(withIdentifier: CELL_UNPAID, for: indexPath)
        let expense = unpaidExpenses[indexPath.row]
            
        unpaidCell.textLabel?.text = expense.name
        unpaidCell.detailTextLabel?.text = String(format: "$%.2f", expense.amount)
        return unpaidCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
