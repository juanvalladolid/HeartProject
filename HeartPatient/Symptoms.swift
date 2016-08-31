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
    func showSurvey()
    {
        
        // TASK - PART 1
        // Symptoms part 1
        let symptomsOne = ORKFormStep(identifier: "symptoms_part1",
                                      title: "Symptoms (Part 1)",
                                      text: nil)
        let symptomsImages1 = [
            ORKImageChoice(normalImage: UIImage(named: "ShortBreath"),
                selectedImage: UIImage(named: "ShortBreath-selected"),
                text: "Shortness of Breath", value: "ShortOfBreath"),
            
            ORKImageChoice(normalImage: UIImage(named: "Fatigue"),
                selectedImage: UIImage(named: "Fatigue-selected"),
                text: "Fatigue & Tiredness", value: "FatigueAndTiredness"),
            
            ORKImageChoice(normalImage: UIImage(named: "NoSymptoms"),
                selectedImage: UIImage(named: "NoSymptoms-selected"),
                text: "None of these symptoms, please go Next",
                value: "No-ShortOfBreath-Fatigue") ]
        
  
        let symptomsPart1 = ORKFormItem(
            identifier: "symptoms1",
            text: "Which of these symptoms do you feel? ",
            answerFormat: ORKAnswerFormat.choiceAnswerFormatWithImageChoices(symptomsImages1))
        
        
        // Symptoms Context
        let symptomsContextChoice = [ ORKImageChoice(normalImage: UIImage(named: "hard-effort"), selectedImage: UIImage(named: "hard-effort-selected"), text: "Running (Hard Effort)", value: "Running"),
                                      ORKImageChoice(normalImage: UIImage(named: "moderate-effort"), selectedImage: UIImage(named: "moderate-effort-selected"), text: "Walking or up the stairs (Moderate Effort)", value: "Walking"),
                                      ORKImageChoice(normalImage: UIImage(named: "low-effort"), selectedImage: UIImage(named: "low-effort-selected"), text: "Standing or daily routine activites (Low Effort)", value: "Standing"),
                                      ORKImageChoice(normalImage: UIImage(named: "rest"), selectedImage: UIImage(named: "rest-selected"), text: "Sitting down or Resting", value: "Resting")
//                                      ORKImageChoice(normalImage: UIImage(named: "none-effort"), selectedImage: UIImage(named: "none-effort-selected"), text: "None", value: "None")
        ]
 
        let symptomsContext1 = ORKFormItem(identifier: "symptomsContext", text: "In which context did you have the symptom: ", answerFormat: ORKAnswerFormat.choiceAnswerFormatWithImageChoices(symptomsContextChoice))
        
        
        symptomsOne.formItems = [symptomsPart1, symptomsContext1]
        symptomsOne.optional = false
        
        
        // TASK - PART 2:
        
        let symptomsTwo = ORKFormStep(identifier: "symptoms_part2", title: "Symptoms (Part 2)", text: nil)
        
        let symptomsImages2 = [ ORKImageChoice(normalImage: UIImage(named: "Nausea"), selectedImage: UIImage(named: "Nausea-selected"), text: "Nausea or Loss of apetite", value: "Nausea"),
                                ORKImageChoice(normalImage: UIImage(named: "Dizziness"), selectedImage: UIImage(named: "Dizziness-selected"), text: "Dizziness", value: "Dizziness"),
                                ORKImageChoice(normalImage: UIImage(named: "NoSymptoms"), selectedImage: UIImage(named: "NoSymptoms-selected"), text: "None of these symptoms, please go next", value: "No-Nausea-Dizziness") ]
        
        let symptomsPart2 = ORKFormItem(identifier: "symptoms2", text: "Which of these symptoms do you feel?", answerFormat: ORKAnswerFormat.choiceAnswerFormatWithImageChoices(symptomsImages2))

        
        let symptomsFrequencyChoice = [ ORKImageChoice(normalImage: UIImage(named: "frequently"), selectedImage: UIImage(named: "frequently-selected"), text: "Frequent", value: "Frequent"),
                                        ORKImageChoice(normalImage: UIImage(named: "sometimes"), selectedImage: UIImage(named: "sometimes-selected"), text: "Sometimes", value: "Sometimes"),
                                        ORKImageChoice(normalImage: UIImage(named: "rare"), selectedImage: UIImage(named: "rare-selected"), text: "Rare", value: "Rare")]
            
            
         let symptomsFrequency = ORKFormItem(identifier: "symptomsFrequency", text: "How often during a day: ", answerFormat: ORKAnswerFormat.choiceAnswerFormatWithImageChoices(symptomsFrequencyChoice))
        
        symptomsTwo.formItems = [symptomsPart2, symptomsFrequency]
        symptomsTwo.optional = false
        
       
        // TASK - PART 3: Coughing
        
        let symptomsThree = ORKFormStep(identifier: "symptoms_part3", title: "Symptoms (Part 3)", text: nil)
        
        let symptomsImages3 = [ ORKImageChoice(normalImage: UIImage(named: "Coughing"), selectedImage: UIImage(named: "Coughing-selected"), text: "Dry Coughing", value: "Coughing-dry"),
                                ORKImageChoice(normalImage: UIImage(named: "Coughing-sputum"), selectedImage: UIImage(named: "Coughing-sputum-selected"), text: "Frothy sputum Coughing", value: "Coughing-sputum"),
                                ORKImageChoice(normalImage: UIImage(named: "NoSymptoms"), selectedImage: UIImage(named: "NoSymptoms-selected"), text: "None of these symptoms, please go next", value: "No-Cough") ]
        
        let symptomsPart3 = ORKFormItem(identifier: "symptoms3", text: "Do you have a dry or a frotty sputum cough?", answerFormat: ORKAnswerFormat.choiceAnswerFormatWithImageChoices(symptomsImages3))
        
        
        
        symptomsThree.formItems = [symptomsPart3]
        symptomsThree.optional = false
        
        
        
        
        // TASK - PART 4: Swelling body
        
        let symptomsFour = ORKFormStep(identifier: "symptoms_part4", title: "Symptoms (Part 4)", text: nil)
        
        let symptomsImages4 = [ ORKImageChoice(normalImage: UIImage(named: "swollen-legs"), selectedImage: UIImage(named: "swollen-legs-selected"), text: "Swelling in legs, feet, or ankles ", value: "Swollen-legs"),
                                ORKImageChoice(normalImage: UIImage(named: "swollen-abdomen"), selectedImage: UIImage(named: "swollen-abdomen-selected"), text: "Swelling in the abdomen", value: "Swollen-abdomen"),
                                ORKImageChoice(normalImage: UIImage(named: "swollen-hands"), selectedImage: UIImage(named: "swollen-hands-selected"), text: "Swelling in hands or arms", value: "Swollen-hands"),
                                ORKImageChoice(normalImage: UIImage(named: "swollen-face"), selectedImage: UIImage(named: "swollen-face-selected"), text: "Swelling in face", value: "Swollen-face"),
                                ORKImageChoice(normalImage: UIImage(named: "NoSymptoms"), selectedImage: UIImage(named: "NoSymptoms-selected"), text: "None of these symptoms, please go next", value: "No-Swollen")]
        
        let symptomsPart4 = ORKFormItem(identifier: "symptoms4", text: "Is any part of your body swollen?", answerFormat: ORKAnswerFormat.choiceAnswerFormatWithImageChoices(symptomsImages4))
        
        
        
        symptomsFour.formItems = [symptomsPart4]
        symptomsFour.optional = false
        
        
        
        // TASK - PART 5: Sleep Position
        
        let symptomsFive = ORKFormStep(identifier: "symptoms_part5", title: "Symptoms (part 5)", text: nil)

        
        let sleepImagesType = [ ORKImageChoice(normalImage: UIImage(named: "sleep-horizontal"), selectedImage: UIImage(named: "sleep-horizontal-select"), text: "Comfortable sleeping: Flat position", value: "flat"),
                                ORKImageChoice(normalImage: UIImage(named: "sleep-vertical"), selectedImage: UIImage(named: "sleep-vertical-select"), text: "Trouble sleeping: Up-right position", value: "vertical")
        ]
        let sleepFormatAnswer: ORKImageChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormatWithImageChoices(sleepImagesType)
        
        let sleepPosition = ORKFormItem(identifier: "symptoms5", text: "Which position did you sleep yesterday in?", answerFormat: sleepFormatAnswer)
        //let sleepPosition = ORKQuestionStep(identifier: "sleep_step", title: "How did you sleep last night?", text: "Choose a Position ", answer: sleepFormatAnswer)
        
        symptomsFive.formItems = [sleepPosition]
        symptomsFive.optional = false

        
        
        
        
        let task = ORKOrderedTask(identifier: "Symptoms", steps: [symptomsOne, symptomsTwo, symptomsThree, symptomsFour, symptomsFive])
        
        let taskViewController = ORKTaskViewController(task: task, taskRunUUID: nil)
        taskViewController.delegate = self
        presentViewController(taskViewController, animated: true, completion: nil)
    }
}