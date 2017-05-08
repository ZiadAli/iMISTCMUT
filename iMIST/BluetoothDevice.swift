//
//  BluetoothDevice.swift
//  iMIST
//
//  Created by Ziad Ali on 4/26/17.
//  Copyright © 2017 ZiadCorp. All rights reserved.
//

import Foundation
import CoreBluetooth
import Charts

class BluetoothDevice:AnyObject {
    
    var name:String?
    var id:String?
    var peripheral:CBPeripheral?
    var characteristic:CBCharacteristic?
    var chartController:ChartsViewController?
    var connected = false
    var isConnecting = false
    
    var deviceChannels:[UInt8] = [0x00, 0x10, 0x40, 0x70]
    var mostRecentMeasurement:[UInt8:Double] = [UInt8:Double]()
    var measurements:[UInt8:[[Double]]] = [UInt8:[[Double]]]()
    
    var hvPot = 56
    var gateTime = 300.0/1000.0
    let hvSleep:UInt32 = 2
    let ampSleep:UInt32 = 1
    
    var cmutCell:CMUTCell?
    var charts:[UInt8:CMUTChartView?] = [UInt8:CMUTChartView?]()
    
    func initializeDevice() {
        guard let peripheral = peripheral else {return}
        guard let characteristic = characteristic else {return}
        
        //HV Setup
        let hv_init = UInt8(hvPot)
        let hvData = getDataFromArray(dataArray: [0x02, 0x00, hv_init])
        let lvData = getDataFromArray(dataArray: [0x03, 0x00, 0x7e])
        peripheral.writeValue(hvData, for: characteristic, type: .withResponse)
        peripheral.writeValue(lvData, for: characteristic, type: .withResponse)
        sleep(hvSleep)
        print("HV Setup Complete")
        
        //Set up osc and amp #1
        let ampWriteData1 = getDataFromArray(dataArray: [0x04, 0x80, 0x9a])
        let ampReadData1 = getDataFromArray(dataArray: [0x04, 0x00, 0x01])
        peripheral.writeValue(ampWriteData1, for: characteristic, type: .withResponse)
        peripheral.writeValue(ampReadData1, for: characteristic, type: .withResponse)
        sleep(ampSleep)
        print("Amp Setup 1 Complete")
        
        //Set up osc and amp #1
        let ampWriteData2 = getDataFromArray(dataArray: [0x04, 0x80, 0x9b])
        let ampReadData2 = getDataFromArray(dataArray: [0x04, 0x00, 0x01])
        peripheral.writeValue(ampWriteData2, for: characteristic, type: .withResponse)
        peripheral.writeValue(ampReadData2, for: characteristic, type: .withResponse)
        sleep(ampSleep)
        print("Amp Setup 2 Complete")
    }
    
    func runDevice(channelIndex:Int) {
        guard deviceChannels.count > channelIndex else {return}
        let channel = deviceChannels[channelIndex]
        guard let peripheral = peripheral else {return}
        guard let characteristic = characteristic else {return}
        DispatchQueue.global().async {
            //Counter reset
            let counterData1 = self.getDataFromArray(dataArray: [0x04, 0x80, 0x8a+channel])
            let counterData2 = self.getDataFromArray(dataArray: [0x04, 0x80, 0x8b+channel])
            peripheral.writeValue(counterData1, for: characteristic, type: .withResponse)
            peripheral.writeValue(counterData2, for: characteristic, type: .withResponse)
            
            //Gate time
            let gateData = self.getDataFromArray(dataArray: [0x05, 0x01, 0x2C])
            peripheral.writeValue(gateData, for: characteristic, type: .withResponse)
            usleep(450000)
            
            //Read SPI
            let spiData = self.getDataFromArray(dataArray: [0x04, 0x08, 0x04])
            peripheral.writeValue(spiData, for: characteristic, type: .withResponse)
            usleep(50000)
        }
    }
    
    func getDataFromArray(dataArray:[UInt8]) -> Data {
        var data = Data()
        for number in dataArray {
            data.append(number)
        }
        return data
    }
    
}
