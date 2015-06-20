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
    
    override func viewDidAppear(animated: Bool) {
        // Re-start scan after coming back from background
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Remove all services from the table and array (they will be re-discovered upon viewDidAppear)
        services.removeAll(keepCapacity: false)
        tableView.reloadData()
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        
        if let e = error {
            println("Failed to discover services: \(e.localizedDescription)")
            
            UIAlertView(
                title: "Services failed",
                message: "Failed to discover services: \(e.localizedDescription)",
                delegate: nil,
                cancelButtonTitle: "OK")
                .show()
            return
        }
        
        for service in peripheral.services as! [CBService] {
            services.append(service)
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Service", forIndexPath: indexPath) as! UITableViewCell
        
        let s = services[indexPath.row]
        cell.textLabel?.text = "UUID: \(s.UUID.UUIDString)"
        cell.detailTextLabel?.text = s.isPrimary ? "This is the primary service" : ""

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        service = services[indexPath.row]
        performSegueWithIdentifier("Characteristics", sender: self)
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let characteristicsTVC = segue.destinationViewController as! CharacteristicsTVC
        characteristicsTVC.peripheral = self.peripheral
        characteristicsTVC.service = self.service
    }

}
