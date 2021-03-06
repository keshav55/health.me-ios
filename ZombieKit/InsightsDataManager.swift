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

class InsightsDataManager {
  let store = CarePlanStoreManager.sharedCarePlanStoreManager.store
  var completionData = [(dateComponent: DateComponents, value: Double)]()
  let gatherDataGroup = DispatchGroup()
  var pulseData = [DateComponents: Double]()
  var temperatureData = [DateComponents: Double]()
    var biotinData = [DateComponents: Double]()
    var moodData = [DateComponents: Double]()

  var completionSeries: OCKBarSeries {
    let completionValues = completionData.map({ NSNumber(value:$0.value) })
    
    let completionValueLabels = completionValues
      .map({ NumberFormatter.localizedString(from: $0, number: .percent)})
    
    return OCKBarSeries(
      title: "Wellness Analysis",
      values: completionValues,
      valueLabels: completionValueLabels,
      tintColor: UIColor.darkOrange())
  }

  func fetchDailyCompletion(startDate: DateComponents, endDate: DateComponents) {
    gatherDataGroup.enter()

    store.dailyCompletionStatus(
      with: .intervention,
      startDate: startDate,
      endDate: endDate,
      handler: { (dateComponents, completed, total) in
        let percentComplete = Double(completed) / Double(total)
        self.completionData.append((dateComponents, percentComplete))
      },
      completion: { (success, error) in
        guard success else { fatalError(error!.localizedDescription) }
        self.gatherDataGroup.leave()
    })
  }
  
  func updateInsights(_ completion: ((Bool, [OCKInsightItem]?) -> Void)?) {
    guard let completion = completion else { return }
    
    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
      let startDateComponents = DateComponents.firstDateOfCurrentWeek
      let endDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date())
      
      guard let pulseActivity = self.findActivityWith(ActivityIdentifier.pulse) else { return }
      self.fetchActivityResultsFor(pulseActivity, startDate: startDateComponents,
                                   endDate: endDateComponents) { (fetchedData) in
                                    self.pulseData = fetchedData
      }
      
      guard let temperatureActivity = self.findActivityWith(ActivityIdentifier.temperature) else { return }
      self.fetchActivityResultsFor(temperatureActivity, startDate: startDateComponents,
                                   endDate: endDateComponents) { (fetchedData) in
                                    self.temperatureData = fetchedData
      }
        
        
        guard let biotinActivity = self.findActivityWith(ActivityIdentifier.biotin) else { return }
        self.fetchActivityResultsFor(biotinActivity, startDate: startDateComponents,
                                     endDate: endDateComponents) { (fetchedData) in
                                        self.biotinData = fetchedData
        }
        
        guard let moodActivity = self.findActivityWith(ActivityIdentifier.mood) else { return }
        self.fetchActivityResultsFor(moodActivity, startDate: startDateComponents,
                                     endDate: endDateComponents) { (fetchedData) in
                                        self.biotinData = fetchedData
        }
        
        
        
        
        
        

      self.fetchDailyCompletion(startDate: startDateComponents, endDate: endDateComponents)
      
      // Once all data is gathered, process and return it
      self.gatherDataGroup.notify(queue: DispatchQueue.main, execute: {
        let insightItems = self.produceInsightsForAdherence()
        completion(true, insightItems)
      })
    }
  }
  
  func barSeriesFor(data: [DateComponents: Double], title: String, tintColor: UIColor) -> OCKBarSeries {
    let rawValues = completionData.map({ (entry) -> Double? in
      return data[entry.dateComponent]
    })
    
    let values = DataHelpers().normalize(rawValues)
    
    let valueLabels = rawValues.map({ (value) -> String in
      guard let value = value else { return "N/A" }
      return NumberFormatter.localizedString(from: NSNumber(value:value), number: .decimal)
    })
    
    return OCKBarSeries(
      title: title,
      values: values,
      valueLabels: valueLabels,
      tintColor: tintColor)
  }
  
  func produceInsightsForAdherence() -> [OCKInsightItem] {
    let dateStrings = completionData.map({(entry) -> String in
      guard let date = Calendar.current.date(from: entry.dateComponent)
        else { return "" }
      return DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
    })
    
    let pulseAssessmentSeries = barSeriesFor(data: pulseData, title: "Pulse",
                                             tintColor: UIColor.darkGreen())
    let temperatureAssessmentSeries = barSeriesFor(data: temperatureData, title: "Temperature",
                                                   tintColor: UIColor.darkYellow())
    let biotinAssessmentSeries = barSeriesFor(data:biotinData, title: "Biotin", tintColor: UIColor.darkOrange())
    
    let moodAssessmentSeries = barSeriesFor(data:biotinData, title: "Mood", tintColor: UIColor.purple)
    
    // Create chart from completion and assessment series
    let chart = OCKBarChart(
      title: "Insights",
      text: "Wellness",
      tintColor: UIColor.green,
      axisTitles: dateStrings,
      axisSubtitles: nil,
      dataSeries: [completionSeries, temperatureAssessmentSeries, pulseAssessmentSeries, biotinAssessmentSeries, moodAssessmentSeries])
    
    return [chart]
  }
  
  func findActivityWith(_ activityIdentifier: ActivityIdentifier) -> OCKCarePlanActivity? {
    let semaphore = DispatchSemaphore(value: 0)
    var activity: OCKCarePlanActivity?
    
    DispatchQueue.main.async {
      self.store.activity(forIdentifier: activityIdentifier.rawValue) { success, foundActivity, error in
        activity = foundActivity
        semaphore.signal()
      }
    }
    
    let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    
    return activity
  }
  
  func fetchActivityResultsFor(_ activity: OCKCarePlanActivity,
                               startDate: DateComponents, endDate: DateComponents,
                               completionClosure: @escaping (_ fetchedData: [DateComponents: Double]) ->()) {
    var fetchedData = [DateComponents: Double]()
    self.gatherDataGroup.enter()

    store.enumerateEvents(
      of: activity,
      startDate: startDate,
      endDate: endDate,
      handler: { (event, stop) in
        if let event = event,
          let result = event.result,
          let value = Double(result.valueString) {
          fetchedData[event.date] = value
        }
      },
      completion: { (success, error) in
        guard success else { fatalError(error!.localizedDescription) }
        completionClosure(fetchedData)
        self.gatherDataGroup.leave()
    })
  }
}
