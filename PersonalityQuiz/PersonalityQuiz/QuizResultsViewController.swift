//
//  QuizResultsViewController.swift
//  PersonalityQuiz
//
//  Created by Zainab on 2/11/26.
//

import UIKit

class QuizResultsViewController: UIViewController {

    @IBOutlet weak var resultAnswerLabel: UILabel!
    @IBOutlet weak var resultDefinitionLabel: UILabel!
    
    
    var responses: [Answer]!
    var quizTitle: String?
    var isTimedQuiz: Bool = false
    var timeLimitSeconds: Int?
    var elapsedSeconds: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Calculate and display the final result.
        let resultEmoji = calculatePersonalityResult()
        saveResult(resultEmoji: resultEmoji)
        navigationItem.hidesBackButton = true
        
    }
    
    func calculatePersonalityResult() -> String {
        // Aggregate the most common answer type.
        guard !responses.isEmpty else {
            resultAnswerLabel.text = "No result"
            resultDefinitionLabel.text = "You did not answer any questions."
            return "—"
        }

        var frequencyOfAnswers: [AnimalType: Int] = [:]
        let responseTypes = responses.map{ $0.type }
        
        for response in responseTypes {
            frequencyOfAnswers[response] = (frequencyOfAnswers[response] ?? 0) + 1
        }
        
        let frequentAnswersSorted = frequencyOfAnswers.sorted(by:
        {(pair1, pair2) -> Bool in
            return pair1.value > pair2.value
        })
        
        let mostCommonAnswer = frequentAnswersSorted.first!.key
        
        resultAnswerLabel.text = "You are a \(mostCommonAnswer.rawValue)!"
        resultDefinitionLabel.text = mostCommonAnswer.definition
        
        return String(mostCommonAnswer.rawValue)
    }

    private func saveResult(resultEmoji: String) {
        // Persist to local history so the recap screen can show it.
        let entry = QuizHistoryEntry(
            id: UUID(),
            date: Date(),
            quizTitle: quizTitle ?? "Personality Quiz",
            resultEmoji: resultEmoji,
            isTimed: isTimedQuiz,
            timeLimitSeconds: isTimedQuiz ? timeLimitSeconds : nil,
            elapsedSeconds: isTimedQuiz ? elapsedSeconds : nil
        )
        QuizHistoryStore.add(entry)
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
