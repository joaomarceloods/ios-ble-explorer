//
//  ServicesTVC.swift
//  BluetoothDiscovery
//
//  Created by João Marcelo on 19/06/15.
//  Copyright (c) 2015 João Marcelo Oliveira. All rights reserved.
//

import UIKit
import CoreBluetooth

class ServicesTVC: UITableViewController, CBPeripheralDelegate {
    
    // Connected peripheral
    var peripheral: CBPeripheral!
    
    // All services in the connected peripheral
    var services = [CBService]()
    
    // Service chosen by user
    var service: CBService!
    
    override func viewDidAppear(_ animated: Bool) {
        // Re-start scan after coming back from background
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Remove all services from the table and array (they will be re-discovered upon viewDidAppear)
        services.removeAll(keepingCapacity: false)
        tableView.reloadData()
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let e = error {
            print("Failed to discover services: \(e.localizedDescription)")
            
            UIAlertView(
                title: "Services failed",
                message: "Failed to discover services: \(e.localizedDescription)",
                delegate: nil,
                cancelButtonTitle: "OK")
                .show()
            return
        }
        
        if let peripheralServices = peripheral.services {
            for service in peripheralServices {
                services.append(service)
            }
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Service", for: indexPath)
        
        let s = services[indexPath.row]
        cell.textLabel?.text = "UUID: \(s.uuid.uuidString)"
        cell.detailTextLabel?.text = s.isPrimary ? "This is the primary service" : ""

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        service = services[indexPath.row]
        performSegue(withIdentifier: "Characteristics", sender: self)
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let characteristicsTVC = segue.destination as! CharacteristicsTVC
        characteristicsTVC.peripheral = self.peripheral
        characteristicsTVC.service = self.service
    }
}
