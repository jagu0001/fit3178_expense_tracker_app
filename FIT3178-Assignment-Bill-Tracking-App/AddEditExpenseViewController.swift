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
        
        // Initialize expense at child context
        initializeExpense()
        
        // Assign self as delegate to text fields to dismiss properly
        nameTextField.delegate = self
        amountTextField.delegate = self
        tagTextField.delegate = self
        
        // Add button to dismiss keyboard when editing TextView
        descriptionTextView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        
        // Add borders to text view
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.cornerRadius = 5
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
    
    func initializeExpense() {
        expense = databaseController?.getChildContextExpense(expense: expense)
    }
    
    @IBAction func saveExpense(_ sender: Any) {
        guard let name = nameTextField.text, name != "", let amount = amountTextField.text, amount != "", let tag = tagTextField.text, let description = descriptionTextView.text, description != "" else {
            displayMessage(title: "Error", message: "Please do not leave any blank fields")
            return
        }
        
        // Set values for expense class
        expense!.name = name
        expense!.amount = (amount as NSString).floatValue
        expense!.expenseDescription = description
        expense!.tag = tag
        expense!.date = payDatePicker.date
        
        if paidSwitch.isOn {
            databaseController?.addExpenseToGroup(expense: expense!, group: databaseController!.paidExpenseGroup)
        }
        else {
            databaseController?.addExpenseToGroup(expense: expense!, group: databaseController!.unpaidExpenseGroup)
        }
        
        // Push child context data to main context
        databaseController?.saveChildContext()
        
        // Save context
        databaseController?.cleanup()
        
        // Refresh child context for next use
        databaseController?.refreshChildContext()
        
        // Go back to previous view
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addImageSegue" {
            let destination = segue.destination as! CameraViewController
            destination.expense = expense
        }
    }
}
