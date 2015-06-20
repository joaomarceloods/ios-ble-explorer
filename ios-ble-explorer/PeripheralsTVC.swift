//
//  PeripheralsTVC.swift
//  BluetoothDiscovery
//
//  Created by João Marcelo on 19/06/15.
//  Copyright (c) 2015 João Marcelo Oliveira. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralsTVC: UITableViewController, CBCentralManagerDelegate {

    // CoreBluetooth Central Manager
    var centralManager:CBCentralManager!
    
    // All peripherals in Central Manager
    var peripherals = [CBPeripheral]()
    
    // Peripheral chosen by user
    var peripheral:CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This will trigger centralManagerDidUpdateState
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        // Re-start scan after coming back from background
        if centralManager.state == .PoweredOn {
            centralManager.scanForPeripheralsWithServices(nil, options: nil)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Stop scan to save battery when entering background
        centralManager.stopScan()
        
        // Remove all peripherals from the table and array (they will be re-discovered upon viewDidAppear)
        peripherals.removeAll(keepCapacity: false)
        self.tableView.reloadData()
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        println("Central Manager did update state")
        
        if (central.state == .PoweredOn) {
            println("Bluetooth is powered on")
            
            // Scan for any peripherals
            centralManager.scanForPeripheralsWithServices(nil, options: nil)
        }
        else {
            // Bluetooth is unavailable for some reason
            
            // Give feedback
            var message = String()
            switch central.state {
            case .Unsupported:
                message = "Bluetooth is unsupported"
            case .Unknown:
                message = "Bluetooth state is unkown"
            case .Unauthorized:
                message = "Bluetooth is unauthorized"
            case .PoweredOff:
                message = "Bluetooth is powered off"
            default:
                break
            }
            println(message)
            
            UIAlertView(
                title: "Bluetooth unavailable",
                message: message,
                delegate: nil,
                cancelButtonTitle: "OK")
                .show()
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("Peripheral discovered: \(peripheral)")
        
        // Add the peripheral to the array to keep reference, otherwise the system will release it and further delegate methods won't be triggered (didConnect, didFail...)
        peripherals.append(peripheral)
        self.tableView.reloadData()
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("Peripheral connected: \(peripheral)")
        
        centralManager.stopScan()
        
        // Keep reference to be used in prepareForSegue
        self.peripheral = peripheral
        performSegueWithIdentifier("Services", sender: self)
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Peripheral failed to connect: \(peripheral)")
        
        // Give feedback
        UIAlertView(
            title: "Peripheral failed",
            message: "Peripheral failed to connect: \(error.localizedDescription)",
            delegate: nil,
            cancelButtonTitle: "OK")
            .show()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Peripheral", forIndexPath: indexPath) as! UITableViewCell

        let p = peripherals[indexPath.row]
        cell.textLabel?.text = p.name.isEmpty ? "[Unkown name]" : p.name
        cell.detailTextLabel?.text = "UUID: \(p.identifier.UUIDString)"

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        centralManager.connectPeripheral(peripherals[indexPath.row], options: nil)
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let servicesTVC = segue.destinationViewController as! ServicesTVC
        servicesTVC.peripheral = self.peripheral
    }


}
