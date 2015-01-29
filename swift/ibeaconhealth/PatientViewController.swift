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

class PatientViewController: UIViewController, CBPeripheralManagerDelegate, UITextViewDelegate {
    
    @IBOutlet var txtOutput: UITextView!
    
    var peripheralManager: CBPeripheralManager?
    var transferCharacteristic: CBMutableCharacteristic?
    var dataToSend: NSData?
    var sendDataIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        peripheralManager!.stopAdvertising()
        super.viewWillDisappear(animated)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        if (peripheral.state != CBPeripheralManagerState.PoweredOn) {
            return
        }
        NSLog("Powered ON")
        
        transferCharacteristic = CBMutableCharacteristic(type: CBUUID(string: Constants.TransferCharacteristicUUID),
            properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
        
        let transferService = CBMutableService(type: CBUUID(string: Constants.TransferServiceUUID), primary: true)
        transferService.characteristics = NSArray(object: transferCharacteristic!)
        peripheralManager!.addService(transferService)

    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
        NSLog("Central subscribed to characteristic")
        dataToSend = txtOutput.text.dataUsingEncoding(NSUTF8StringEncoding)
        sendDataIndex = 0
        sendData()
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic!) {
        NSLog("Central unsubscribed from characteristic")
    }
    
    var sendingEOM = false
    func sendData() {
        if (sendingEOM) {
            
            let didSend = peripheralManager!.updateValue("EOM".dataUsingEncoding(NSUTF8StringEncoding), forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
            if (didSend) {
                sendingEOM = false
                NSLog("Sent: EOM")
            }
            return
        }
        
        if (sendDataIndex >= dataToSend!.length) {
            return
        }
        
        var didSend = true
        while (didSend) {
            var amountToSend = dataToSend!.length - sendDataIndex
            
            if (amountToSend > Constants.NotifyMTU) {
                amountToSend = Constants.NotifyMTU
            }
            
            let chunk = NSData(bytes: UnsafePointer<UInt8>(dataToSend!.bytes) + sendDataIndex, length: amountToSend)
            didSend = peripheralManager!.updateValue(chunk, forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
            if (!didSend) {
                return
            }
            
            let stringFromData = NSString(data: chunk, encoding: NSUTF8StringEncoding)
            NSLog("Sent: \(stringFromData)")
            
            sendDataIndex += amountToSend
            
            if (sendDataIndex >= dataToSend!.length) {
                sendingEOM = true
                let eomSent = peripheralManager!.updateValue("EOM".dataUsingEncoding(NSUTF8StringEncoding), forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
                if (eomSent) {
                    sendingEOM = true
                    NSLog("Sent: EOM")
                }
                return
            }
        }
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager!) {
        sendData()
    }
    
    @IBAction func energyChanged(swEnergy: UISwitch) {
        if (swEnergy.on) {
            peripheralManager!.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: Constants.TransferServiceUUID)]])
        } else {
            peripheralManager!.stopAdvertising()
        }
    }

    @IBAction func generateRandomValues(sender: AnyObject) {
        
        let f1 = ((Float(rand()) / Float(RAND_MAX)) * 3.0) + 2.0
        let f2 = ((Float(rand()) / Float(RAND_MAX)) * 5) + 10
        let i1 = Int(((Float(rand()) / Float(RAND_MAX)) * 30) + 20)
        let i2 = Int(((Float(rand()) / Float(RAND_MAX)) * 4000) + 1000)
        
        txtOutput.text = "Hematíes: \(f1) millones\nHemoglobina: \(f2) millones\nHematocrito: \(i1)\nLinfocitos: \(i2)"

    }
    
}

