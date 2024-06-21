import SwiftUI
import HealthKit

struct BreatheRateView:View{
    @State private var breathingRate:Int = 0 //为什么使用了private
    var body:some View{
        VStack{
            Text("Breathe Rate")
                .font(.title)
            Text("\(breathingRate) breaths/min")
                .font(.largeTitle)
                .foregroundColor(.blue)
                .padding()
//            updateBreathRate()
        }
        .padding()
    }
    
    private func updateBreathRate(){
        
    }
}

