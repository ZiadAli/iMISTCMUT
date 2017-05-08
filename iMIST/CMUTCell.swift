//
//  CMUTCell.swift
//  iMIST
//
//  Created by Ziad Ali on 4/27/17.
//  Copyright © 2017 ZiadCorp. All rights reserved.
//

import UIKit

class CMUTCell: UICollectionViewCell {
    
    @IBOutlet var deviceLabel: UILabel!
    @IBOutlet var cmutView: UIView!
    let cmutsPerRow = 4
    let cmutsPerColumn = 2
    var channelData:[UInt8:Double]!
    
    func initialize(deviceName:String, channelData:[UInt8:Double]) {
        self.channelData = channelData
        deviceLabel.text = deviceName
        formatCmutView()
        addLabels()
    }
    
    func formatCmutView() {
        cmutView.layer.cornerRadius = 5.0
    }
    
    func addLabels() {
        let horizontalSpacing = cmutView.frame.width/CGFloat(cmutsPerRow+1)
        let verticalSpacing = cmutView.frame.height/CGFloat(cmutsPerColumn+1)
        
        for i in 0..<cmutsPerColumn {
            for j in 0..<cmutsPerRow {
                let dataView = UIView(frame: CGRect(x: 0, y: 0, width: horizontalSpacing-10.0, height: verticalSpacing-10.0))
                dataView.center.x = horizontalSpacing*CGFloat(j+1)
                dataView.center.y = verticalSpacing*CGFloat(i+1)
                dataView.backgroundColor = UIColor.white
                dataView.layer.cornerRadius = dataView.frame.width/2.0
                
                let dataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: horizontalSpacing-15.0, height: 20))
                dataLabel.textAlignment = .center
                dataLabel.text = "--"
                dataLabel.center = dataView.center
                
                let dataIndex = i*cmutsPerRow+j
                let dataUintIndex = UInt8(16*dataIndex)
                if let data = channelData[dataUintIndex] {
                    let mhzData = data/1000000.0
                    let formattedData = Double(round(1000000*mhzData)/1000000)
                    dataLabel.text = "\(formattedData)"
                }
                
                cmutView.addSubview(dataView)
                cmutView.addSubview(dataLabel)
            }
        }
    }
}
