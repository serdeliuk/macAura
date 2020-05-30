//
//  AppDelegate.swift
//  macAura
//
//  Created by Marc on 02/01/2020.
//  Copyright © 2020 Marc Serdeliuk, serdeliuk@yahoo.com . All rights reserved.
//
//


import Cocoa

var path = Bundle.main.path(forResource: "Product", ofType: "plist")
var dict = NSDictionary(contentsOfFile: path!)

let ProductID = dict!.object(forKey: "asusProductID")

//var ProductID = Bundle.main.object(forInfoDictionaryKey: "asusProductID") as! NSNumber

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    

    //    make sure that ROG_DeviceMonitor always exist
    let ROG_DeviceMonitor = USBDeviceMonitor([
        USBMonitorData(vendorId: 0x0B05, productId: ProductID as! UInt16)
        ])
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let ROG_DeviceDaemon = Thread(target: ROG_DeviceMonitor, selector:#selector(ROG_DeviceMonitor.start), object: nil)
        ROG_DeviceDaemon.start()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}


