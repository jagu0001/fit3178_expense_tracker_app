//
//  ChartDataViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/11/21.
//

import UIKit
import CoreLocation

class ChartDataViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var data: UrbanAreaData?
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var transportLabel: UILabel!
    
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
                                self.foodLabel.text = "Monthly food cost: $\((self.data?.mealCost)!)"
                                self.transportLabel.text = "Monthly transport cost: $\((self.data?.publicTransportCost)!)"
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
                //print(locality!.first)
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
