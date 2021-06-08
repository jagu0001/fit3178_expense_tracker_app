//
//  AddEditExpenseViewController.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/3/21.
//

import UIKit
import MessageUI

class AddEditExpenseViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let appDelegate = {
       return UIApplication.shared.delegate as! AppDelegate
    }()
    
    let NOTIFICATION_IDENTIFIER = "edu.monash.fit3178.Expense-Tracker-App"

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var paidSwitch: UISwitch!
    @IBOutlet weak var remindSwitch: UISwitch!
    @IBOutlet weak var payDatePicker: UIDatePicker!
    @IBOutlet weak var tagPicker: UIPickerView!
    
    weak var databaseController: DatabaseProtocol?
    var expense: Expense?
    var tagList = ["Food", "Entertainment", "Utility", "Transport", "Movies", "Fitness", "Other"]
    
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
        
        // Add button to dismiss keyboard when editing TextView
        descriptionTextView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        
        // Add borders to text view
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.cornerRadius = 5
        
        // Assign self as delegate and data source to picker view
        tagPicker.delegate = self
        tagPicker.dataSource = self
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
            descriptionTextView.text = expense.expenseDescription
            payDatePicker.date = expense.date!
            paidSwitch.isOn = expense.isPaid
            remindSwitch.isOn = expense.isNotify
            
            if let pickerViewIndex = tagList.firstIndex(of: expense.tag!) {
                tagPicker.selectRow(pickerViewIndex, inComponent: 0, animated: true)
            }
        }
    }
    
    func initializeExpense() {
        expense = databaseController?.getChildContextExpense(expense: expense)
    }
    
    @IBAction func saveExpense(_ sender: Any) {
        guard let name = nameTextField.text, name != "", let amount = amountTextField.text, amount != "", let description = descriptionTextView.text, description != "" else {
            displayMessage(title: "Error", message: "Please do not leave any blank fields")
            return
        }

        // Set values for expense class
        expense!.name = name
        expense!.amount = (amount as NSString).floatValue
        expense!.expenseDescription = description
        expense!.date = payDatePicker.date
        expense!.tag = tagList[tagPicker.selectedRow(inComponent: 0)]
        
        if paidSwitch.isOn {
            // Remove from unpaid group if it was there previously
            databaseController?.removeExpenseFromGroup(expense: expense!, group: databaseController!.unpaidExpenseGroup)
            
            // Add to paid group
            databaseController?.addExpenseToGroup(expense: expense!, group: databaseController!.paidExpenseGroup)
            
            expense!.isPaid = true
        }
        else {
            // Remove from paid group if it was there previously
            databaseController?.removeExpenseFromGroup(expense: expense!, group: databaseController!.paidExpenseGroup)
            
            // Add to unpaid group
            databaseController?.addExpenseToGroup(expense: expense!, group: databaseController!.unpaidExpenseGroup)
            
            expense!.isPaid = false
        }
        
        expense!.isNotify = remindSwitch.isOn
        
        // If reminder is set, send notification at a later date
        if remindSwitch.isOn {
            self.sendNotification(expense: expense!)
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
    
    // MARK: - Picker View Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tagList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return tagList[row]
    }
    
    
    // MARK: - Send Notification Method
    func sendNotification(expense: Expense) {
        guard appDelegate.notificationsEnabled else {
            print("Notifications disabled")
            return
        }
        
        let content = UNMutableNotificationContent()
        
        content.title = "Payment Reminder"
        content.body = "Reminder to pay \(expense.name!) for $\(expense.amount) tomorrow"
        
        let triggerDate = Calendar.current.date(byAdding: .day, value: -1, to: expense.date!)
        let calendarTriggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate!)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: calendarTriggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: NOTIFICATION_IDENTIFIER, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
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
