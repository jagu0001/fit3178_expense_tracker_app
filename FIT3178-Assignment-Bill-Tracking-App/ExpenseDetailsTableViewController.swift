//
//  ExpenseDetailsTableViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/5/21.
//

import UIKit

class ExpenseDetailsTableViewController: UITableViewController {
    let SECTION_NAME = 0
    let SECTION_AMOUNT = 1
    let SECTION_TAG = 2
    let SECTION_DESCRIPTION = 3
    let SECTION_DATE = 4
    
    let CELL_NAME = "nameCell"
    let CELL_AMOUNT = "amountCell"
    let CELL_TAG = "tagCell"
    let CELL_DESCRIPTION = "descriptionCell"
    let CELL_DATE = "dateCell"
    
    var expense: Expense?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_NAME {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_NAME, for: indexPath)
            cell.textLabel?.text = expense?.name
            return cell
        }
        
        if indexPath.section == SECTION_AMOUNT {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_AMOUNT, for: indexPath)
            cell.textLabel?.text = "$\(expense!.amount)"
            return cell
        }
        
        if indexPath.section == SECTION_TAG {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_TAG, for: indexPath)
            cell.textLabel?.text = expense?.tag
            return cell
        }
        
        if indexPath.section == SECTION_DESCRIPTION {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DESCRIPTION, for: indexPath)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = expense?.expenseDescription
            return cell
        }
        
        // Otherwise, return date cell
        // Create date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        // Add formatted date string to cell
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DATE, for: indexPath)
        cell.textLabel?.text = dateFormatter.string(from: expense!.date!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case SECTION_NAME:
                return "Expense Name"
            case SECTION_AMOUNT:
                return "Amount"
            case SECTION_TAG:
                return "Tag"
            case SECTION_DESCRIPTION:
                return "Description"
            case SECTION_DATE:
                return "Date"
            default:
                return ""
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "editExpense" {
            let destination = segue.destination as! AddEditExpenseViewController
            destination.expense = expense
        }
    }
}
