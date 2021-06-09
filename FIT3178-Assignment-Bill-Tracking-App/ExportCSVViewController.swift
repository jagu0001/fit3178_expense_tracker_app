//
//  ExportCSVViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/27/21.
//

import UIKit
import SwiftCSVExport

class ExportCSVViewController: UIViewController {
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    var allExpenses: [Expense]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func exportCSV(_ sender: Any) {
        let startDateValue = startDate.date
        let endDateValue = endDate.date
        
        let dataList = NSMutableArray()
        let header = ["name", "amount", "description", "tag", "date", "isPaid"]
        
        if let allExpenses = self.allExpenses {
            for expense in allExpenses {
                if (expense.date! >= startDateValue) && (expense.date! <= endDateValue) {
                    // Set all data for CSV
                    let expenseData: NSMutableDictionary = NSMutableDictionary()
                    expenseData.setObject(expense.name, forKey: "name" as NSCopying)
                    expenseData.setObject(expense.amount, forKey: "amount" as NSCopying)
                    expenseData.setObject(expense.expenseDescription, forKey: "description" as NSCopying)
                    expenseData.setObject(expense.tag, forKey: "tag" as NSCopying)
                    expenseData.setObject(expense.date, forKey: "date" as NSCopying)
                    expenseData.setObject(expense.isPaid, forKey: "isPaid" as NSCopying)
                    
                    // Add expense to data list
                    dataList.add(expenseData)
                }
            }
        }
        
        // Create CSV object and write to object
        let writeCSVObj = CSV()
        writeCSVObj.rows = dataList
        writeCSVObj.delimiter = DividerType.comma.rawValue
        writeCSVObj.fields = header as NSArray
        writeCSVObj.name = "expenseList"
        
        // Write file
        let export = CSVExport.export(writeCSVObj)
        
        if export.result.isSuccess {
            displayMessage(title: "Success!", message: "File has been saved to \(export.filePath!)")
        }
        else {
            displayMessage(title: "Error", message: "Error in exporting data: \(export.message)")
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
