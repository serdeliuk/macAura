//
//  ViewController.swift
//  macAura
//
//  Created by marc on 27/11/2019.
//  Copyright © 2019 Marc Serdeliuk, serdeliuk@yahoo.com . All rights reserved.
//

import Cocoa

//--------------------------------------------------√-R---√-G---√-B---RGB bits
var iAura_COLOR:[UInt8] = [0x5d, 0xb3, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
//-------------------------------------------------√-INTENSITY bit, between 0 to 3
var iAura_BRIGH:[UInt8] = [0x5a, 0xba, 0xc5, 0xc4, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
//----- controller save-set where apply store data into controller to be available during boot time after a power cycle
var iAura_APPLY:[UInt8] = [0x5d, 0xb4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
var iAura_SET__:[UInt8] = [0x5d, 0xb5, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]

enum ROG_REQUEST:UInt8 {
    case DETACH=0x00
    case DNLOAD=0x01
    case UPLOAD=0x02
    case GETSTATUS=0x03
    case CLRSTATUS=0x04
    case GETSTAT=0x05
    case ABORT=0x06
    case SEND=0x09
}

enum ROG_DeviceError: Error {
    case DeviceInterfaceNotFound
    case InvalidData(desc:String)
    case RequestError(desc:String)
}

class ROG_Device {
    var deviceInfo:USBDevice
    
    required init(_ deviceInfo:USBDevice) {
        self.deviceInfo = deviceInfo
    }
    
    func setLeds() throws -> [UInt8] {
        //Getting device interface from our pointer
        guard let deviceInterface = self.deviceInfo.deviceInterfacePtrPtr?.pointee?.pointee else {
            throw ROG_DeviceError.DeviceInterfaceNotFound
        }
        
        var kr:Int32 = 0
        let length:Int = 17
        //let requestPtr:[UInt8] = [UInt8](repeating: 0, count: length)
        // Creating request
        var request = IOUSBDevRequest(bmRequestType: 0x21,
                                      bRequest: ROG_REQUEST.SEND.rawValue,
                                      wValue: 0x035d,
                                      wIndex: 0,
                                      wLength: UInt16(length),
                                      pData: &iAura_COLOR,
                                      wLenDone: 255)
        
        kr = deviceInterface.DeviceRequest(self.deviceInfo.deviceInterfacePtrPtr, &request)
        
        if (kr != kIOReturnSuccess) {
            throw ROG_DeviceError.RequestError(desc: "Get device status request error: \(kr)")
        }
        
        return iAura_COLOR
    }
    
    func setLedsBrightness() throws -> [UInt8] {
        //Getting device interface from our pointer
        guard let deviceInterface = self.deviceInfo.deviceInterfacePtrPtr?.pointee?.pointee else {
            throw ROG_DeviceError.DeviceInterfaceNotFound
        }
        
        var kr:Int32 = 0
        let length:Int = 17
        //let requestPtr:[UInt8] = [UInt8](repeating: 0, count: length)
        // Creating request
        var request = IOUSBDevRequest(bmRequestType: 0x21,
                                      bRequest: ROG_REQUEST.SEND.rawValue,
                                      wValue: 0x035d,
                                      wIndex: 0,
                                      wLength: UInt16(length),
                                      pData: &iAura_BRIGH,
                                      wLenDone: 255)
        
        kr = deviceInterface.DeviceRequest(self.deviceInfo.deviceInterfacePtrPtr, &request)
        
        if (kr != kIOReturnSuccess) {
            throw ROG_DeviceError.RequestError(desc: "Get device status request error: \(kr)")
        }
        
        return iAura_BRIGH
    }
    
    func apply_iAura() throws -> [UInt8] {
        //Getting device interface from our pointer
        guard let deviceInterface = self.deviceInfo.deviceInterfacePtrPtr?.pointee?.pointee else {
            throw ROG_DeviceError.DeviceInterfaceNotFound
        }
        
        var kr:Int32 = 0
        let length:Int = 17
        //let requestPtr:[UInt8] = [UInt8](repeating: 0, count: length)
        // Creating request
        var request = IOUSBDevRequest(bmRequestType: 0x21,
                                      bRequest: ROG_REQUEST.SEND.rawValue,
                                      wValue: 0x035d,
                                      wIndex: 0,
                                      wLength: UInt16(length),
                                      pData: &iAura_SET__,
                                      wLenDone: 255)
        
        kr = deviceInterface.DeviceRequest(self.deviceInfo.deviceInterfacePtrPtr, &request)
        
        if (kr != kIOReturnSuccess) {
            throw ROG_DeviceError.RequestError(desc: "Get device status request error: \(kr)")
        }

        var request2 = IOUSBDevRequest(bmRequestType: 0x21,
                                      bRequest: ROG_REQUEST.SEND.rawValue,
                                      wValue: 0x035d,
                                      wIndex: 0,
                                      wLength: UInt16(length),
                                      pData: &iAura_APPLY,
                                      wLenDone: 255)
        
        kr = deviceInterface.DeviceRequest(self.deviceInfo.deviceInterfacePtrPtr, &request2)
        
        if (kr != kIOReturnSuccess) {
            throw ROG_DeviceError.RequestError(desc: "Get device status request error: \(kr)")
        }

        return iAura_APPLY
    }


}

