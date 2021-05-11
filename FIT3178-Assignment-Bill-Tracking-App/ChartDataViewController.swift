//
//  ChartDataViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/11/21.
//

import UIKit

class ChartDataViewController: UIViewController {
    let API_URL = "https://api.teleport.org/api/urban_areas/slug:melbourne/details/"
    var data: UrbanAreaData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestData()

        // Do any additional setup after loading the view.
    }
    
    func requestData() {
        let requestURL = URL(string: API_URL)!
        let task = URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let urbanAreaData = try decoder.decode(UrbanArea.self, from: data!)
                
                if let dataList = urbanAreaData.categories {
                    for data in dataList {
                        if let transportCost = data.publicTransportCost, let mealCost = data.mealCost {
                            self.data = data
                        }
                    }
                }
            }
            catch let err {
                print(err)
            }
        }
        task.resume()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
