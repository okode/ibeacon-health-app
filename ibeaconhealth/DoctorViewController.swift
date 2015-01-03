/**
 * Copyright 2015 Okode | www.okode.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import CoreBluetooth
import AudioToolbox

class DoctorViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
                            
    @IBOutlet var txtOutput : UITextView
    var centralManager: CBCentralManager?
    var discoveredPeripheral: CBPeripheral?
    var data: NSMutableData = NSMutableData()
    var lastPatientData: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        centralManager!.stopScan()
        NSLog("Scanning stopped")
        super.viewWillDisappear(animated)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if (central.state != CBCentralManagerState.PoweredOn) {
            return;
        }
        scan()
    }
    
    func scan() {
        centralManager!.scanForPeripheralsWithServices([CBUUID.UUIDWithString(Constants.TransferServiceUUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        NSLog("Scanning started");
    }

    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: NSDictionary!, RSSI: NSNumber!) {
        if (RSSI.integerValue > -15) {
            return;
        }
        
        if (RSSI.integerValue < -35) {
            return;
        }
        
        NSLog("Discovered \(peripheral.name) at \(RSSI)");
        
        if (self.discoveredPeripheral != peripheral) {
            self.discoveredPeripheral = peripheral;
            NSLog("Connecting to peripheral \(peripheral)");
            centralManager!.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        NSLog("Failed to connect to \(peripheral). (\(error.localizedDescription))")
        cleanup()
    }
    
    func cleanup() {
        
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        NSLog("Peripheral Connected");
        centralManager!.stopScan()
        NSLog("Scanning stopped");
        data.length = 0
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID.UUIDWithString(Constants.TransferServiceUUID)])
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if (error) {
            NSLog("Error discovering services: \(error.localizedDescription)")
            cleanup()
            return;
        }
        
        for service in peripheral.services as CBService[] {
            peripheral.discoverCharacteristics([CBUUID.UUIDWithString(Constants.TransferCharacteristicUUID)], forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if (error) {
            NSLog("Error discovering characteristics: \(error.localizedDescription)")
            cleanup()
            return;
        }
        
        for characteristic in service.characteristics as CBCharacteristic[] {
            if (characteristic.UUID == CBUUID.UUIDWithString(Constants.TransferCharacteristicUUID)) {
                peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if (error) {
            NSLog("Error discovering characteristics: \(error.localizedDescription)")
            return;
        }

        let stringFromData = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding)

        if (stringFromData == "EOM") {
            let newPatientData = NSString(data: data, encoding: NSUTF8StringEncoding)
            if (lastPatientData != newPatientData) {
                AudioServicesPlaySystemSound(1255)
                
                let notification = UILocalNotification()
                notification.fireDate =  NSDate(timeIntervalSinceNow: 0)
                notification.alertBody = "Nuevos datos de paciente capturados"
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.alertAction = "MAPFRE Salud"
                notification.hasAction = true;
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }

            txtOutput.text = newPatientData
            lastPatientData = newPatientData
            peripheral.setNotifyValue(false, forCharacteristic: characteristic)
            centralManager!.cancelPeripheralConnection(peripheral)
        }
        
        data.appendData(characteristic.value)
        NSLog("Received: \(stringFromData)");
    }
    
}

