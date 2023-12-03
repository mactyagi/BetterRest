//
//  ContentView.swift
//  BetterRest
//
//  Created by Admin on 03/12/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
   static var defaultWakeTime: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var coffeeAmountIndex = 0
    var totalCoffeeAmount: Int{
        coffeeAmountIndex + 1
    }
    var body: some View {
        NavigationStack{
            Form{
                Section("When do you want to wake up?"){
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section("Desired amount of sleep"){
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section("Daily coffee intake"){
                    Picker("Number of cups", selection: $coffeeAmountIndex) {
                        ForEach(1 ..< 20){ number in
                                Text("^[\(number) cup](inflect: true)")
                        }
                    }
                }
                
                Section("Ideal sleep"){
                    let sleepDate = calculateBedTime()
                    Text("Your ideal sleep is \(sleepDate?.formatted(date: .omitted, time: .shortened) ?? "")")
                }
            }
            .navigationTitle("BetterRest")
//            .toolbar {
//                Button("Calculate", action: calculateBedTime)
//            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK"){}
            }message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedTime() -> Date? {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(hour + minute), estimatedSleep: sleepAmount, coffee: Int64(totalCoffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            showingAlert = true
            return nil
        }
        
    }
}

#Preview {
    ContentView()
}
