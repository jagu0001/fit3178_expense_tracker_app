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
    @IBOutlet weak var dataTimeframeSegment: UISegmentedControl!
    
    var allExpenses: [Expense]?
    var tagTotals: ([String : Float])?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
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
        // Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        
        // Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        var colorfulTemplate = ChartColorTemplates.colorful()
        colorfulTemplate.append(NSUIColor(red: 20/255.0, green: 67/255.0, blue: 180/255.0, alpha: 1.0))
        pieChartDataSet.colors = colorfulTemplate
        
        // Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .currency
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        
        // Assign it to the chart’s data
        chartView.data = pieChartData
        
        // Add controls to segmented view
        dataTimeframeSegment.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    func customizeChartWithExpenses(expenses: [Expense]) {
        let expenseTagData = calculateTotalExpenseTags(expenses: expenses)
        var tagPoints: [String] = []
        var tagValues: [Double] = []
        
        for (tag, total) in expenseTagData {
            tagPoints.append(tag)
            tagValues.append(Double(total))
        }
        
        customizeChart(dataPoints: tagPoints, values: tagValues)
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
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            let monthExpenses = filterExpensesByMonth(expenses: allExpenses!)
            customizeChartWithExpenses(expenses: monthExpenses)
        }
        else if sender.selectedSegmentIndex == 1 {
            let quarterlyExpenses = filterExpensesByQuarter(expenses: allExpenses!)
            customizeChartWithExpenses(expenses: quarterlyExpenses)
        }
        else {
            let yearlyExpenses = filterExpensesByYear(expenses: allExpenses!)
            customizeChartWithExpenses(expenses: yearlyExpenses)
        }
    }
    
    private func filterExpensesByMonth(expenses: [Expense]) -> [Expense] {
        return expenses.filter {
            return Calendar.current.component(.month, from: $0.date!) == Calendar.current.component(.month, from: Date())
        }
    }
    
    private func filterExpensesByQuarter(expenses: [Expense]) -> [Expense] {
        return expenses.filter {
            return Calendar.current.component(.quarter, from: $0.date!) == Calendar.current.component(.quarter, from: Date())
        }
    }
    
    private func filterExpensesByYear(expenses: [Expense]) -> [Expense] {
        return expenses.filter {
            return Calendar.current.component(.year, from: $0.date!) == Calendar.current.component(.year, from: Date())
        }
    }
    
    // MARK: - DatabaseListener Protocol Methods
    
    func onExpenseChange(change: DatabaseChange, expenses: [Expense]) {
        // Set allExpenses attribute
        allExpenses = expenses

        // Filter expenses for only this month
        var filteredExpenses: [Expense] = []
        
        switch dataTimeframeSegment.selectedSegmentIndex {
            case 0:
                filteredExpenses = filterExpensesByMonth(expenses: allExpenses!)
            case 1:
                filteredExpenses = filterExpensesByQuarter(expenses: allExpenses!)
            case 2:
                filteredExpenses = filterExpensesByYear(expenses: allExpenses!)
            default:
                filteredExpenses = []
        }
        
        customizeChartWithExpenses(expenses: filteredExpenses)
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
