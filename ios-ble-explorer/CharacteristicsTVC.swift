//
//  CharacteristicsTVC.swift
//  BluetoothDiscovery
//
//  Created by João Marcelo on 19/06/15.
//  Copyright (c) 2015 João Marcelo Oliveira. All rights reserved.
//

import UIKit
import CoreBluetooth

class CharacteristicsTVC: UITableViewController, CBPeripheralDelegate {
    
    var peripheral: CBPeripheral!
    var service: CBService!
    var characteristics = Array<CBCharacteristic>()
    
    override func viewDidAppear(animated: Bool) {
        peripheral.delegate = self
        peripheral.discoverCharacteristics(nil, forService: service)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characteristics.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Characteristic", forIndexPath: indexPath) as! UITableViewCell

        let c = characteristics[indexPath.row]
        cell.textLabel?.text = "UUID: \(c.UUID.UUIDString)"
        cell.detailTextLabel?.text = c.value == nil ? "Value: [none]" : "Value: \(c.value.hexadecimalString().stringFromHexadecimalStringUsingEncoding(NSUTF8StringEncoding)!)"
        
        

        return cell
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        
        if let e = error {
            println("Failed to discover characteristics: \(e.localizedDescription)")
            
            UIAlertView(
                title: "Characteristics failed",
                message: "Failed to discover characteristics: \(e.localizedDescription)",
                delegate: nil,
                cancelButtonTitle: "OK")
                .show()
            return
        }
        
        for characteristic in service.characteristics as! [CBCharacteristic] {
            println("Characteristic discovered: \(characteristic)")
            
            characteristics.append(characteristic)
            peripheral.setNotifyValue(true, forCharacteristic: characteristic)
        }
        self.tableView.reloadData()
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if let e = error {
            println("Failed to update value for characteristic: \(e.localizedDescription)")
            return
        }
        
        println("Value for characteristic \(characteristic.UUID.UUIDString) is: \(characteristic.value)")
        
        self.tableView.reloadData()
    }

}
