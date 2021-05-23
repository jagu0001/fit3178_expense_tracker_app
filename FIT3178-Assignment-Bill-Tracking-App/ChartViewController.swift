//
//  ChartViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/23/21.
//

import UIKit
import Charts

class ChartViewController: UIViewController, DatabaseListener {
    var listenerType: ListenerType = .all
    weak var databaseController: DatabaseProtocol?
    @IBOutlet weak var chartView: PieChartView!
    
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
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
        
        // 3. Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        
        // 4. Assign it to the chart’s data
        chartView.data = pieChartData
    }
    
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        var colors: [UIColor] = []
        for _ in 0..<numbersOfColor {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        return colors
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
        return tagTotals
    }
    
    // MARK: - DatabaseListener Protocol Methods
    
    func onExpenseChange(change: DatabaseChange, expenses: [Expense]) {
        let expenseTagData = calculateTotalExpenseTags(expenses: expenses)
        var tagPoints: [String] = []
        var tagValues: [Double] = []
        
        for (tag, total) in expenseTagData {
            tagPoints.append(tag)
            tagValues.append(Double(total))
        }
        
        customizeChart(dataPoints: tagPoints, values: tagValues)
    }
    
    func onPaidExpenseGroupChange(change: DatabaseChange, expenses: [Expense]) {
        
    }
    
    func onUnpaidExpenseGroupChange(change: DatabaseChange, expenses: [Expense]) {
        
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
