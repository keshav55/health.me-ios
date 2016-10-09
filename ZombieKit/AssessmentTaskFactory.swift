/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import ResearchKit

struct AssessmentTaskFactory {
    
    
    
  static func makePulseAssessmentTask() -> ORKTask {
    let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    let unit = HKUnit(from: "count/min")
    let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .integer)
    
    // Create a question.
    let title = "Measure the number of beats per minute."
    let text = "Place two fingers on your wrist and count how many beats you feel in 15 seconds.  Multiply this number by 4."
    let questionStep = ORKQuestionStep(identifier: "PulseStep", title: title, text: text, answer: answerFormat)
    questionStep.isOptional = false
    
    // Create an ordered task with a single question
    return ORKOrderedTask(identifier: "PulseTask", steps: [questionStep])
  }
    
    static func makeBiotinAssessmentTask() -> ORKTask {
        
        let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryBiotin)!
        let unit = HKUnit(from: "mcg")
        let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .decimal)
        
        // Create a question.
        let title = "Input Biotin Count"
        let text = "Biotin is critical towards reduction of anxiety."
        let questionStep = ORKQuestionStep(identifier: "BiotinStep", title: title, text: text, answer: answerFormat)
        questionStep.isOptional = false
        
        // Create an ordered task with a single question
        return ORKOrderedTask(identifier: "BiotinTask", steps: [questionStep])
    }
    
    static func makeMoodAssessmentTask() -> ORKTask {
        
        
        let question = NSLocalizedString("On a scale from 1 to 10, how would you rate your mood today?", comment: "")
        let maximumValueDescription = NSLocalizedString("Good", comment: "")
        let minimumValueDescription = NSLocalizedString("Bad", comment: "")
        
//        let answerFormat = ORKScaleAnswerFormat(
//            maximumValue: 10,
//            minimumValue: 1,
//            defaultValue: -1,
//            step: 1,
//            vertical: false,
//            maximumValueDescription: maximumValueDescription,
//            minimumValueDescription: minimumValueDescription
//        )
        
        let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.numberOfTimesFallen)!
        let unit = HKUnit(from: "")
        let new_answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .decimal)
        
        // Create a question.
        let questionStep = ORKQuestionStep(identifier: "MoodStep", title: question, answer: new_answerFormat)
        questionStep.isOptional = false
        
        // Create an ordered task with a single question.
        let task = ORKOrderedTask(identifier: "MoodStep", steps: [questionStep])
        
        return task
    }
    
    

    
  static func makeTemperatureAssessmentTask() -> ORKTask {
    let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyTemperature)!
    let unit = HKUnit(from: "degF")
    let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .decimal)
    
    // Create a question.
    let title = "Take temperature orally."
    let text = "Temperatures in the range of 99-103°F are an early sign of possible infection."
    let questionStep = ORKQuestionStep(identifier: "TemperatureStep", title: title, text: text, answer: answerFormat)
    questionStep.isOptional = false
    
    // Create an ordered task with a single question
    return ORKOrderedTask(identifier: "TemperatureTask", steps: [questionStep])
  }
}
