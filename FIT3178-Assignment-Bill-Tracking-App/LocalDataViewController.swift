//
//  LocalDataViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/11/21.
//

import UIKit
import CoreLocation
import Charts

// This class uses the Teleport API to obtain monthly living costs for each region
// Full documentation can be found at: https://developers.teleport.org/api/reference/

class LocalDataViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var cityName: String?
    var data: UrbanAreaData?
    var totalExpenseData: ([String : Float])?
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
        // Set up authorization for location services
        let authorizationStatus = locationManager.authorizationStatus
        
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        if authorizationStatus == .denied {
            displayMessage(title: "Location Services Disabled", message: "Unable to view statistics without location services")
        }
        else {
            locationManager.requestLocation()
        }
        
        barChartView.noDataText = "No data for current location"
    }
    
    func requestData(latitude: String, longitude: String) {
        let latLon = latitude + "," + longitude
        guard let queryString = latLon.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Query string cannot be encoded")
            return
        }
        let requestString = "https://api.teleport.org/api/locations/\(queryString)"
        
        guard let requestURL = URL(string: requestString) else {
            print("Invalid URL")
            return
        }
        
        let locationTask = URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            do {
                let json = try RootCityData.init(data: data!)
                if let detailsString = json.embedded.nearestUrbanAreas.first?.links.nearestUrbanArea.href {
                    let detailsRequestURL = URL(string: detailsString + "details")
                    
                    let detailsTask = URLSession.shared.dataTask(with: detailsRequestURL!) { (data, response, error) in
                        if let error = error {
                            print(error)
                            return
                        }
                        
                        do {
                            let decoder = JSONDecoder()
                            let urbanAreaData = try decoder.decode(UrbanArea.self, from: data!)
                        
                            if let dataList = urbanAreaData.categories {
                                for data in dataList {
                                    if let _ = data.publicTransportCost, let _ = data.mealCost {
                                        self.data = data
                                    }
                                }
                            }
                            
                            DispatchQueue.main.async {
                                if let cityName = self.cityName {
                                    self.cityLabel.text = "Monthly Living Costs in \(cityName)"
                                }
                                self.drawBarChart()
                            }
                        }
                        catch let err {
                            print(err)
                        }
                    }
                    
                    detailsTask.resume()
                }
            }
            catch let err {
                print(err)
            }
        }
        locationTask.resume()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            CLGeocoder().reverseGeocodeLocation(location) { (locality, error) in
                self.cityName = locality!.first?.locality
            }
            location.fetchCity() { (city, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.requestData(latitude: "\(location.coordinate.latitude)", longitude: "\(location.coordinate.longitude)")
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if CLLocationManager.locationServicesEnabled() {
            
        }
    }
    
    // MARK: - Bar Chart Functions
    func drawBarChart() {
        let tags = ["Food", "Transport", "Movies", "Fitness"]
        let localCosts = [Double((self.data?.mealCost!)! * 2 * 30), Double((self.data?.publicTransportCost)!), Double((self.data?.movieCost)!), Double((self.data?.fitnessCost)!)]
        var expenses: [Double] = []
        
        for tag in tags {
            if totalExpenseData!.keys.contains(tag) {
                expenses.append(Double(totalExpenseData![tag]!))
            }
            else {
                expenses.append(0)
            }
        }
        configureChart(labels: tags, expenseData: expenses, localCostData: localCosts)
    }
    
    
    func configureChart(labels: [String], expenseData: [Double], localCostData: [Double]) {
        var expenseDataEntries: [BarChartDataEntry] = []
        var localCostDataEntries: [BarChartDataEntry] = []

        for i in 0..<labels.count {
            let expenseDataEntry = BarChartDataEntry(x: Double(i) , y: expenseData[i])
            expenseDataEntries.append(expenseDataEntry)

            let localCostDataEntry = BarChartDataEntry(x: Double(i) , y: localCostData[i])
               localCostDataEntries.append(localCostDataEntry)
        }

        let expenseChartDataSet = BarChartDataSet(entries: expenseDataEntries, label: "My Expenses")
        var localCostChartDataSet = BarChartDataSet(entries: localCostDataEntries, label: "Regular Costs")
        
        if let cityName = self.cityName {
            localCostChartDataSet = BarChartDataSet(entries: localCostDataEntries, label: "Costs in \(cityName)")
        }

        let dataSets: [BarChartDataSet] = [expenseChartDataSet, localCostChartDataSet]
        expenseChartDataSet.colors = [UIColor(red: 34/255, green: 126/255, blue: 230/255, alpha: 1)]
        let chartData = BarChartData(dataSets: dataSets)
        
        // Format x axis
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        xAxis.granularity = 1
        xAxis.centerAxisLabelsEnabled = true
        xAxis.axisMinimum = 0
        xAxis.axisMaximum = Double(labels.count)
            
        // Group bars
        let groupSpace = 0.3
        let barSpace = 0.05
        let barWidth = 0.3
        
        chartData.barWidth = barWidth;
        chartData.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
        
        barChartView.notifyDataSetChanged()
        barChartView.data = chartData
        
        //barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)

        // Animate chart appearance
        barChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)
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

extension CLLocation {
    func fetchCity(completion: @escaping (_ city: String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $1) }
    }
}
