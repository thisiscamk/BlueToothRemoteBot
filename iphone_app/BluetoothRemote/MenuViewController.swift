//
//  MenuViewController.swift
//  BluetoothRemote
//
//  Created by Me on 11/12/23.
//

import Foundation
import UIKit

var mode = 2
class MenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func topButtonSelected(_ sender: Any) {
        mode = 2
        self.performSegue(withIdentifier: "goToController", sender: self)
    }
    
    @IBAction func bottomButtonSelected(_ sender: Any) {
        mode = 3
        self.performSegue(withIdentifier: "goToController", sender: self)
    }
    
}
