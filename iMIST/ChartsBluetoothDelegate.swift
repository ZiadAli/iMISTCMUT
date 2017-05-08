//
//  ChartsBluetoothDelegate.swift
//  iMIST
//
//  Created by Ziad Ali on 4/26/17.
//  Copyright © 2017 ZiadCorp. All rights reserved.
//

import Foundation
import CoreBluetooth

var allDevices:[BluetoothDevice]!               //Stores all located devices
var connectedDevices:[BluetoothDevice]!         //Stores connected devices
var currentDeviceIndex = 0                      //Stores index of current device in connectedDevices
var currentChannelIndex = 0                     //Stores index of current channel for current device

extension ChartsViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    
    // MARK: Custom Methods
    
    //Connects to new device
    func connect(to peripheral:CBPeripheral) {
        manager.connect(peripheral, options: nil)
        peripheral.delegate = self
        //peripherals.append(peripheral)
    }
    
    //Updates device connection status and adds/removes from connectedDevices array
    func updateDevicesConnectionStatus(peripheral:CBPeripheral, connected:Bool) {
        if let device = getDevice(from: peripheral) {
            device.connected = connected
            device.isConnecting = false
            if connected {
                addToConnectedDevices(device: device)
            }
            else {
                removeFromConnectedDevices(device: device)
            }
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "Update Devices View")))
        }
    }
    
    //Adds device to connectedDevices if it hasn't been added already
    func addToConnectedDevices(device:BluetoothDevice) {
        if !connectedDevices.contains(where: { (connectedDevice) -> Bool in
            connectedDevice.peripheral == device.peripheral
        }) {
            connectedDevices.append(device)
        }
    }
    
    //Removes device from connectedDevices if it is in the array
    func removeFromConnectedDevices(device:BluetoothDevice) {
        if let deviceIndex = connectedDevices.index(where: { (connectedDevice) -> Bool in
            connectedDevice.peripheral == device.peripheral
        }) {
            connectedDevices.remove(at: deviceIndex)
        }
    }
    
    //Get device from list of all devices from its peripheral
    func getDevice(from peripheral:CBPeripheral) -> BluetoothDevice? {
        for device in allDevices {
            if let devicePeripheral = device.peripheral {
                if devicePeripheral == peripheral {
                    return device
                }
            }
        }
        return nil
    }
    
    //Get device from list of connected devices
    func getCurrentConnectedDevice() -> BluetoothDevice? {
        if connectedDevices.count > currentDeviceIndex {
            return connectedDevices[currentDeviceIndex]
        }
        else {
            print("DidUpdateValue: Device index was too large")
            return nil
        }
    }
    
    //Returns hex string for data returned from CMUT to print to console
    func getHexString(array:[UInt8]) -> String? {
        if array.count >= 4 {
            let hex1 = String(format:"%02X", array[0])
            let hex2 = String(format:"%02X", array[1])
            let hex3 = String(format:"%02X", array[2])
            let hex4 = String(format:"%02X", array[3])
            return "\(hex1) \(hex2) \(hex3) \(hex4)"
        }
        return nil
    }
    
    //Updates current channel or current device indices
    func updateCurrentChannel() {
        let device = connectedDevices[currentDeviceIndex]
        currentChannelIndex += 1
        if currentChannelIndex >= device.deviceChannels.count {
            currentChannelIndex = 0
            currentDeviceIndex += 1
            if currentDeviceIndex >= connectedDevices.count {
                currentDeviceIndex = 0
            }
        }
        skipDeviceIfNoChannelsActivated()
    }
    
    //Resets current device and current channel indices and sets them to first device with actual channels
    func resetCurrentChannelAndDevice() {
        currentDeviceIndex = 0
        currentChannelIndex = 0
        skipDeviceIfNoChannelsActivated()
    }
    
    //Skips devices with no activated channels
    func skipDeviceIfNoChannelsActivated() {
        if let currentDevice = getCurrentConnectedDevice() {
            if connectedDevices.contains(where: { (device) -> Bool in
                device.deviceChannels.count > 0
            }) {
                if currentDevice.deviceChannels.count == 0 {
                    updateCurrentChannel()
                }
            }
        }
    }
    
    //Begin collecting data
    func startDataCollection() {
        if let currentDevice = getCurrentConnectedDevice() {
            currentDevice.runDevice(channelIndex: currentChannelIndex)
        }
    }
    
    
    
    // MARK: CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
        else {
            print("Bluetooth not available")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let deviceName = peripheral.name else {return}
        let deviceId = peripheral.identifier
        
        //If device has not already been added to allDevices, add it
        if !allDevices.contains(where: {$0.peripheral == peripheral}) {
            let bluetoothDevice = BluetoothDevice()
            bluetoothDevice.name = deviceName
            bluetoothDevice.id = deviceId.uuidString
            bluetoothDevice.peripheral = peripheral
            bluetoothDevice.chartController = self
            
            allDevices.append(bluetoothDevice)
            
            print("Did discover new peripheral: \(deviceName) \(deviceId.uuidString)")
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "Update Devices View")))
        }
            
        else {
            print("Rediscovered old peripheral:\(deviceName) \(deviceId.uuidString)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Did connect peripheral: \(peripheral.name!) \(peripheral.identifier.uuidString)")
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Error connecting peripheral: \(error)")
        updateDevicesConnectionStatus(peripheral: peripheral, connected: false)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Did disconnect peripheral")
        updateDevicesConnectionStatus(peripheral: peripheral, connected: false)
    }
    
    
    
    // MARK: CBPeripheralDelegate
    
    //Set devices to connected if they contain
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {return}
        
        //If device has Simblee characteristics add it to the connectedDevices list and set the device write characteristic
        for characteristic in characteristics {
            //2221 is read and 2222 and 2223 are write
            print("Characteristic: \(characteristic.uuid.uuidString)")
            if characteristic.uuid.uuidString == "2221" {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            else if characteristic.uuid.uuidString == "2222" {
                //writePeripheral = peripheral
                //writeCharacteristic = characteristic
                //initializeSimblee(peripheral: peripheral, characteristic: characteristic)
                updateDevicesConnectionStatus(peripheral: peripheral, connected: true)
                let device = getDevice(from: peripheral)!
                device.characteristic = characteristic
                device.initializeDevice()
            }
        }

    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //Gets current device if it is in connectedDevices
        guard connectedDevices.count > currentDeviceIndex else {
            print("DidUpdateValue: Device index was too large")
            return
        }
        let device = connectedDevices[currentDeviceIndex]
        
        //Gets current device channel
        guard device.deviceChannels.count > currentChannelIndex else {
            print("DidUpdateValue: Channel index was too large")
            return
        }
        let currentUintChannel = device.deviceChannels[currentChannelIndex]
        
        if let value = characteristic.value {
            let array = [UInt8](value)
            var frequency = 0.0
            if array.count >= 4 {
                //Calculate returned frequency from hex
                let freqSum = (UInt32(array[3]) << 24) + (UInt32(array[2]) << 16) + (UInt32(array[1]) << 8) + UInt32(array[0])
                frequency = Double(freqSum)/device.gateTime/2
                print("Device: \(device.name!) Channel: \(currentUintChannel/16) Frequency: \(frequency) Hex Array: \(getHexString(array: array)) ")
                
                let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
                device.mostRecentMeasurement[currentUintChannel] = frequency
                device.measurements[currentUintChannel]?.append([elapsedTime, frequency])
                
                if let cmutCell = device.cmutCell {
                    cmutCell.initialize(deviceName: device.name!, channelData: device.mostRecentMeasurement)
                }
                
                if let chartOptional = device.charts[currentUintChannel] {
                    if let chart = chartOptional {
                        let yVal = (frequency/1000000)
                        let xVal = elapsedTime
                        print("Yval: \(yVal) Xval: \(xVal)")
                        
                        if chart.initialized == false {
                            chart.initialize(device: device, channel: currentUintChannel, yVal: yVal, xVal: xVal)
                        }
                        else {
                            chart.update(yVal: yVal, xVal: xVal)
                        }
                    }
                }
                
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "New Measurement")))
                
                updateCurrentChannel()
                if shouldRun {
                    if let currentDevice = getCurrentConnectedDevice() {
                        currentDevice.runDevice(channelIndex: currentChannelIndex)
                    }
                }
                /*
                if readValues >= 10 {
                    if device.initializedChannels[currentUintChannel]! {
                        updateCharts(yVal: (frequency/1000000), xVal: elapsedTime)
                    }
                    else {
                        initializeChart(yVal: (frequency/1000000), xVal: elapsedTime)
                    }
                }
                else {
                    readValues += 1
                }*/
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        
        for service in services {
            print("Service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
}
