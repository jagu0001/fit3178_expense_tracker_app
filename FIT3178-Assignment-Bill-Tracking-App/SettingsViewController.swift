//
//  SettingsViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/22/21.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print("Log out error: \(error.localizedDescription)")
        }
        self.tabBarController?.navigationController?.popViewController(animated: true)
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
