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
    private var leftRightDirectionChar: CBCharacteristic?
    private var forwardBackDirectionChar: CBCharacteristic?

    var customServiceUUID: CBUUID = CBUUID.init()
    var leftRightDirectionCharacteristicUUID = CBUUID.init()
    var forwardBackDirectionCharacteristicUUID = CBUUID.init()
    let centreValue = 100

    

    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var leftRightSlider: UISlider!
    @IBOutlet weak var forwardBackSlider: UISlider!
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Not powered on")
        }
        else {
            //print("Central scanning for peripheral")
            centralManager.scanForPeripherals(withServices: [customServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
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
            //print("Connected, let's scan for services")
            peripheral.discoverServices([customServiceUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //print("disconnected")
        setButtons(state: false)
        if central.state != .poweredOn {
            //print("Not powered on")
        }
        else {
            //print("Central scanning for peripheral")
            centralManager.scanForPeripherals(withServices: [customServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == customServiceUUID {
                    //print( "Custom service found")
                    peripheral.discoverCharacteristics(nil, for: service)
                    return
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == leftRightDirectionCharacteristicUUID {
                    //print("Left-right characteristic found")
                    leftRightDirectionChar = characteristic
                    setButtons(state: true)
                }
                else if characteristic.uuid == forwardBackDirectionCharacteristicUUID {
                    //print("Forward-back characteristic found")
                    forwardBackDirectionChar = characteristic
                    setButtons(state: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        forwardBackSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        setButtons(state: false)
        if mode == 3 {
            customServiceUUID = CBUUID.init(string: "6E500001-B5A3-F393-E0A9-E50E24DCCA9E")
            leftRightDirectionCharacteristicUUID = CBUUID.init(string: "6E500002-B5A3-F393-E0A9-E50E24DCCA9E")
            forwardBackDirectionCharacteristicUUID = CBUUID.init(string: "6E500003-B5A3-F393-E0A9-E50E24DCCA9E")
        }
        else {
            customServiceUUID = CBUUID.init(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
            leftRightDirectionCharacteristicUUID = CBUUID.init(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
            forwardBackDirectionCharacteristicUUID = CBUUID.init(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
        }

        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)

    }
    
    func setButtons(state: Bool) {
        statusLabel.isHidden = state
        leftRightSlider.isEnabled = state
        forwardBackSlider.isEnabled = state
    }
    
    private func writeValueToChar( withCharacteristic characteristic: CBCharacteristic, withValue value: Data) {

                // Check if it has the write property
                if characteristic.properties.contains(.writeWithoutResponse) && peripheral != nil {

                    peripheral.writeValue(value, for: characteristic, type: .withoutResponse)

                }

            }
    
    func leftRightDirection(dirValue: Int) {
        let direction:UInt8 = UInt8(dirValue)
        writeValueToChar(withCharacteristic: leftRightDirectionChar!, withValue: Data([direction]))
    }
    
    func forwardBackDirection(dirValue: Int) {
        let direction:UInt8 = UInt8(dirValue)
        writeValueToChar(withCharacteristic: forwardBackDirectionChar!, withValue: Data([direction]))
    }
    
    // Actions
    @IBAction func leftRightValueChanged(_ sender: Any) {
        leftRightDirection(dirValue: Int(leftRightSlider.value))
    }
    @IBAction func leftRightTouchUpOutside(_ sender: Any) {
        //print("touch up outside")
        leftRightSlider.value = Float(centreValue)
        leftRightDirection(dirValue: centreValue)
    }
    @IBAction func leftRightTouchUpInside(_ sender: Any) {
        //print("touch up inside")
        leftRightSlider.value = Float(centreValue)
        leftRightDirection(dirValue: centreValue)
    }
    @IBAction func forwardBackValueChanged(_ sender: Any) {
        forwardBackDirection(dirValue: Int(forwardBackSlider.value))
    }
    @IBAction func forwardBackTouchUpOutside(_ sender: Any) {
        forwardBackSlider.value = Float(centreValue)
        forwardBackDirection(dirValue: centreValue)
    }
    @IBAction func forwardBackTouchUpInside(_ sender: Any) {
        forwardBackSlider.value = Float(centreValue)
        forwardBackDirection(dirValue: centreValue)
    }
    
    
    
    
    
}

