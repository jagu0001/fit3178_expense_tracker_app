//
//  AddEditExpenseViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/3/21.
//

import UIKit
import MessageUI

class AddEditExpenseViewController: UIViewController, UITextFieldDelegate {

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
        
        // Initialize fields if expense is present
        initializeFields()
        
        // Add button to dismiss keyboard when editing TextView
        descriptionTextView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        
        // Assign self as delegate to text fields to dismiss properly
        nameTextField.delegate = self
        amountTextField.delegate = self
        tagTextField.delegate = self
    }
    
    @objc func tapDone(sender: Any) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func initializeFields() {
        if let expense = expense {
            nameTextField.text = expense.name
            amountTextField.text = expense.amount.description
            tagTextField.text = expense.tag
            descriptionTextView.text = expense.expenseDescription
            payDatePicker.date = expense.date!
        }
    }
    
    @IBAction func saveExpense(_ sender: Any) {
        let newExpense = databaseController!.getContextExpense(expense: expense)
        
        guard let name = nameTextField.text, name != "", let amount = amountTextField.text, amount != "", let tag = tagTextField.text, let description = descriptionTextView.text, description != "" else {
            displayMessage(title: "Error", message: "Please do not leave any blank fields")
            return
        }
        
        // Set values for expense class
        newExpense.name = name
        newExpense.amount = (amount as NSString).floatValue
        newExpense.expenseDescription = description
        newExpense.tag = tag
        newExpense.date = payDatePicker.date
        
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
