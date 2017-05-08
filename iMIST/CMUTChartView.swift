//
//  CMUTChartView.swift
//  iMIST
//
//  Created by Ziad Ali on 4/28/17.
//  Copyright © 2017 ZiadCorp. All rights reserved.
//

import Foundation
import Charts

class CMUTChartView:LineChartView {
    
    var initialized = false
    
    func initialize(device:BluetoothDevice, channel:UInt8, yVal:Double, xVal:Double) {
        //Create new data entry array for chart and add the first data element to it
        var lineChartEntries: [ChartDataEntry] = []
        let newEntry = ChartDataEntry(x: xVal, y: yVal)
        lineChartEntries.append(newEntry)
        
        //If the device has a name add it to the chart label
        var deviceName = "None"
        if let _ = device.name {
            deviceName = device.name!
        }
        let currentChannel = Int(channel)/16
        let lineChartSet = LineChartDataSet(values: lineChartEntries, label: "Device: \(deviceName) Channel \(currentChannel)")
        
        //Set the chart parameters including point size and color
        lineChartSet.circleRadius = 3.0
        let red = NSUIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        lineChartSet.setColor(red)
        lineChartSet.setCircleColor(red)
        let lineChartData = LineChartData(dataSet: lineChartSet)
        
        //Update the chartsInitialized array and attach new data to the line chart
        self.data = lineChartData
        initialized = true
    }
    
    func update(yVal:Double, xVal:Double) {
        let newEntry = ChartDataEntry(x: xVal, y: yVal)
        self.data?.addEntry(newEntry, dataSetIndex: 0)
        self.setVisibleXRangeMaximum(10.0)
        //currentLineChart.setVisibleXRangeMinimum(0.1)
        //self.lineChart.setVisibleXRange(minXRange: 10.0, maxXRange: 10.0)
        //self.lineChart.setVisibleYRange(minYRange: 10.0, maxYRange: 10.0, axis: .left)
        //self.lineChart.centerViewTo(xValue: xVal, yValue: yVal, axis: .left)
        self.notifyDataSetChanged()
        self.moveViewToX(xVal)
    }
}
