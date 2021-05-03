//
//  AddEditExpenseViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/3/21.
//

import UIKit

class AddEditExpenseViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var paidSwitch: UISwitch!
    @IBOutlet weak var remindSwitch: UISwitch!
    @IBOutlet weak var payDatePicker: UIDatePicker!
    
    weak var databaseController: DatabaseProtocol?
    var expense: Expense?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    @IBAction func saveExpense(_ sender: Any) {
        let newExpense = databaseController!.getContextExpense(expense: expense)
        
        if let name = nameTextField.text, name != "", let amount = amountTextField.text, amount != "", let tag = tagTextField.text, let description = descriptionTextView.text {
            newExpense.name = name
            newExpense.amount = (amount as NSString).floatValue
            newExpense.expenseDescription = description
            newExpense.tag = tag
            newExpense.date = payDatePicker.date
        }
        
        if paidSwitch.isOn {
            databaseController?.addExpenseToGroup(expense: newExpense, group: databaseController!.paidExpenseGroup)
        }
        else {
            databaseController?.addExpenseToGroup(expense: newExpense, group: databaseController!.unpaidExpenseGroup)
        }
        
        // Save context
        databaseController?.cleanup()
        
        // Go back to previous view
        navigationController?.popViewController(animated: true)
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
