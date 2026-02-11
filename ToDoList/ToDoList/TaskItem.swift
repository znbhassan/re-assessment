//
//  TaskItem.swift
//  ToDoList
//
//  Created by Zainab on 2/11/26.
//

import Foundation
import UIKit

enum TaskCategory: String, Codable, CaseIterable {
    case work
    case personal
    case completed
    
    var title: String {
        switch self {
        case .work:
            return "Work"
        case .personal:
            return "Personal"
        case .completed:
            return "Completed"
        }
    }
    
    var color: UIColor {
        switch self {
        case .work:
            return UIColor(red: 0.96, green: 0.77, blue: 0.75, alpha: 1.0)
        case .personal:
            return UIColor(red: 0.80, green: 0.90, blue: 0.98, alpha: 1.0)
        case .completed:
            return UIColor(red: 0.80, green: 0.94, blue: 0.84, alpha: 1.0)
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .completed:
            return UIColor(red: 0.16, green: 0.46, blue: 0.27, alpha: 1.0)
        case .work:
            return UIColor(red: 0.45, green: 0.20, blue: 0.18, alpha: 1.0)
        case .personal:
            return UIColor(red: 0.16, green: 0.30, blue: 0.52, alpha: 1.0)
        }
    }
}

struct TaskItem: Equatable, Codable {
    var id = UUID()
    var title: String
    var isComplete: Bool
    var category: TaskCategory
    var dueDate: Date
    var notes: String?
    var shouldRemind: Bool = false
    var notificationId: String?
    
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
       in: .userDomainMask).first!
    
    static let archiveURL = documentsDirectory.appendingPathComponent("tasks").appendingPathExtension("plist")
    
    static func ==(lhs: TaskItem, rhs: TaskItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func loadTasks() -> [TaskItem]?  {
        guard let codedTasks = try? Data(contentsOf: archiveURL) else { return nil }
        
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode(Array<TaskItem>.self,
           from: codedTasks)
    }
    
    static func saveTasks(_ tasks: [TaskItem]) {
        let propertyListEncoder = PropertyListEncoder()
        let codedTasks = try? propertyListEncoder.encode(tasks)
        try? codedTasks?.write(to: archiveURL, options: .noFileProtection)
    }
    
    static func loadSampleTasks() -> [TaskItem] {
        let task1 = TaskItem(title: "Task One", isComplete: false, category: .work,
           dueDate: Date(), notes: "Notes 1")
        let task2 = TaskItem(title: "Task Two", isComplete: false, category: .personal,
           dueDate: Date(), notes: "Notes 2")
        let task3 = TaskItem(title: "Task Three", isComplete: false, category: .work,
           dueDate: Date(), notes: "Notes 3")
    
        return [task1, task2, task3]
    }
    
    static let dueDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var tagCategory: TaskCategory {
        return isComplete ? .completed : category
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case isComplete
        case category
        case dueDate
        case notes
        case shouldRemind
        case notificationId
    }
    
    init(id: UUID = UUID(), title: String, isComplete: Bool, category: TaskCategory, dueDate: Date, notes: String?) {
        self.id = id
        self.title = title
        self.isComplete = isComplete
        self.category = category
        self.dueDate = dueDate
        self.notes = notes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        isComplete = try container.decode(Bool.self, forKey: .isComplete)
        category = try container.decodeIfPresent(TaskCategory.self, forKey: .category) ?? .personal
        dueDate = try container.decode(Date.self, forKey: .dueDate)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        shouldRemind = try container.decodeIfPresent(Bool.self, forKey: .shouldRemind) ?? false
        notificationId = try container.decodeIfPresent(String.self, forKey: .notificationId)
    }
}
