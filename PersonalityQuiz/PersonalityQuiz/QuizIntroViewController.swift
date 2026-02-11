//
//  QuizIntroViewController.swift
//  PersonalityQuiz
//
//  Created by Zainab on 2/11/26.
//

import UIKit

class QuizIntroViewController: UIViewController {

    @IBOutlet weak var timedButton: UIButton!

    // Tracks the user's timed-quiz preference before starting.
    private var isTimedQuiz = false
    private let timeLimitSeconds = 10

    @IBAction func unwindToQuizIntroduction(segue: UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Keep the button label in sync with the current state.
        updateTimedButtonTitle()
    }

    @IBAction func toggleTimedQuiz(_ sender: UIButton) {
        isTimedQuiz.toggle()
        updateTimedButtonTitle()
    }

    private func updateTimedButtonTitle() {
        let stateText = isTimedQuiz ? "On" : "Off"
        timedButton.setTitle("Timed Quiz: \(stateText) (\(timeLimitSeconds)s/question)", for: .normal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController,
              let questionViewController = navigationController.viewControllers.first as? QuizQuestionViewController else {
            return
        }

        // Use the tapped button's tag to choose which quiz to run.
        let quizIndex = (sender as? UIButton)?.tag ?? 0
        let quiz = QuizBank.quiz(at: quizIndex)
        questionViewController.questions = quiz.questions
        questionViewController.quizTitle = quiz.title
        questionViewController.isTimedQuiz = isTimedQuiz
        questionViewController.timeLimitSeconds = timeLimitSeconds
    }

}
