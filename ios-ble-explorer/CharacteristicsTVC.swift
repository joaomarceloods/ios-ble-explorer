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
    
    override func viewDidAppear(_ animated: Bool) {
        peripheral.delegate = self
        peripheral.discoverCharacteristics(nil, for: service)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characteristics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Characteristic", for: indexPath)

        let c = characteristics[indexPath.row]
        cell.textLabel?.text = "UUID: \(c.uuid.uuidString)"
        cell.detailTextLabel?.text = c.value == nil ? "Value: [none]" : "Value: \(c.value!.hexadecimalString().stringFromHexadecimalStringUsingEncoding(encoding: String.Encoding.utf8)!)"
        return cell
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let e = error {
            print("Failed to discover characteristics: \(e.localizedDescription)")
            
            UIAlertView(
                title: "Characteristics failed",
                message: "Failed to discover characteristics: \(e.localizedDescription)",
                delegate: nil,
                cancelButtonTitle: "OK")
                .show()
            return
        }
        
        if let serviceCharacteristics = service.characteristics {
            for characteristic in serviceCharacteristics {
                print("Characteristic discovered: \(characteristic)")
                
                characteristics.append(characteristic)
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        self.tableView.reloadData()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
            print("Failed to update value for characteristic: \(e.localizedDescription)")
            return
        }
        
        print("Value for characteristic \(characteristic.uuid.uuidString) is: \(String(describing: characteristic.value))")
        
        self.tableView.reloadData()
    }
}
