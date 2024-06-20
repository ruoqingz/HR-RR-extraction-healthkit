/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view controller that displays quantity sample statistics for the week.
*/

import UIKit
import HealthKit

//class WeeklyQuantitySampleTableViewController: HealthDataTableViewController, HealthQueryDataSource {
class WeeklyQuantitySampleTableViewController: HRDataTableViewController, HealthQueryDataSource {
    
    let calendar: Calendar = .current
    let healthStore = HealthData.healthStore
    
    var quantityTypeIdentifier: HKQuantityTypeIdentifier {
        return HKQuantityTypeIdentifier(rawValue: dataTypeIdentifier)
    }
    
    var quantityType: HKQuantityType {
        return HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier)!
    }
    
    var query: HKSampleQuery?
    
    // MARK: - View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if query != nil { return }
        
        // Request authorization.
        let dataTypeValues = Set([quantityType])
        
        print("Requesting HealthKit authorization of Heart Rate...")
        
        self.healthStore.requestAuthorization(toShare: dataTypeValues, read: dataTypeValues) { (success, error) in
            if success {
//                self.calculateDailyQuantitySamplesForPastWeek() //run
                print("ready to run setupHeartRateObservor")
                self.setupHeartRateObservor()
            }
        }
    }
    
    func setupHeartRateObservor(){
        print("get into setupobservor")
        let query = HKObserverQuery(sampleType: getSampleType(for: dataTypeIdentifier)!, predicate: nil){(query, completionHandler,error) in
            guard error == nil else{
                print("Observer query failed with error: \(error!.localizedDescription)")
                return
            }
            
            print("ready to use performquery")
            
            self.performQuery {
                DispatchQueue.main.async { [weak self] in
                    self?.reloadData()
                }
            }
            completionHandler()
            
        }
        healthStore.execute(query)
        healthStore.enableBackgroundDelivery(for: getSampleType(for: dataTypeIdentifier)!, frequency: .immediate, withCompletion: {(status, error)in
            if status == false {
                print("Error enabling background delivery - \(error.debugDescription)")
            }
        })
    }
    
//    func calculateDailyQuantitySamplesForPastWeek() {
//        performQuery { //run
//            DispatchQueue.main.async { [weak self] in
//                self?.reloadData()
//            }
//        }
//    }
    
    // MARK: - HealthQueryDataSource
    
    //    func performQuery(completion: @escaping () -> Void) {
    //        //let = predicate = createLastWeekPredicate()
    //        let anchorDate = createAnchorDate() // 使每次查询开始于一个确定的时间，比如每个星期一
    //        let dailyInterval = DateComponents(day: 1)
    //        let statisticsOptions = getStatisticsOptions(for: dataTypeIdentifier)
    //
    //        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
    //                                                 quantitySamplePredicate: predicate,
    //                                                 options: statisticsOptions,
    //                                                 anchorDate: anchorDate,
    //                                                 intervalComponents: dailyInterval)
    //
    //        // The handler block for the HKStatisticsCollection object.
    //        let updateInterfaceWithStatistics: (HKStatisticsCollection) -> Void = { statisticsCollection in
    //            self.dataValues = []
    //
    //            let now = Date()
    //            let startDate = getLastWeekStartDate()
    //            let endDate = now
    //
    //            statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { [weak self] (statistics, stop) in
    //                var dataValue = HealthDataTypeValue(startDate: statistics.startDate,
    //                                                    endDate: statistics.endDate,
    //                                                    value: 0)
    //
    //                if let quantity = getStatisticsQuantity(for: statistics, with: statisticsOptions),
    //                   let identifier = self?.dataTypeIdentifier,
    //                   let unit = preferredUnit(for: identifier) {
    //                    dataValue.value = quantity.doubleValue(for: unit)
    //                }
    //
    //                self?.dataValues.append(dataValue)
    //            }
    //
    //            completion()
    //        }
    //
    //        query.initialResultsHandler = { query, statisticsCollection, error in
    //            if let statisticsCollection = statisticsCollection {
    //                updateInterfaceWithStatistics(statisticsCollection)
    //            }
    //        }
    //
    //        query.statisticsUpdateHandler = { [weak self] query, statistics, statisticsCollection, error in
    //            // Ensure we only update the interface if the visible data type is updated
    //            if let statisticsCollection = statisticsCollection, query.objectType?.identifier == self?.dataTypeIdentifier {
    //                updateInterfaceWithStatistics(statisticsCollection)
    //            }
    //        }
    //
    //        self.healthStore.execute(query)
    //        self.query = query
    //    }
    func performQuery(completion: @escaping () -> Void) {
        print("get into perform query")
        let predicate = createLastSecondsPredicate()
        
        // The handler block for the HKStatisticsCollection object.
        let updateInterfaceWithStatistics: ([HKQuantitySample]) -> Void = { samples in
            print(samples.count)
            for sample in samples {
                let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                print("Heart rate at \(sample.startDate): \(heartRate) BPM")
            }
        }
        
        let query = HKSampleQuery(sampleType: getSampleType(for: dataTypeIdentifier)!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil){
            (query, samples, error) in
            guard let samples = samples as? [HKQuantitySample],error==nil else {
                print("No samples returned: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            updateInterfaceWithStatistics(samples) //run
            
        }
        
        
//        // 更新数据
//        query.initialResultsHandler = { query, statisticsCollection, error in
//            if let statisticsCollection = statisticsCollection {
//                updateInterfaceWithStatistics(statisticsCollection)
//            }
//        }
//        
//        //更换datatype
//        query.statisticsUpdateHandler = { [weak self] query, statistics, statisticsCollection, error in
//            // Ensure we only update the interface if the visible data type is updated
//            if let statisticsCollection = statisticsCollection, query.objectType?.identifier == self?.dataTypeIdentifier {
//                updateInterfaceWithStatistics(statisticsCollection)
//            }
//        }
        
        self.healthStore.execute(query)
        self.query = query
    }



    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let query = query {
            self.healthStore.stop(query)
        }
    }
}


