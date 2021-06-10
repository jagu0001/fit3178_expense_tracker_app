//
//  ChartViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/23/21.
//

import UIKit
import Charts

// This class uses the Charts library to create and display the charts
// Full documentation can be found at: https://github.com/danielgindi/Charts

class ChartViewController: UIViewController, DatabaseListener {
    var listenerType: ListenerType = .all
    weak var databaseController: DatabaseProtocol?
    @IBOutlet weak var chartView: PieChartView!
    
    var allExpenses: [Expense]?
    var tagTotals: ([String : Float])?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        //customizeChart(dataPoints: players, values: goals.map {Double($0)})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.databaseController?.removeListener(listener: self)
    }
    
    func customizeChart(dataPoints: [String], values: [Double]) {
        // 1. Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        
        // 2. Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = ChartColorTemplates.colorful()
        
        // 3. Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .currency
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        
        // 4. Assign it to the chart’s data
        chartView.data = pieChartData
    }
    
    func calculateTotalExpenseTags(expenses: [Expense]) -> [String : Float] {
        var tagTotals = [String : Float]()
        
        for expense in expenses {
            if tagTotals.keys.contains(expense.tag!) {
                tagTotals[expense.tag!]! += expense.amount
            }
            else {
                tagTotals[expense.tag!] = expense.amount
            }
        }
        self.tagTotals = tagTotals
        return tagTotals
    }
    
    // MARK: - DatabaseListener Protocol Methods
    
    func onExpenseChange(change: DatabaseChange, expenses: [Expense]) {
        // Set allExpenses attribute
        allExpenses = expenses

        // Filter expenses for only this month
        let monthExpenses = expenses.filter {
            return Calendar.current.component(.month, from: $0.date!) == Calendar.current.component(.month, from: Date())
        }
        
        let expenseTagData = calculateTotalExpenseTags(expenses: monthExpenses)
        var tagPoints: [String] = []
        var tagValues: [Double] = []
        
        for (tag, total) in expenseTagData {
            tagPoints.append(tag)
            tagValues.append(Double(total))
        }
        
        customizeChart(dataPoints: tagPoints, values: tagValues)
    }
    
    func onPaidExpenseGroupChange(change: DatabaseChange, expenses: [Expense]) {
        // Do nothing
    }
    
    func onUnpaidExpenseGroupChange(change: DatabaseChange, expenses: [Expense]) {
        // Do nothing
    }
    
    func onMapAnnotationChange(change: DatabaseChange, annotations: [MapAnnotation]) {
        // Do nothing
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "localDataSegue" {
            if let tagTotals = self.tagTotals {
                let destination = segue.destination as! LocalDataViewController
                destination.totalExpenseData = tagTotals
            }
        }
        else if segue.identifier == "exportCSVSegue" {
            if let allExpenses = self.allExpenses {
                let destination = segue.destination as! ExportCSVViewController
                destination.allExpenses = allExpenses
            }
        }
        else if segue.identifier == "exportPDFSegue" {
            if let allExpenses = self.allExpenses {
                let destination = segue.destination as! ExportPDFViewController
                destination.allExpenses = allExpenses
            }
        }
    }

}
