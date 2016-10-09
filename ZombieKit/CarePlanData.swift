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

import CareKit

enum ActivityIdentifier: String {
  case cardio
  case limberUp = "Limber Up"
  case targetPractice = "Target Practice"
  case pulse
  case temperature
  case mood
    
}

class CarePlanData: NSObject {
  let carePlanStore: OCKCarePlanStore
    let s = "shivam is disappointing"
  let contacts =
    [
     OCKContact(contactType: .careTeam,
                name: "Dr. Shivam Patel",
                relation: "Psychatrist",
                tintColor: nil,
                phoneNumber: CNPhoneNumber(stringValue: "510-555-5555"),
                messageNumber: CNPhoneNumber(stringValue: "510-555-5555"),
                emailAddress: "patelshivam845@gmail.com",
                monogram: "SP",
                image: UIImage(named: "hershel-avatar"))]

  class func dailyScheduleRepeating(occurencesPerDay: UInt) -> OCKCareSchedule {
    return OCKCareSchedule.dailySchedule(withStartDate: DateComponents.firstDateOfCurrentWeek,
                                         occurrencesPerDay: occurencesPerDay)
  }

  init(carePlanStore: OCKCarePlanStore) {
    self.carePlanStore = carePlanStore
    
    let cardioActivity = OCKCarePlanActivity(
      identifier: ActivityIdentifier.cardio.rawValue,
      groupIdentifier: nil,
      type: .intervention,
      title: "Mindful Meditation",
      text: "15 Minutes",
      tintColor: UIColor.darkOrange(),
      instructions: "Concentrate on your thoughts and meditate for 15 minutes. Record your thoughts on an notebook.",
      imageURL: nil,
      schedule:CarePlanData.dailyScheduleRepeating(occurencesPerDay: 2),
      resultResettable: true,
      userInfo: nil)
    
    let limberUpActivity = OCKCarePlanActivity(
      identifier: ActivityIdentifier.limberUp.rawValue,
      groupIdentifier: nil,
      type: .intervention,
      title: "Ativan",
      text: "Intake",
      tintColor: UIColor.darkOrange(),
      instructions: "This is your anxiety medicine.",
      imageURL: nil,
      schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 2),
      resultResettable: true,
      userInfo: nil)
    
    let targetPracticeActivity = OCKCarePlanActivity(
      identifier: ActivityIdentifier.targetPractice.rawValue,
      groupIdentifier: nil,
      type: .intervention,
      title: "Jogging",
      text: nil,
      tintColor: UIColor.darkOrange(),
      instructions: "Go on a jog around the park.",
      imageURL: nil,
      schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 1),
      resultResettable: true,
      userInfo: nil)
    
    let pulseActivity = OCKCarePlanActivity
      .assessment(withIdentifier: ActivityIdentifier.pulse.rawValue,
                  groupIdentifier: nil,
                  title: "Pulse",
                  text: "Do you have one?",
                  tintColor: UIColor.darkGreen(),
                  resultResettable: true,
                  schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 1),
                  userInfo: ["ORKTask": AssessmentTaskFactory.makePulseAssessmentTask()])
    
    
    let temperatureActivity = OCKCarePlanActivity
      .assessment(withIdentifier: ActivityIdentifier.temperature.rawValue,
                  groupIdentifier: nil,
                  title: "Temperature",
                  text: "Oral",
                  tintColor: UIColor.darkYellow(),
                  resultResettable: true,
                  schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 1),
                  userInfo: ["ORKTask": AssessmentTaskFactory.makeTemperatureAssessmentTask()])
    
    let moodActivity = OCKCarePlanActivity
        .assessment(withIdentifier: ActivityIdentifier.mood.rawValue,
                    groupIdentifier: nil,
                    title: "Daily Emotional Survey",
                    text: "How are you feeling?",
                    tintColor: nil,
                    resultResettable: false,
                    schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 1),
                    userInfo: ["ORKTask": AssessmentTaskFactory.makeTemperatureAssessmentTask()])
    
    

    
    super.init()
    
    for activity in [cardioActivity, limberUpActivity, targetPracticeActivity,
                     pulseActivity, temperatureActivity, moodActivity] {
                      add(activity: activity)
    }
  }
  
  func add(activity: OCKCarePlanActivity) {
    carePlanStore.activity(forIdentifier: activity.identifier) {
      [weak self] (success, fetchedActivity, error) in
      guard success else { return }
      guard let strongSelf = self else { return }

      if let _ = fetchedActivity { return }
      
      strongSelf.carePlanStore.add(activity, completion: { _ in })
    }
  }
}

extension CarePlanData {
  func generateDocumentWith(chart: OCKChart?) -> OCKDocument {
    let intro = OCKDocumentElementParagraph(content: "I've been tracking my efforts to avoid becoming a Zombie with ZombieKit. Please check the attached report to see if you're safe around me.")
    
    var documentElements: [OCKDocumentElement] = [intro]
    if let chart = chart {
      documentElements.append(OCKDocumentElementChart(chart: chart))
    }
    
    let document = OCKDocument(title: "Re: Your Brains", elements: documentElements)
    document.pageHeader = "ZombieKit: Weekly Report"
    
    return document
  }
}
