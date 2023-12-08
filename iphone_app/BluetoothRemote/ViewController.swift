//
//  ViewController.swift
//  BluetoothRemote
//
//  Created by Me on 5/12/23.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var directionChar: CBCharacteristic?
    //private var leftRightChar: CBCharacteristic?
    
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Not powered on")
        }
        else {
            print("Central scanning for peripheral")
            centralManager.scanForPeripherals(withServices: [CustomPeripheral.customServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "mpy-uart" {
            self.centralManager.stopScan()
            self.peripheral = peripheral
            self.peripheral.delegate = self
            self.centralManager.connect(self.peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            print("Connected, let's scan for services")
            peripheral.discoverServices([CustomPeripheral.customServiceUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnected")
        setButtons(state: false)
        if central.state != .poweredOn {
            print("Not powered on")
        }
        else {
            print("Central scanning for peripheral")
            centralManager.scanForPeripherals(withServices: [CustomPeripheral.customServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == CustomPeripheral.customServiceUUID {
                    print( "Custom service found")
                    peripheral.discoverCharacteristics(nil, for: service)
                    return
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == CustomPeripheral.directionCharacteristicUUID {
                    print("Direction characteristic found")
                    directionChar = characteristic
                    setButtons(state: true)
                }

            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtons(state: false)

        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func setButtons(state: Bool) {
        forwardButton.isEnabled = state
        backButton.isEnabled = state
        leftButton.isEnabled = state
        rightButton.isEnabled = state
        statusLabel.isHidden = state
    }
    
    private func writeValueToChar( withCharacteristic characteristic: CBCharacteristic, withValue value: Data) {

                // Check if it has the write property
                if characteristic.properties.contains(.writeWithoutResponse) && peripheral != nil {

                    peripheral.writeValue(value, for: characteristic, type: .withoutResponse)

                }

            }
    
    // Actions
    @IBAction func forwardStopped(_ sender: Any) {
        let direction:UInt8 = UInt8(0)
        writeValueToChar(withCharacteristic: directionChar!, withValue: Data([direction]))
    }
    @IBAction func forwardPressed(_ sender: Any) {
        let direction:UInt8 = UInt8(1)
        writeValueToChar(withCharacteristic: directionChar!, withValue: Data([direction]))
    }
    
    @IBAction func goBack(_ sender: Any) {
        let direction:UInt8 = UInt8(2)
        writeValueToChar(withCharacteristic: directionChar!, withValue: Data([direction]))
    }
    @IBAction func backStopped(_ sender: Any) {
        let direction:UInt8 = UInt8(0)
        writeValueToChar(withCharacteristic: directionChar!, withValue: Data([direction]))
    }
    
    @IBAction func goLeft(_ sender: Any) {
        let direction:UInt8 = UInt8(3)
        writeValueToChar(withCharacteristic: directionChar!, withValue: Data([direction]))
    }
    
    @IBAction func leftStopped(_ sender: Any) {
        let direction:UInt8 = UInt8(0)
        writeValueToChar(withCharacteristic: directionChar!, withValue: Data([direction]))
    }
    @IBAction func goRight(_ sender: Any) {
        let direction:UInt8 = UInt8(4)
        writeValueToChar(withCharacteristic: directionChar!, withValue: Data([direction]))
    }
    @IBAction func rightStopped(_ sender: Any) {
        let direction:UInt8 = UInt8(0)
        writeValueToChar(withCharacteristic: directionChar!, withValue: Data([direction]))
    }
    
    
    
}

