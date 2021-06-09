//
//  LocationsTableViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 6/7/21.
//

import UIKit

class LocationsTableViewController: UITableViewController {
    let CELL_LOCATION = "locationCell"
    let CELL_INFO = "infoCell"
    
    let SECTION_LOCATION = 0
    let SECTION_INFO = 1
    
    weak var mapViewController: MapViewController?
    var locationList = [LocationAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case SECTION_LOCATION:
                return locationList.count
            case SECTION_INFO:
                return locationList.count == 0 ? 1 : 0
            default:
                return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Info cell
        if indexPath.section == SECTION_INFO {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
            cell.textLabel?.text = "Please tap the + button to save ATM locations"
            return cell
        }
        
        // Location cell
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LOCATION, for: indexPath)
        let location = locationList[indexPath.row]
        cell.textLabel?.text = location.title
        cell.detailTextLabel?.text = "Lat: \(location.coordinate.latitude), Lon: \(location.coordinate.longitude)"
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == SECTION_LOCATION
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            mapViewController?.mapView.removeAnnotation(locationList[indexPath.row])
            locationList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapViewController?.focusOn(annotation: locationList[indexPath.row])
        splitViewController?.show(.secondary)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
