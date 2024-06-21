

import SwiftUI
import HealthKit  // 确保导入HealthKit处理心率数据

struct ContentView: View {
    @State private var heartRate: String = "Loading..."
    @State private var breatheRate: String = "Loading..."
    
    //    var body: some View {
    //        VStack {
    //            Text("Heart Rate")
    //                .font(.title)
    //            Text("\(heartRate) BPM")
    //                .padding()
    //                .onAppear{
    //                    HealthKitManager.shared.startUpdateData()
    //                    HealthKitManager.shared.onHeartRateUpdate = {samples, error in
    //                        DispatchQueue.main.async {
    //                            if let samples = samples, let sample = samples.first {
    //                                let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
    //                                self.heartRate = "\(value) BPM"
    //                            } else {
    //                                self.heartRate = "Failed to fetch data: \(error?.localizedDescription ?? "Unknown error")"
    //                            }
    //                        }
    //                    }
    //                }
    //                .onDisappear {
    //                    HealthKitManager.shared.stopMonitoringHeartRate()
    //                }
    //                .padding()
    //        }
    //    }
    var body: some View{
        VStack(spacing:20){
            Text("最近30秒的数据")
                .font(.headline)
            
            HStack {
                VStack {
                    Text("Heart Rate")
                        .font(.title)
                    Text("\(heartRate) BPM")
                        .font(.body)
                }
                
                VStack {
                    Text("Breathe Rate")
                        .font(.title)
                    Text("\(breatheRate) times/min")
                        .font(.body)
                }
            }
        }
        .padding()
        .onAppear {
            HealthKitManager.shared.startUpdateData()
            setupCallbacks()
        }
        .onDisappear {
            HealthKitManager.shared.stopMonitoringHeartRate()
        }
    }
    
    func setupCallbacks(){
        HealthKitManager.shared.onHeartRateUpdate = {samples, error in
            DispatchQueue.main.async {
                if let samples = samples, let sample = samples.first {
                    let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    self.heartRate = "\(value) BPM"
                } else {
                    self.heartRate = "Failed to fetch data: \(error?.localizedDescription ?? "Unknown error")"
                }
            }
        }
        
        HealthKitManager.shared.onBreatheRateUpdate = {samples, error in
            DispatchQueue.main.async {
                if let samples = samples, let sample = samples.first {
                    let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    self.breatheRate = "\(value) BPM"
                } else {
                    self.breatheRate = "Failed to fetch data: \(error?.localizedDescription ?? "Unknown error")"
                }
            }
        }
    }
}
