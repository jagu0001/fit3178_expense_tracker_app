//
//  MyBillsMainViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 4/27/21.
//

import UIKit

class MyBillsMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let SECTION_UNPAID = 0
    let SECTION_PAID = 1
    
    let CELL_UNPAID = "cellUnpaid"
    let CELL_PAID = "cellPaid"
    
    var unpaidBills: [Bill] = []
    var paidBills: [Bill] = []

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    
        // Do any additional setup after loading the view.
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case SECTION_UNPAID:
                return unpaidBills.count
            case SECTION_PAID:
                return paidBills.count
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case SECTION_UNPAID:
                return "Unpaid Bills"
            case SECTION_PAID:
                return "Paid Bills"
            default:
                return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for:
        indexPath)
        // Configure the cell...
        return cell

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
