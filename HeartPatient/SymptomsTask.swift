//
//  SymptomsTask.swift
//  HeartPatient
//
//  Created by Juan Valladolid on 28/07/16.
//  Copyright © 2016 DTU. All rights reserved.
//

//
//  SymptomsTask.swift
//  HeartCare2016
//
//  Created by Juan Valladolid on 28/04/16.
//  Copyright © 2016 Valladolid. All rights reserved.
//


import ResearchKit

public class SymptomsTask: NSObject, ORKTask {
    
    let sleepStepID = "sleep_step"
    let symptomStepID = "symptom_step"
    let symptomPositionStepID = "symptomPosition_step"

    
    let summaryStepID = "summary_step"
    
    public var identifier: String { get { return "survey"} }
    
    public func stepBeforeStep(step: ORKStep?, withResult result: ORKTaskResult) -> ORKStep? {
        
        switch step?.identifier {
            
        case .Some(symptomPositionStepID):
            return stepWithIdentifier(symptomStepID)
            
        case .Some(sleepStepID):
            return stepWithIdentifier(symptomPositionStepID)
            
        
//        case .Some(sleepStepID):
//            return stepWithIdentifier(symptomStepID)
//            
//        case .Some(summaryStepID):
//            return stepWithIdentifier(sleepStepID)
      
            
        default:
            return nil
        }
    }
    
    public func stepAfterStep(step: ORKStep?, withResult result: ORKTaskResult) -> ORKStep? {
        
        switch step?.identifier {
        case .None:
            return stepWithIdentifier(symptomStepID)
            
            
        case .Some(symptomStepID):
            return stepWithIdentifier(symptomPositionStepID)
            
        case .Some(symptomPositionStepID):
            return stepWithIdentifier(sleepStepID)
 
        default:
            return nil
        }
    }
    
    public func stepWithIdentifier(identifier: String) -> ORKStep? {
        switch identifier {
            
        case symptomStepID:
            //1
            
            let textChoice = [ ORKTextChoice(text: "Shortness of Breath", detailText: "Breathlessness during activity", value: 1,exclusive: false),
                               ORKTextChoice(text: "Lack of apetite or Nausea", detailText: "A feeling of being full or sick to the stomach", value: 2, exclusive: false),
                               ORKTextChoice(text: "Dizziness", detailText: "Especially when standing up quickly", value: 3, exclusive: false),
                               ORKTextChoice(text: "Fatigue & Tiredness", detailText: "A tired feeling and difficulty with everyday activities", value: 4, exclusive: false),
                               ORKTextChoice(text: "No symptoms", detailText: nil, value: 5, exclusive: true) ]
            
            
            
            
            //2
            let answerFormat4 = ORKNumericAnswerFormat.choiceAnswerFormatWithStyle(ORKChoiceAnswerStyle.MultipleChoice, textChoices: textChoice)
            
            let symptomsNew = ORKQuestionStep(identifier: "symptom_step", title: "Which symptoms do you feel?", answer: answerFormat4)
            
            symptomsNew.optional = false
            return symptomsNew
            
        case symptomPositionStepID:
            let symptomPositionStepTitle = "When did you experience the symptoms?"
            
            
            let textChoice = [ ORKTextChoice(text: "Running (High Effort)", detailText: nil, value: 1,exclusive: false),
                               ORKTextChoice(text: "Walking or up stairs (Moderate Effort)", detailText: nil, value: 2, exclusive: false),
                               ORKTextChoice(text: "Standing or very short moves (Low Effort)", detailText: nil, value: 3, exclusive: false),
                               ORKTextChoice(text: "At Rest or sitting down (Dyspnea)", detailText: nil, value: 4, exclusive: false),
                               ORKTextChoice(text: "None of above", detailText: nil, value: 5, exclusive: true) ]
            
            
            let answerFormat = ORKNumericAnswerFormat.choiceAnswerFormatWithStyle(ORKChoiceAnswerStyle.MultipleChoice, textChoices: textChoice)
            
            
            let symptomPosition = ORKQuestionStep(identifier: symptomPositionStepID, title: symptomPositionStepTitle, text: "Choose one or many contexts when you have experienced symptoms", answer: answerFormat)
            
            
            // "Skip value" = false
            symptomPosition.optional = false
            
            return symptomPosition
        
            
        case sleepStepID:
            let sleepStepTitle = "How did you sleep last night?"
            
            
            let sleepImagesType = [ ORKImageChoice(normalImage: UIImage(named: "sleep-horizontal"), selectedImage: UIImage(named: "sleep-horizontal-select"), text: "Comfortable sleeping: Flat position", value: "flat"),
                                    ORKImageChoice(normalImage: UIImage(named: "sleep-vertical"), selectedImage: UIImage(named: "sleep-vertical-select"), text: "Trouble sleeping: Up-right position", value: "vertical")
            ]
            
            
            let sleepFormatAnswer: ORKImageChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormatWithImageChoices(sleepImagesType)
            
            
            let sleepNew = ORKQuestionStep(identifier: sleepStepID, title: sleepStepTitle, text: "Choose a Position ", answer: sleepFormatAnswer)
        
            
            // "Skip value" = false
            sleepNew.optional = false
            
            return sleepNew
            
            
            
            
        case summaryStepID:
            let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
            summaryStep.title = "Good job!"
            summaryStep.text = "However, if you have more than 3 symptoms and difficulties in breathing while laying down, please contact your nurse to revise your medicine"
            return summaryStep
            
        default:
            return nil
        }
        
    }
    
    
    
}

extension TimeLineTableViewController {
    func processSurveyResults(taskResult: ORKTaskResult?)
    {
        
        if let taskResultValue = taskResult
        {
            print("Task Run UUID : " + taskResultValue.taskRunUUID.UUIDString)
            print("Survey started at : \(taskResultValue.startDate!)     Ended at : \(taskResultValue.endDate!)")
            
            
            if let question1Result = taskResultValue.stepResultForStepIdentifier("sleep_step")?.results?.first as? ORKChoiceQuestionResult
            {
                if question1Result.choiceAnswers != nil
                {
                    print("Answer to question 2 is \(question1Result.choiceAnswers!)")
                }
                else
                {
                    print("question 2 was skipped")
                }
            }
        }
    }
}
