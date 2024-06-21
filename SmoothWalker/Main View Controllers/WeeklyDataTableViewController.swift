/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view controller that displays quantity sample statistics for the week.
*/

import UIKit
import HealthKit


class WeeklyQuantitySampleTableViewController: HRDataTableViewController, HealthQueryDataSource {
    
    let healthStore = HealthData.healthStore
    
    var quantityTypeIdentifier: HKQuantityTypeIdentifier {
        return HKQuantityTypeIdentifier(rawValue: dataTypeIdentifier)
    }
    
    var quantityType: HKQuantityType {
        return HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier)!
    }
    
    var query: HKSampleQuery?
    var updateTimer: Timer?
    
    // MARK: - View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if query != nil { return }

        // Request authorization.
        let dataTypeValues = Set([quantityType])

        print("Requesting HealthKit authorization of Heart Rate...")

        self.healthStore.requestAuthorization(toShare: dataTypeValues, read: dataTypeValues) { (success, error) in
            if success {
                print("ready to run setupHeartRateObservor")
                self.startUpdateData()
            }
        }
    }
    
    func startUpdateData(){
        print("get into start update data")
        let interval=5.0
        DispatchQueue.main.async{
            self.updateTimer=Timer.scheduledTimer(withTimeInterval: interval, repeats: true){[weak self] _ in
                print("timer fired")
                self?.performQuery {
                    DispatchQueue.main.async {
                        self?.reloadData()
                    }
                }
            }
        }
        
    }
    // MARK: - HealthQueryDataSource
    

    func performQuery(completion: @escaping () -> Void) {
        print("get into perform query")
        func createLastSecondsPredicate(from endDate: Date=Date()) -> NSPredicate{
            print(endDate)
            let startDate=endDate.addingTimeInterval(-30)
            return HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        }
        
        let predicate = createLastSecondsPredicate()
        
        // The handler block for the HKStatisticsCollection object.
        let updateInterfaceWithStatistics: ([HKQuantitySample]) -> Void = { samples in
            print(samples.count)
            for sample in samples {
                let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                let localTime = self.localTimeString(from: sample.startDate)
                print("Heart rate at \(localTime): \(heartRate) BPM")
            }
        }
        
        let query = HKSampleQuery(sampleType: getSampleType(for: dataTypeIdentifier)!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil){
            (query, samples, error) in
            guard let samples = samples as? [HKQuantitySample],error==nil else {
                print("No samples returned: \(error?.localizedDescription ?? "Unknown error")")
                completion()
                return
            }
            updateInterfaceWithStatistics(samples) //run
            completion()
        }
        self.healthStore.execute(query)
        self.query=query
    }
    
    func localTimeString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current // 设置为当前时区
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 您可以自定义日期和时间的格式
        return dateFormatter.string(from: date)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateTimer?.invalidate()
        updateTimer = nil
    }
}
