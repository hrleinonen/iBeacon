//
//  ViewController.swift
//  My iBeacon
//
//  Created by Ville Leinonen on 25.8.2020.
//  Use under GPL.
//

import UIKit
import CoreBluetooth
import CoreLocation



class ViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var iStatus: UILabel!

    @IBOutlet weak var iDistance: UILabel!
    
    @IBOutlet weak var mDistance: UILabel!

    @IBOutlet weak var RSSI: UILabel!
    
    @IBOutlet weak var userUUID: UILabel!
    
    @IBOutlet weak var userMajor: UILabel!
    
    @IBOutlet weak var userMinor: UILabel!
    
    // Access Shared Defaults Object
    let userDefaults = UserDefaults.standard
    
    // Needed to location and permissions.
    var locationManager = CLLocationManager()
    var foundBeacons = [CLBeacon]()

    var beaconRegion: CLBeaconRegion!
    var beaconRegionConstraints: CLBeaconIdentityConstraint!

    var isRanging = false

    var notificationIsBlocked = false
    var notificationTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
        }
        UNUserNotificationCenter.current().delegate = self

        locationManager.delegate = self
        
        // Check if user has already done setup, if not then setup default values
        let  setupSettings = userDefaults.object(forKey: "settingsDone")

        if (setupSettings == nil) {
            print("Debug")
            let dictionary = [
                "UUID": "00000000-0000-0000-0000-000000000000",
                "Name": "Not yet implemented",
                "Major": "0",
                "Minor": "0"
            ]
            
            userDefaults.set(dictionary, forKey: "iBeacons")
        }
    
        // Read userdefaults
        let dict = userDefaults.object(forKey: "iBeacons") as? [String: String] ?? [String: String]()

        let usrMajor = UInt16(dict["Major"]!) ?? 0
        let usrMinor = UInt16(dict["Minor"]!) ?? 0
        let usrUUID = dict["UUID"]!
        
        userUUID.text = "\(dict["UUID"]!)"
        userMajor.text = "\(dict["Major"]!)"
        userMinor.text = "\(dict["Minor"]!)"
        
        let uuid = UUID(uuidString: usrUUID)!
        
        beaconRegion = CLBeaconRegion(uuid: uuid, major: usrMajor, minor: usrMinor, identifier: uuid.uuidString)
        
        beaconRegionConstraints = CLBeaconIdentityConstraint(uuid: uuid, major: usrMajor, minor: usrMinor)

        // Need authorization for location, if now allowed request it, otherwise
        // start monitoring beacons.
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.startMonitoring(for: beaconRegion)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            if !locationManager.monitoredRegions.contains(beaconRegion) {
                locationManager.startMonitoring(for: beaconRegion)
                //print("BT authorisation always granted")
            }
        case .authorizedWhenInUse:
            if !locationManager.monitoredRegions.contains(beaconRegion) {
                locationManager.startMonitoring(for: beaconRegion)
            }
        default:
            
            print("BT authorisation not granted")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            locationManager.startRangingBeacons(satisfying: beaconRegionConstraints)
            isRanging = true
            postNotification()
        } else {
            isRanging = false
            iStatus.text = "Not in range"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // For future use
        // print("Did start monitoring region: \(region)\n")
        // tableView.reloadData()
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        locationManager.startRangingBeacons(satisfying: beaconRegionConstraints)
        iStatus.text = "Enter in range"

        //tableView.reloadData()
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        locationManager.stopRangingBeacons(satisfying: beaconRegionConstraints)
        iStatus.text = "Exit in range"
        foundBeacons = []
    }
    

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            updateDistance(beacons[0].proximity)
            
            let  mDistanceFormated = String(format: "%.2f", beacons[0].accuracy)
            
            mDistance.text = "\(mDistanceFormated)"
            RSSI.text = "\(beacons[0].rssi)"
  
        } else {
            updateDistance(.unknown)
        }

    }
    
    func updateDistance(_ distance: CLProximity) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .unknown:
                self.iDistance.text = "Unknown"

            case .far:
                self.iDistance.text = "Far"

            case .near:
                self.iDistance.text = "Near"

            case .immediate:
                self.iDistance.text = "Very Close"
                
            @unknown default:
                self.iDistance.text = "Error Unknown"
            }
        }
    }

    func postNotification() {
        iStatus.text = "Is in range"
    }
  
}

