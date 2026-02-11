//
//  TaskListViewController.swift
//  ToDoList
//
//  Created by Zainab on 2/11/26.
//

import UIKit
import UserNotifications

class TaskListViewController: UITableViewController, TaskCellDelegate
{
    var tasks = [TaskItem]()
    private var filteredTasks = [TaskItem]()
    let searchController = UISearchController(searchResultsController: nil)
    private let categoryOrder: [TaskCategory] = [.work, .personal, .completed]
    
    private enum CategoryFilter: Int, CaseIterable {
        case all
        case work
        case personal
        case completed
        
        var title: String {
            switch self {
            case .all:
                return "All"
            case .work:
                return "Work"
            case .personal:
                return "Personal"
            case .completed:
                return "Completed"
            }
        }
        
        var category: TaskCategory? {
            switch self {
            case .all:
                return nil
            case .work:
                return .work
            case .personal:
                return .personal
            case .completed:
                return .completed
            }
        }
    }
    
    private lazy var categorySegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: CategoryFilter.allCases.map { $0.title })
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(categoryFilterChanged), for: .valueChanged)
        return control
    }()
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        setupSearchBar()
        setupCategoryFilter()
        if let savedTasks = TaskItem.loadTasks() {
            tasks = savedTasks
        } else {
            tasks = TaskItem.loadSampleTasks()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCategoryHeaderLayout()
    }
    
    @IBAction func unwindToTaskList(segue: UIStoryboardSegue) {
        
        guard segue.identifier == "saveUnwind" else { return }
        let sourceViewController = segue.source as! TaskDetailViewController

        if let task = sourceViewController.task {
            if let indexOfExistingTask = tasks.firstIndex(of: task) {
                tasks[indexOfExistingTask] = task
            } else {
                tasks.append(task)
            }
            updateReminder(for: task)
        }
        TaskItem.saveTasks(tasks)
        tableView.reloadData()
    }
    
    @IBSegueAction func editTask(_ coder: NSCoder, sender: Any?) -> TaskDetailViewController? {
        guard let cell = sender as? UITableViewCell, let indexPath =
                tableView.indexPath(for: cell) else {
            return nil
        }
        let task = taskForIndexPath(indexPath)
        
        tableView.deselectRow(at: indexPath, animated: true)
        let detailController = TaskDetailViewController(coder: coder)
        detailController?.task = task
        return detailController
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search title or notes"
        definesPresentationContext = true
    }

    // Category filter header shown above the list
    private func setupCategoryFilter() {
        let headerHeight: CGFloat = 44
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight))
        categorySegmentedControl.frame = headerView.bounds.insetBy(dx: 16, dy: 6)
        categorySegmentedControl.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        headerView.addSubview(categorySegmentedControl)
        tableView.tableHeaderView = headerView
    }
    
    private func updateCategoryHeaderLayout() {
        guard let headerView = tableView.tableHeaderView else { return }
        if headerView.frame.width != tableView.bounds.width {
            headerView.frame.size.width = tableView.bounds.width
            categorySegmentedControl.frame = headerView.bounds.insetBy(dx: 16, dy: 6)
            tableView.tableHeaderView = headerView
        }
    }
    
    func checkmarkTapped(sender: TaskCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            let selectedTodo = taskForIndexPath(indexPath)
            guard let todoIndex = tasks.firstIndex(of: selectedTodo) else { return }
            var task = tasks[todoIndex]
            task.isComplete.toggle()
            tasks[todoIndex] = task
            updateReminder(for: task)
            tableView.reloadData()
        }
        TaskItem.saveTasks(tasks)
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedTodo = taskForIndexPath(indexPath)
            if let todoIndex = tasks.firstIndex(of: selectedTodo) {
                cancelReminder(for: tasks[todoIndex])
                tasks.remove(at: todoIndex)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            TaskItem.saveTasks(tasks)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksForSection(section).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCellIdentifier", for: indexPath) as! TaskCell
        
        let task = taskForIndexPath(indexPath)
        
        cell.delegate = self
        cell.titleLabel?.text = task.title
        cell.isCompleteButton.isSelected = task.isComplete
        cell.tagLabel.text = task.tagCategory.title
        cell.tagLabel.backgroundColor = task.tagCategory.color
        cell.tagLabel.textColor = task.tagCategory.textColor
        applyDueDateHighlight(to: cell, task: task)
        
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if selectedCategoryFilter == .all {
            return categoryOrder.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if selectedCategoryFilter == .all {
            return categoryOrder[section].title
        }
        return selectedCategoryFilter.title
    }
    
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

extension TaskListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterContentForSearchText("")
    }
}

extension TaskListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }
}

private extension TaskListViewController {
    private var selectedCategoryFilter: CategoryFilter {
        return CategoryFilter(rawValue: categorySegmentedControl.selectedSegmentIndex) ?? .all
    }
    
    func filterContentForSearchText(_ searchText: String) {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let terms = trimmed.split(separator: " ").map(String.init)
        
        if terms.isEmpty {
            filteredTasks = []
        } else {
            filteredTasks = tasks.filter { task in
                let notes = task.notes ?? ""
                let haystack = "\(task.title) \(notes)".lowercased()
                return terms.allSatisfy { haystack.contains($0) }
            }
        }
        tableView.reloadData()
    }
    
    func tasksForSection(_ section: Int) -> [TaskItem] {
        let baseTodos = isFiltering ? filteredTasks : tasks
        if selectedCategoryFilter == .all {
            let category = categoryOrder[section]
            return baseTodos.filter { $0.tagCategory == category }
        }
        if let category = selectedCategoryFilter.category {
            return baseTodos.filter { $0.tagCategory == category }
        }
        return baseTodos
    }
    
    func taskForIndexPath(_ indexPath: IndexPath) -> TaskItem {
        return tasksForSection(indexPath.section)[indexPath.row]
    }
    
    @objc func categoryFilterChanged() {
        tableView.reloadData()
    }

    // Visual cues for overdue or soon-due tasks
    func applyDueDateHighlight(to cell: TaskCell, task: TaskItem) {
        cell.contentView.backgroundColor = .clear
        cell.titleLabel.textColor = .white
        
        guard !task.isComplete else { return }
        
        let now = Date()
        if task.dueDate < now {
            cell.contentView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.12)
            cell.titleLabel.textColor = .systemRed
        } else if task.dueDate < now.addingTimeInterval(24 * 60 * 60) {
            cell.contentView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.12)
            cell.titleLabel.textColor = .systemOrange
        }
    }

    // Keep notifications in sync with task state
    func updateReminder(for task: TaskItem) {
        if task.shouldRemind && !task.isComplete {
            scheduleReminder(for: task)
        } else {
            cancelReminder(for: task)
        }
    }

    func scheduleReminder(for task: TaskItem) {
        guard task.shouldRemind,
              !task.isComplete,
              let notificationId = task.notificationId,
              task.dueDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder(for task: TaskItem) {
        guard let notificationId = task.notificationId else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
    }
}
