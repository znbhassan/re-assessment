//
//  TaskDetailViewController.swift
//  ToDoList
//
//  Created by Zainab on 2/11/26.
//

import UIKit
import UserNotifications

class TaskDetailViewController: UITableViewController {
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var isCompleteButton: UIButton!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var dueDatePickerView: UIDatePicker!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var categorySegmentedControl: UISegmentedControl!
    @IBOutlet var reminderSwitch: UISwitch!
    
    var task: TaskItem?
    private var shareButton: UIBarButtonItem!
    
    var isDatePickerHidden = true
    let dateLabelIndexPath = IndexPath(row: 0, section: 1)
    let datePickerIndexPath = IndexPath(row: 1, section: 1)
    let notesIndexPath = IndexPath(row: 0, section: 2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let task = task {
            navigationItem.title = "Edit To-Do"
            titleTextField.text = task.title
            isCompleteButton.isSelected = task.isComplete
            dueDatePickerView.date = task.dueDate
            notesTextView.text = task.notes
            categorySegmentedControl.selectedSegmentIndex = categoryIndex(for: task.category)
            reminderSwitch.isOn = task.shouldRemind
        } else {
            dueDatePickerView.date = Date().addingTimeInterval(24*60*60)
            categorySegmentedControl.selectedSegmentIndex = categoryIndex(for: .personal)
            reminderSwitch.isOn = false
        }
        updateDueDateLabel(date: dueDatePickerView.date)
        dueDateLabel.textColor = .white
        dueDatePickerView.setValue(UIColor.white, forKeyPath: "textColor")
        updateSaveButtonState()
        configureShareButton()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        updateDueDateLabel(date: sender.date)
    }
    
    
    @IBAction func isCompleteButtonTapped(_ sender: UIButton) {
        isCompleteButton.isSelected.toggle()
    }
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }

    // Request notification permission when enabling reminders
    @IBAction func reminderSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                guard let self = self else { return }
                if !granted {
                    DispatchQueue.main.async {
                        sender.isOn = false
                        let alert = UIAlertController(title: "Notifications Disabled",
                                                      message: "Enable notifications in Settings to use reminders.",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func returnPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "saveUnwind" else { return }
        
        let title = titleTextField.text!
        let isComplete = isCompleteButton.isSelected
        let dueDate = dueDatePickerView.date
        let notes = notesTextView.text
        let category = categoryForSelectedSegment()
        let shouldRemind = reminderSwitch.isOn
        let notificationId = shouldRemind ? (task?.notificationId ?? UUID().uuidString) : nil
        
        if task != nil {
            task?.title = title
            task?.isComplete = isComplete
            task?.dueDate = dueDate
            task?.notes = notes
            task?.category = category
            task?.shouldRemind = shouldRemind
            task?.notificationId = notificationId
        } else {
            task = TaskItem(title: title, isComplete: isComplete, category: category, dueDate: dueDate, notes: notes)
            task?.shouldRemind = shouldRemind
            task?.notificationId = notificationId
        }
    }
    
    func updateDueDateLabel(date: Date) {
        dueDateLabel.text = TaskItem.dueDateFormatter.string(from: date)
    }
    
    func updateSaveButtonState() {
        let shouldEnableSaveButton = titleTextField.text?.isEmpty == false
        saveButton.isEnabled = shouldEnableSaveButton
        shareButton?.isEnabled = shouldEnableSaveButton
    }

    private func categoryForSelectedSegment() -> TaskCategory {
        switch categorySegmentedControl.selectedSegmentIndex {
        case 0:
            return .work
        case 1:
            return .personal
        default:
            return .personal
        }
    }

    private func categoryIndex(for category: TaskCategory) -> Int {
        switch category {
        case .work:
            return 0
        case .personal:
            return 1
        case .completed:
            return 1
        }
    }

    // Share task details via the system activity sheet
    private func configureShareButton() {
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTask))
        if let saveButton = saveButton {
            navigationItem.rightBarButtonItems = [shareButton, saveButton]
        } else {
            navigationItem.rightBarButtonItem = shareButton
        }
        let shouldEnableShareButton = titleTextField.text?.isEmpty == false
        shareButton.isEnabled = shouldEnableShareButton
    }

    @objc private func shareTask() {
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeTitle = (title?.isEmpty == false) ? title! : "Untitled To-Do"
        let dueDateText = TaskItem.dueDateFormatter.string(from: dueDatePickerView.date)
        let statusText = isCompleteButton.isSelected ? "Complete" : "Incomplete"
        let notes = notesTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        var body = "Task: \(safeTitle)\nStatus: \(statusText)\nDue: \(dueDateText)"
        if !notes.isEmpty {
            body += "\nNotes: \(notes)"
        }

        let activityVC = UIActivityViewController(activityItems: [body], applicationActivities: nil)
        activityVC.setValue("Task Details: \(safeTitle)", forKey: "subject")

        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = shareButton
        }
        present(activityVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case datePickerIndexPath where isDatePickerHidden == true:
            return 0
        case notesIndexPath:
            return 200
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt
       indexPath: IndexPath) {
        if indexPath == dateLabelIndexPath {
            isDatePickerHidden.toggle()
            dueDateLabel.textColor = .white
            updateDueDateLabel(date: dueDatePickerView.date)
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    
    // MARK: - Table view data source

    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
