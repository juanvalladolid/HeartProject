//
//  Symptoms.swift
//  HeartPatient
//
//  Created by Juan Valladolid on 02/08/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import Foundation

import ResearchKit

extension TimeLineTableViewController
{
    func showSurvey2()
    {
        // Symptoms
        let symptomsChoice = [ ORKTextChoice(text: "Shortness of Breath", detailText: "Breathlessness during activity", value: 1,exclusive: false),
                               ORKTextChoice(text: "Lack of apetite or Nausea", detailText: "A feeling of being full or sick to the stomach", value: 2, exclusive: false),
                               ORKTextChoice(text: "Dizziness", detailText: "Especially when standing up quickly", value: 3, exclusive: false),
                               ORKTextChoice(text: "Fatigue & Tiredness", detailText: "A tired feeling and difficulty with everyday activities", value: 4, exclusive: false),
                               ORKTextChoice(text: "No symptoms", detailText: nil, value: 5, exclusive: true) ]
        
        let symptomsFormat = ORKNumericAnswerFormat.choiceAnswerFormatWithStyle(ORKChoiceAnswerStyle.MultipleChoice, textChoices: symptomsChoice)
        let symptoms = ORKQuestionStep(identifier: "symptom_step", title: "Which symptoms do you feel?", answer: symptomsFormat)
        symptoms.optional = false
        
        
        // Symptoms Context
        let symptomsContextChoice = [ ORKTextChoice(text: "Running (High Effort)", detailText: nil, value: 1,exclusive: false),
                                      ORKTextChoice(text: "Walking or up stairs (Moderate Effort)", detailText: nil, value: 2, exclusive: false),
                                      ORKTextChoice(text: "Standing or very short moves (Low Effort)", detailText: nil, value: 3, exclusive: false),
                                      ORKTextChoice(text: "At Rest or sitting down (Dyspnea)", detailText: nil, value: 4, exclusive: false),
                                      ORKTextChoice(text: "None of above", detailText: nil, value: 5, exclusive: true) ]
        
        let answerFormat = ORKNumericAnswerFormat.choiceAnswerFormatWithStyle(ORKChoiceAnswerStyle.MultipleChoice, textChoices: symptomsContextChoice)
        let symptomPosition = ORKQuestionStep(identifier: "symptom_context", title: "When did you experience the symptoms?", text: "Choose one or many contexts when you have experienced symptoms", answer: answerFormat)
        symptomPosition.optional = false
        
        
        // Sleep Position
        let sleepImagesType = [ ORKImageChoice(normalImage: UIImage(named: "sleep-horizontal"), selectedImage: UIImage(named: "sleep-horizontal-select"), text: "Comfortable sleeping: Flat position", value: "flat"),
                                ORKImageChoice(normalImage: UIImage(named: "sleep-vertical"), selectedImage: UIImage(named: "sleep-vertical-select"), text: "Trouble sleeping: Up-right position", value: "vertical")
        ]
        let sleepFormatAnswer: ORKImageChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormatWithImageChoices(sleepImagesType)
        let sleepPosition = ORKQuestionStep(identifier: "sleep_step", title: "How did you sleep last night?", text: "Choose a Position ", answer: sleepFormatAnswer)
        sleepPosition.optional = false
        
        
        
        // Test
        let step = ORKFormStep(identifier: "sleep_test", title: "Title", text: "detailed text")
        
        
        let sleepImages1 = [ ORKImageChoice(normalImage: UIImage(named: "sleep-horizontal"), selectedImage: UIImage(named: "sleep-horizontal-select"), text: "Comfortable sleeping: Flat position", value: "flat"),
                             ORKImageChoice(normalImage: UIImage(named: "sleep-vertical"), selectedImage: UIImage(named: "sleep-vertical-select"), text: "Trouble sleeping: Up-right position", value: "vertical")
        ]
        
        //let sleepFormatAnswer: ORKImageChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormatWithImageChoices(sleepImagesType)
        //let sleepNew = ORKQuestionStep(identifier: sleepStepID2, title: sleepStepTitle, text: "Choose a Position ", answer: sleepFormatAnswer)
        let sleepTest1 = ORKFormItem(identifier: "sleep1", text: "testing", answerFormat: ORKAnswerFormat.choiceAnswerFormatWithImageChoices(sleepImages1))
        
        let sleepImages2 = [ ORKImageChoice(normalImage: UIImage(named: "sleep-horizontal"), selectedImage: UIImage(named: "sleep-horizontal-select"), text: "Comfortable sleeping: Flat position", value: "flat"),
                             ORKImageChoice(normalImage: UIImage(named: "sleep-vertical"), selectedImage: UIImage(named: "sleep-vertical-select"), text: "Trouble sleeping: Up-right position", value: "vertical")
        ]
        
        let sleepTest2 = ORKFormItem(identifier: "sleep2", text: "testing2", answerFormat: ORKAnswerFormat.choiceAnswerFormatWithImageChoices(sleepImages2))
        //let sleepFormatAnswer2: ORKImageChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormatWithImageChoices(sleepImagesType2)
        //let sleepNew2 = ORKQuestionStep(identifier: sleepStepID2, title: sleepStepTitle2, text: "Choose a Position ", answer: sleepFormatAnswer2)
        
        step.formItems = [sleepTest1, sleepTest2]
        step.optional = false
        
        
        
        let task = ORKOrderedTask(identifier: "Survey", steps: [symptoms, symptomPosition, sleepPosition, step])
        
        let taskViewController = ORKTaskViewController(task: task, taskRunUUID: nil)
        taskViewController.delegate = self
        presentViewController(taskViewController, animated: true, completion: nil)
    }
}