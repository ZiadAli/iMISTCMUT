//
//  ChartsViewController.swift
//  iMIST
//
//  Created by Ziad Ali on 4/26/17.
//  Copyright © 2017 ZiadCorp. All rights reserved.
//

import UIKit
import CoreBluetooth

private let reuseIdentifier = "chartCell"

class ChartsViewController: UICollectionViewController {

    var manager:CBCentralManager!
    var shouldRun = false
    var startTime = CFAbsoluteTimeGetCurrent()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allDevices = [BluetoothDevice]()
        connectedDevices = [BluetoothDevice]()
        manager = CBCentralManager(delegate: self, queue: nil)
        startTime = CFAbsoluteTimeGetCurrent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stopOrStart(_ sender: Any) {
        shouldRun = !shouldRun
        resetCurrentChannelAndDevice()
        if shouldRun {
            collectionView?.reloadData()
            startDataCollection()
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("Connected Devices Count: \(connectedDevices.count)")
        return connectedDevices.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return connectedDevices[section].deviceChannels.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChartCell
        let device = connectedDevices[indexPath.section]
        let channel = device.deviceChannels[indexPath.row]
        print("Channel: \(channel)")
        
        if Array(device.charts.keys).contains(channel) == false {
            device.charts[channel] = cell.cmutChart
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
