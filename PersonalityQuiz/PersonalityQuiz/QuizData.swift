//
//  QuizData.swift
//  PersonalityQuiz
//
//  Created by Zainab on 2/11/26.
//

import Foundation

struct Question {
    var text: String
    var type: ResponseType
    var answers: [Answer]
}

struct Quiz {
    var title: String
    var questions: [Question]
}

enum QuizBank {
    static let all: [Quiz] = [
        Quiz(
            title: "Classic Animal Quiz",
            questions: [
                Question(text: "Which food do you like the most?",
                         type: .single,
                         answers: [
                            Answer(text: "Steak", type: .dog),
                            Answer(text: "Fish", type: .cat),
                            Answer(text: "Carrots", type: .rabbit),
                            Answer(text: "Corn", type: .turtle)
                    ]),
                Question(text: "Which activities do you enjoy?",
                         type: .multiple,
                         answers: [
                            Answer(text: "Swimming", type: .turtle),
                            Answer(text: "Sleeping", type: .cat),
                            Answer(text: "Cuddling", type: .rabbit),
                            Answer(text: "Eating", type: .dog)
                    ]),
                Question(text: "How much do you enjoy car rides?",
                         type: .ranged,
                         answers: [
                            Answer(text: "I dislike them", type: .cat),
                            Answer(text: "I get a little nervous", type: .rabbit),
                            Answer(text: "I barely notice them", type: .turtle),
                            Answer(text: "I love them", type: .dog)
                    ]),
            ]
        ),
        Quiz(
            title: "Adventure Animal Quiz",
            questions: [
                Question(text: "Your ideal morning is...",
                         type: .single,
                         answers: [
                            Answer(text: "A sunrise hike", type: .dog),
                            Answer(text: "A slow, quiet start", type: .cat),
                            Answer(text: "Coffee and journaling", type: .rabbit),
                            Answer(text: "A calm walk by water", type: .turtle)
                    ]),
                Question(text: "Pick the activities you'd enjoy on a day off.",
                         type: .multiple,
                         answers: [
                            Answer(text: "Trying a new sport", type: .dog),
                            Answer(text: "Watching a documentary", type: .turtle),
                            Answer(text: "Baking something sweet", type: .rabbit),
                            Answer(text: "Taking a long nap", type: .cat)
                    ]),
                Question(text: "How much do you like trying new foods?",
                         type: .ranged,
                         answers: [
                            Answer(text: "Not much", type: .cat),
                            Answer(text: "Only sometimes", type: .rabbit),
                            Answer(text: "I usually do", type: .turtle),
                            Answer(text: "Love it", type: .dog)
                    ]),
            ]
        ),
        Quiz(
            title: "Cozy Animal Quiz",
            questions: [
                Question(text: "Pick a cozy spot to relax.",
                         type: .single,
                         answers: [
                            Answer(text: "Couch with a blanket", type: .cat),
                            Answer(text: "Sunny window seat", type: .rabbit),
                            Answer(text: "Porch with a view", type: .turtle),
                            Answer(text: "Living room with friends", type: .dog)
                    ]),
                Question(text: "Which traits describe you?",
                         type: .multiple,
                         answers: [
                            Answer(text: "Loyal", type: .dog),
                            Answer(text: "Independent", type: .cat),
                            Answer(text: "Gentle", type: .rabbit),
                            Answer(text: "Thoughtful", type: .turtle)
                    ]),
                Question(text: "How much do you like planning ahead?",
                         type: .ranged,
                         answers: [
                            Answer(text: "Not at all", type: .cat),
                            Answer(text: "A little", type: .rabbit),
                            Answer(text: "Usually", type: .turtle),
                            Answer(text: "Always", type: .dog)
                    ]),
            ]
        )
    ]

    static func quiz(at index: Int) -> Quiz {
        if index >= 0 && index < all.count {
            return all[index]
        }
        return all[0]
    }

    static func shuffledQuestions(_ questions: [Question]) -> [Question] {
        return questions.shuffled().map { question in
            switch question.type {
            case .single, .multiple:
                var shuffledQuestion = question
                shuffledQuestion.answers = question.answers.shuffled()
                return shuffledQuestion
            case .ranged:
                return question
            }
        }
    }
}

enum ResponseType {
    case single, multiple, ranged
}

struct Answer {
    var text: String
    var type: AnimalType
}

enum AnimalType: Character {
    case dog = "🐶", cat = "🐱", rabbit = "🐰", turtle = "🐢"
    
    var definition: String {
        switch self {
        case .dog:
            return "You are incredibly outgoing. You surround yourself with the people you love and enjoy activities with your friends."
        case .cat:
            return "Mischievous, yet mild-tempered, you enjoy doing things on your own terms."
        case .rabbit:
            return "You love everything that's soft. You are healthy and full of energy."
        case .turtle:
            return "You are wise beyond your years, and you focus on the details. Slow and steady wins the race."
        }
    }
    
}
