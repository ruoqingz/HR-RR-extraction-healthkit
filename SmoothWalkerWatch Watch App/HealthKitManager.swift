
import Foundation
import HealthKit


class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    var heartRateQuery: HKSampleQuery?
    var breatheRateQuery: HKSampleQuery?
    var updateTimer: Timer?
    
    var onHeartRateUpdate: (([HKQuantitySample]?, Error?) -> Void)?
    var onBreatheRateUpdate: (([HKQuantitySample]?, Error?) -> Void)?
    
    func requestAuthorization(completion:@escaping(Bool,Error?)->Void){
        guard HKHealthStore.isHealthDataAvailable() else{
            completion(false,NSError(domain: "com.example.HealthKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available in this Device"]))
            return
        }
        let heartRateType=HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "heartRate"))!
        let breathRateType=HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "respiratoryRate"))!
        
        let typesToRead: Set<HKObjectType>=[heartRateType,breathRateType]
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            completion(success,error)
            }
        }
    
    func startUpdateData(){
        print("get into start update data")
        let interval=5.0
        DispatchQueue.main.async{
            self.updateTimer=Timer.scheduledTimer(withTimeInterval: interval, repeats: true){[weak self] _ in
                print("timer fired")
                self?.performHRQuery{ samples, error in
                    self?.onHeartRateUpdate?(samples,error)
                    
                }
                self?.performBRQuery{ samples, error in
                    self?.onBreatheRateUpdate?(samples,error)
                    
                }
            }
        }
        
    }
    

    func performHRQuery(completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        print("get into perform HR query")
        
        let predicate = self.createLastSecondsPredicate()
        let heartRateType=HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "heartRate"))!
        
        // The handler block for the HKStatisticsCollection object.
        let updateInterfaceWithStatistics: ([HKQuantitySample]) -> Void = { samples in
            print(samples.count)
            for sample in samples {
                let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                let localTime = self.localTimeString(from: sample.startDate)
                print("Heart rate at \(localTime): \(heartRate) BPM")
            }
        }
        
        let heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil){
            (query, samples, error) in
            guard let samples = samples as? [HKQuantitySample],error==nil else {
                print("No samples returned: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil,error)
                return
            }
            updateInterfaceWithStatistics(samples) //run
            completion(samples,nil)
        }
        self.healthStore.execute(heartRateQuery)
        self.heartRateQuery=heartRateQuery
    }
    
    func performBRQuery(completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        print("get into perform BR query")

        let predicate = self.createLastSecondsPredicate()
        let breathRateType=HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: "respiratoryRate"))!
        
        // The handler block for the HKStatisticsCollection object.
        let updateInterfaceWithStatistics: ([HKQuantitySample]) -> Void = { samples in
            print(samples.count)
            for sample in samples {
                let breatheRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                let localTime = self.localTimeString(from: sample.startDate)
                print("Breathe rate at \(localTime): \(breatheRate) times/min")
            }
        }
        
        let breatheRateQuery = HKSampleQuery(sampleType: breathRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil){
            (query, samples, error) in
            guard let samples = samples as? [HKQuantitySample],error==nil else {
                print("No samples returned: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil,error)
                return
            }
            updateInterfaceWithStatistics(samples) //run
            completion(samples,nil)
        }
        self.healthStore.execute(breatheRateQuery)
        self.breatheRateQuery=breatheRateQuery
    }
    
    func localTimeString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current // 设置为当前时区
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 您可以自定义日期和时间的格式
        return dateFormatter.string(from: date)
    }
    
    func createLastSecondsPredicate(from endDate: Date=Date()) -> NSPredicate{
        print(endDate)
        let startDate=endDate.addingTimeInterval(-30)
        return HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
    }
    
    func stopMonitoringHeartRate() {
            updateTimer?.invalidate()
            updateTimer = nil
        }
}

