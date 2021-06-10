//
//  LocationsTableViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 6/7/21.
//

import UIKit

class LocationsTableViewController: UITableViewController, DatabaseListener {
    var listenerType: ListenerType = .mapAnnotation
    weak var databaseController: DatabaseProtocol?
    
    let CELL_LOCATION = "locationCell"
    let CELL_INFO = "infoCell"
    
    let SECTION_LOCATION = 0
    let SECTION_INFO = 1
    
    weak var mapViewController: MapViewController?
    var annotationList = [MapAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case SECTION_LOCATION:
                return annotationList.count
            case SECTION_INFO:
                return annotationList.count == 0 ? 1 : 0
            default:
                return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Info cell
        if indexPath.section == SECTION_INFO {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
            cell.textLabel?.text = "Please tap the + button to save ATM locations"
            cell.backgroundColor = UIColor(named: "PastelGreen")
            return cell
        }
        
        // Location cell
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LOCATION, for: indexPath)
        let location = annotationList[indexPath.row]
        cell.textLabel?.text = location.title
        cell.detailTextLabel?.text = location.subtitle
        cell.backgroundColor = UIColor(named: "ExpenseGray")
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == SECTION_LOCATION
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            databaseController?.deleteAnnotation(annotation: annotationList[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

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
    
    // MARK: - Database Listener Protocol Methods
    func onExpenseChange(change: DatabaseChange, expenses: [Expense]) {
        // Do nothing
    }
    
    func onPaidExpenseGroupChange(change: DatabaseChange, expenses: [Expense]) {
        // Do nothing
    }
    
    func onUnpaidExpenseGroupChange(change: DatabaseChange, expenses: [Expense]) {
        // Do nothing
    }
    
    func onMapAnnotationChange(change: DatabaseChange, annotations: [MapAnnotation]) {
        annotationList = annotations
        tableView.reloadData()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "focusSegue" {
            let destination = segue.destination as! MapViewController
            let indexPath = tableView.indexPathForSelectedRow
            let annotationInfo = annotationList[indexPath!.row]
            let annotation = LocationAnnotation(title: annotationInfo.title!, subtitle: annotationInfo.subtitle!, lat: annotationInfo.latitude, lon: annotationInfo.longitude)
            
            destination.focusLocation = annotation
        }
    }
    

}
