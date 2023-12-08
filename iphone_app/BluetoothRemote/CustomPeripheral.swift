//
//  CustomPeripheral.swift
//  BluetoothRemote
//
//  Created by Me on 5/12/23.
//

import UIKit
import CoreBluetooth

class CustomPeripheral: NSObject {
    
    public static let customServiceUUID = CBUUID.init(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    public static let directionCharacteristicUUID = CBUUID.init(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    
}
