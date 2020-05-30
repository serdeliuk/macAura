//
//  ViewController.swift
//  macAura
//
//  Created by Marc on 02/01/2020.
//  Copyright © 2020 Marc Serdeliuk, serdeliuk@yahoo.com . All rights reserved.
//
//

import Cocoa

class ViewController: NSViewController, NSComboBoxDataSource {
    
    
    @IBAction func radioButtonChanged(_ sender: AnyObject) {
        if one.state.rawValue == 1 {
            iAura_COLOR[2] = 1
        } else if two.state.rawValue == 1 {
            iAura_COLOR[2] = 8
        } else if three.state.rawValue == 1 {
            iAura_COLOR[2] = 7
        } else if four.state.rawValue == 1 {
            iAura_COLOR[2] = 9
        } else {
            iAura_COLOR[2] = 00
        }
    }
    
    @IBOutlet weak var one: NSButton!
    @IBOutlet weak var two: NSButton!
    @IBOutlet weak var three: NSButton!
    @IBOutlet weak var four: NSButton!
    @IBOutlet weak var all: NSButton!
    @IBOutlet weak var devicesComboBox: NSComboBox!
    @IBOutlet weak var connectButton: NSButton!
    @IBOutlet weak var connectedDeviceLabel: NSTextField!
    @IBOutlet weak var dfuDeviceView: NSView!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet weak var amountLabel: NSTextField!
    @IBOutlet weak var amountSlider: NSSlider!
    @IBAction func save2acpi(_ sender: Any) {
        do {
            let status = try self.connectedDevice?.apply_iAura()
            print(status as Any)
        } catch {
            print(error)
        }
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        let ammount = amountSlider.integerValue
        amountLabel.stringValue = "\(ammount)"
        do {
            iAura_BRIGH[4] = UInt8(ammount)
            let status = try self.connectedDevice?.setLedsBrightness()
            print(status as Any)
        } catch {
            print(error)
        }
    }
    
    @IBAction func colorChanged( sender: NSColorWell ) {
        let colorString = stringForColorWell( colorWell: sender )
        //        print(self.get_numbers(stringtext: colorString))
        var colorsArr = self.get_numbers(stringtext: colorString)
        do {
            iAura_COLOR[4] = UInt8(colorsArr[0])
            iAura_COLOR[5] = UInt8(colorsArr[1])
            iAura_COLOR[6] = UInt8(colorsArr[2])
            
            let status = try self.connectedDevice?.setLeds()
            print(status as Any)
        } catch {
            print(error)
        }
    }
    private func get_numbers(stringtext:String) -> [Int] {
        let StringRecordedArr = stringtext.components(separatedBy: ",")
        return StringRecordedArr.map { Int($0)!}
    }
    
    private func stringForColorWell( colorWell: NSColorWell ) -> String {
        if let color = colorWell.color.usingColorSpaceName(NSColorSpaceName.calibratedRGB) {
            var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
            color.getRed( &r, green:&g, blue:&b, alpha:&a )
            return "\(Int(r * 255)),\(Int(g * 255)),\(Int(b * 255))"
            
        } else {
            print("colorUsingColorSpaceName error" )
            return "1,1,1"
        }
    }
    
    @IBAction func connectDevice(_ sender: Any) {
        DispatchQueue.main.async {
            if (self.devices.count > 0) {
                if (self.connectedDevice != nil) {
                    self.connectButton.title = "Connect"
                    self.devicesComboBox.isEnabled = true
                    self.connectedDevice = nil
                    self.dfuDeviceView.isHidden = true
                } else {
                    self.connectButton.title = "Disconnect"
                    self.devicesComboBox.isEnabled = false
                    self.connectedDevice = self.devices[self.devicesComboBox.integerValue]
                    self.connectedDeviceLabel.stringValue = "Connected to: \(self.connectedDevice!.deviceInfo.name) (\(self.connectedDevice!.deviceInfo.vendorId), \(self.connectedDevice!.deviceInfo.productId))"
                    self.dfuDeviceView.isHidden = false
                }
            }
        }
    }
    
    var connectedDevice:ROG_Device?
    var devices:[ROG_Device] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        sliderChanged(self)
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.usbConnected), name: .USBDeviceConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.usbDisconnected), name: .USBDeviceDisconnected, object: nil)
        
        self.devicesComboBox.isEditable = false
        self.devicesComboBox.completes = false
        self.dfuDeviceView.isHidden = true
        self.devicesComboBox.reloadData()
        // Set the radio group's initial selection
        all.state = NSControl.StateValue.on
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return self.devices.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return self.devices[index].deviceInfo.name
    }
    
    @objc func usbConnected(notification: NSNotification) {
        guard let nobj = notification.object as? NSDictionary else {
            return
        }
        
        guard let deviceInfo:USBDevice = nobj["device"] as? USBDevice else {
            return
        }
        let device = ROG_Device(deviceInfo)
        DispatchQueue.main.async {
            self.devices.append(device)
            self.devicesComboBox.reloadData()
        }
    }
    
    @objc func usbDisconnected(notification: NSNotification) {
        guard let nobj = notification.object as? NSDictionary else {
            return
        }
        
        guard let id:UInt64 = nobj["id"] as? UInt64 else {
            return
        }
        DispatchQueue.main.async {
            if let index = self.devices.index(where: { $0.deviceInfo.id == id }) {
                self.devices.remove(at: index)
                if (id == self.connectedDevice?.deviceInfo.id) {
                    self.connectButton.title = "Connect"
                    self.devicesComboBox.isEnabled = true
                    self.connectedDevice = nil
                    self.dfuDeviceView.isHidden = true
                }
            }
            self.devicesComboBox.reloadData()
        }
    }
    
    @objc func refreshu() {
        self.devicesComboBox.reloadData()
    }
    
}

extension ViewController {
    @IBAction func quit(_ sender: NSButton) {
        NSApplication.shared.terminate(sender)
    }
}

extension ViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> ViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier("ViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ViewController else {
            fatalError("Why cant i find ViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
