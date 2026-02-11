//
//  QuizHistoryViewController.swift
//  PersonalityQuiz
//
//  Created by Zainab on 2/11/26.
//

import UIKit

class QuizHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel!

    private var entries: [QuizHistoryEntry] = []

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Basic table setup for the history list.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor(red: 0.0666666667, green: 0.0862745098, blue: 0.1137254902, alpha: 1)
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh entries every time the screen appears.
        entries = QuizHistoryStore.load()
        emptyStateLabel.isHidden = !entries.isEmpty
        tableView.reloadData()
    }

    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = entries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "HistoryCell")

        // Title + date on the first line.
        let dateText = dateFormatter.string(from: entry.date)
        cell.textLabel?.text = "\(entry.quizTitle) • \(dateText)"
        cell.textLabel?.textColor = UIColor(red: 0.9058823529, green: 0.9254901961, blue: 0.9490196078, alpha: 1)

        var detail = "Result: \(entry.resultEmoji)"
        if entry.isTimed {
            if let limit = entry.timeLimitSeconds {
                detail += " • Timed: \(limit)s/question"
            } else {
                detail += " • Timed"
            }
            if let elapsed = entry.elapsedSeconds {
                detail += " • Time: \(formatDuration(elapsed))"
            }
        }
        cell.detailTextLabel?.text = detail
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.textColor = UIColor(red: 0.662745098, green: 0.7019607843, blue: 0.7607843137, alpha: 1)
        cell.backgroundColor = UIColor(red: 0.1019607843, green: 0.1333333333, blue: 0.1882352941, alpha: 1)
        return cell
    }

    private func formatDuration(_ seconds: Double) -> String {
        let total = max(0, Int(round(seconds)))
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
