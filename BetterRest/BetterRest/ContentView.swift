//
//  ContentView.swift
//  BetterRest
//
//  Created by Lance Kent Briones on 4/16/20.
//  Copyright © 2020 Lance Kent Briones. All rights reserved.
//

import SwiftUI
struct ResultFont: ViewModifier{
    func body(content: Content) -> some View{
        content
            .font(.largeTitle)
            .foregroundColor(.green)
    }
}
extension View {
    func result() -> some View {
        return self.modifier(ResultFont())
    }
}

struct ContentView: View {
    @State private var date_select = default_waketime
    @State private var sleep_amout: Double = 8.0
    @State private var coffee_amount: Int = 0
    
    static var default_waketime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 30
        
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var body: some View {
        NavigationView{
            Form {
                Section(header: Text("When do you want to wake up?")){
                    DatePicker(selection: $date_select, displayedComponents: .hourAndMinute, label: {
                        Text("")
                        })
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                }
                
                Section(header: Text("Desired hours of sleep")){
                    Stepper(value: $sleep_amout, in: 4...12, step: 0.25){
                        Text("\(sleep_amout, specifier: "%g") hours")
                    }
                }
                
                Section(header: Text("Daily coffee intake")){
                    Picker("", selection: $coffee_amount){  //self.coffee_amount will only be up to 19
                        ForEach(0..<20){
                            $0 == 0 ? Text("1 cup") : Text("\($0 + 1) cups")
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(WheelPickerStyle())
                }
                
                Section(header: Text("Recommended time of sleep"), footer: Text("Data was taken from: \n\n https://github.com/twostraws/HackingWithSwift/blob/master/SwiftUI/project4-files/BetterRest.csv!")){
                    self.calculate_bedtime().result()
                }
                
                
            }
            .navigationBarTitle("BetterRest", displayMode: .inline)
        }
    }
    func calculate_bedtime() -> some View{
        /*
         Data was taken from:
    https://github.com/twostraws/HackingWithSwift/blob/master/SwiftUI/project4-files/BetterRest.csv
         */
        
        let model = sleepCalculator()
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: date_select)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: self.sleep_amout, coffee: Double(self.coffee_amount + 1))
            // since self.coffee is off by 1, we will be adding 1 to prediction.coffee
            
            let sleep_time = self.date_select - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            return Text(formatter.string(from: sleep_time))
        }
        catch{
            return Text("There was an error calculating bedtime! Please try again.")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
