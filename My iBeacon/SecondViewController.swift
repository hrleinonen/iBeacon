//
//  SecondViewController.swift
//  My iBeacon
//
//  Created by Ville Leinonen on 2.9.2020.
//  Use under GPL.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var addUUID: UITextField!
    
    @IBOutlet weak var addName: UITextField!
    
    @IBOutlet weak var addMajor: UITextField!
    
    @IBOutlet weak var addMinor: UITextField!
    
    
    // Access Shared Defaults Object
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Read userdefaults
        let dict = userDefaults.object(forKey: "iBeacons") as? [String: String] ?? [String: String]()
        
        // Show values in the text fields.
        addUUID.text = dict["UUID"]!
        addMajor.text = dict["Major"]!
        addMinor.text = dict["Minor"]!
        
        if (addUUID.text?.isEmpty != false) {
            addUUID.text = "9f7c5686-b43d-49dc-abb5-7f211ef0ce8d"
        }
        if (addMajor.text?.isEmpty != false) {
            addMajor.text = "99"
        }
        if (addMinor.text?.isEmpty != false) {
            addMinor.text = "99"
        }
    
    }
    
    // Save button
    @IBAction func saveBeacon(_ sender: Any) {
        print("Save pressed")
        print("Annettu data \(addUUID.text!) \(addName.text!) \(addMajor.text!) \(addMinor.text!)")
        
        let dictionary = [
            "UUID": "\(addUUID.text!)",
            "Name": "\(addName.text!)",
            "Major": "\(addMajor.text!)",
            "Minor": "\(addMinor.text!)"
        ]
        
        //userDefaults.set(dictionary, forKey: "\(addName.text!)")
        // Save userDefaults
        userDefaults.set(dictionary, forKey: "iBeacons")
        
        // Custom userdefaults is set
        let setupSettings = 1
        userDefaults.set(setupSettings, forKey: "settingsDone")
        
        //dictionary.forEach { print($0) }
        
        UIApplication.shared.endEditing() // Call to dismiss keyboard
    }
    
    // Close keyboard if pressed outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        addUUID.resignFirstResponder()
        addName.resignFirstResponder()
        addMajor.resignFirstResponder()
        addMinor.resignFirstResponder()
    }
    
}

// extension for keyboard to dismiss
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// extension for keyboard to dismiss if return is pressed (not working)
extension ViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
