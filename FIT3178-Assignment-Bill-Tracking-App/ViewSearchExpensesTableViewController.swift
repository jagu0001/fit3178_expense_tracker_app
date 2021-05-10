//
//  ViewSearchExpensesTableViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/10/21.
//

import UIKit

class ViewSearchExpensesTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    let SECTION_UNPAID = 0
    let SECTION_PAID = 1
    
    let CELL_UNPAID = "unpaidCell"
    let CELL_PAID = "paidCell"
    
    var paidExpenses: [Expense] = []
    var unpaidExpenses: [Expense] = []
    
    var filteredPaidExpenses: [Expense] = []
    var filteredUnpaidExpenses: [Expense] = []
    
    var listenerType: ListenerType = .all
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Set up search bar
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Expenses"
        navigationItem.searchController = searchController

        // This view controller decides how the search controller is presented
        definesPresentationContext = true
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
                return filteredUnpaidExpenses.count
            case SECTION_PAID:
                return filteredPaidExpenses.count
            default:
                return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        if indexPath.section == SECTION_PAID {
            let paidCell = tableView.dequeueReusableCell(withIdentifier: CELL_PAID, for: indexPath)
            let expense = filteredPaidExpenses[indexPath.row]
            
            // Set cell to allow multiple lines for details
            paidCell.detailTextLabel?.numberOfLines = 0
            
            paidCell.textLabel?.text = expense.name
            paidCell.detailTextLabel?.text = String(format: "$%.2f\nDate paid: %@", expense.amount, dateFormatter.string(from: expense.date!))
            paidCell.backgroundColor = UIColor(named: "PaidGreen")
            return paidCell
        }
        else {
            let unpaidCell = tableView.dequeueReusableCell(withIdentifier: CELL_UNPAID, for: indexPath)
            let expense = filteredUnpaidExpenses[indexPath.row]
            
            // Set cell to allow multiple lines for details
            unpaidCell.detailTextLabel?.numberOfLines = 0
            
            unpaidCell.textLabel?.text = expense.name
            unpaidCell.detailTextLabel?.text = String(format: "$%.2f\nDue date: %@", expense.amount, dateFormatter.string(from: expense.date!))
            
            let dueSoon = Calendar.current.date(byAdding: .day, value: -3, to: expense.date!)
            
            // Set cell color to red if expense is already due
            // Set cell color to yellow if expense is almost due
            if Date() > expense.date! {
                unpaidCell.backgroundColor = UIColor(named: "WarningLate")
            }
            else if Date() >= dueSoon! {
                unpaidCell.backgroundColor = UIColor(named: "WarningYellow")
            }
            return unpaidCell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case SECTION_UNPAID:
                if filteredUnpaidExpenses.count > 0 {
                    return "Unpaid Bills"
                }
                return nil
            case SECTION_PAID:
                if filteredPaidExpenses.count > 0 {
                    return "Paid Bills"
                }
                return nil
            default:
                return nil
        }
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == SECTION_PAID {
                databaseController?.deleteExpense(expense: filteredPaidExpenses[indexPath.row])
            }
            else if indexPath.section == SECTION_UNPAID {
                databaseController?.deleteExpense(expense: filteredUnpaidExpenses[indexPath.row])
            }
        }
    }
    
    // MARK: - SearchResultsUpdating Protocol Methods
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        if searchText.count > 0 {
            filteredPaidExpenses = paidExpenses.filter({ (expense: Expense) -> Bool in
                return (expense.name?.lowercased().contains(searchText) ?? false)
            })
            filteredUnpaidExpenses = unpaidExpenses.filter({ (expense: Expense) -> Bool in
                return (expense.name?.lowercased().contains(searchText) ?? false)
            })
        }
        else {
            filteredPaidExpenses = paidExpenses
            filteredUnpaidExpenses = unpaidExpenses
        }
        tableView.reloadData()
    }
    
    // MARK: - DatabaseListener Protocol Methods
    func onExpenseChange(change: DatabaseChange, expenses: [Expense]) {
        // Do nothing
    }
    
    func onPaidExpenseGroupChange(change: DatabaseChange, expenses: [Expense]) {
        paidExpenses = expenses
        updateSearchResults(for: navigationItem.searchController!)
        tableView.reloadData()
        
    }
    
    func onUnpaidExpenseGroupChange(change: DatabaseChange, expenses: [Expense]) {
        unpaidExpenses = expenses
        updateSearchResults(for: navigationItem.searchController!)
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
