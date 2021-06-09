//
//  ExportPDFViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 6/9/21.
//

import UIKit
import SimplePDF

class ExportPDFViewController: UIViewController {

    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    var allExpenses: [Expense]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func exportPDF(_ sender: Any) {
        if startDate.date > endDate.date {
            displayMessage(title: "Error", message: "Start date cannot exceed end date")
            return
        }
        
        let A4_SIZE = CGSize(width: 595, height: 842)
        let pdf = SimplePDF(pageSize: A4_SIZE, pageMargin: 20)
        let headerDateFormatter = DateFormatter()
        headerDateFormatter.dateFormat = "dd/MM/yyyy"
        
        // Add text and some space for table
        pdf.addText("Your Expense History", font: UIFont.systemFont(ofSize: 30.0), textColor: UIColor.systemBlue)
        pdf.addText("From: \(headerDateFormatter.string(from: startDate.date)) to \(headerDateFormatter.string(from: endDate.date))", font: UIFont.systemFont(ofSize: 20.0), textColor: UIColor.systemGreen)
        pdf.addVerticalSpace(20.0)
        
        var dataArray: [[String]] = [["Expense Name", "Amount", "Description", "Date", "Paid"]]
        
        if let allExpenses = allExpenses {
            for expense in allExpenses {
                if expense.date! >= startDate.date && expense.date! <= endDate.date {
                    // Append all expense data into array to write into PDF table
                    var expenseData: [String] = []
                    expenseData.append(expense.name!)
                    expenseData.append("$\(expense.amount)")
                    expenseData.append(expense.expenseDescription!)
                    
                    // Format date to string
                    let expenseDateFormatter = DateFormatter()
                    expenseDateFormatter.dateFormat = "dd/MMM/yyyy, HH:mm"
                    expenseData.append(expenseDateFormatter.string(from: expense.date!))
                    
                    expenseData.append(expense.isPaid ? "Yes" : "No")
                    
                    dataArray.append(expenseData)
                }
            }
        }
        
        // Set up data table
        let tableDefinition = TableDefinition(alignments: [.center, .center, .center, .center, .center], columnWidths: [160.0, 50.0, 160.0, 100.0, 30.0], fonts: [UIFont.systemFont(ofSize: 10), UIFont.systemFont(ofSize: 10), UIFont.systemFont(ofSize: 10), UIFont.systemFont(ofSize: 10), UIFont.systemFont(ofSize: 10)], textColors: [UIColor.black, UIColor.black, UIColor.black, UIColor.black, UIColor.black])
        pdf.addTable(dataArray.count, columnCount: 5, rowHeight: 30, tableLineWidth: 0.5, tableDefinition: tableDefinition, dataArray: dataArray)
                
        let fileManager = FileManager.default
        do {
            let directory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = directory.appendingPathComponent("test").appendingPathExtension("pdf")
            displayMessage(title: "Success!", message: "File has been saved to \(fileURL)")
            let pdfData = pdf.generatePDFdata()
            try? pdfData.write(to: fileURL)
        }
        catch {
            print(error)
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
