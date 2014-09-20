import Foundation
import Cocoa
import CoreBluetooth

class PeripheralController : NSObject, CBPeripheralDelegate {
    lazy var locked : Bool = false
    var peripheral : CBPeripheral
    var canUpdate : Bool = true
    
    func stopUpdating() {
        canUpdate = false
    }
    
    func startUpdating() {
        canUpdate = true
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateRSSI"), userInfo: nil, repeats: false)
    }
    
    func updateRSSI() {
        peripheral.readRSSI()
        if (canUpdate) {
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateRSSI"), userInfo: nil, repeats: false)
        }
    }
    
    func peripheralDidUpdateRSSI(peripheral: CBPeripheral!, error: NSError!) {
        println(peripheral.RSSI)
        
        if (peripheral.RSSI < -70 && !locked) {
            println("locking")
            var scr = NSAppleScript(source: "\n" +
                "tell application \"System Events\" to start current screen saver\n")
            scr?.executeAndReturnError(nil)
            locked = true
        }
        if (peripheral.RSSI > -70 && locked) {
            println("unlocking")
            let del : AppDelegate = NSApplication.sharedApplication().delegate as AppDelegate
            var pass : String = ""
            let kcPass = del.statusView?.getPassword()
            
            if (kcPass != nil) {
                pass = kcPass!.stringByReplacingOccurrencesOfString("\\", withString: "\\\\")
            }
            var scr = NSAppleScript(source: "\n" +
                "tell application \"System Events\"\n" +
                    "\tkey code 0 using command down\n" +
                    "\tdelay 0.5\n" +
                    "\tkey code 51\n" +
                    "\tdelay 0.5\n" +
                    "\tkeystroke \"" + pass + "\"\n" +
                    "\tdelay 0.5\n" +
                    "\tkeystroke return\n" +
                "end tell")
            var err : NSDictionary?
            scr?.executeAndReturnError(&err)
            println(err)
            locked = false
        }
    }

    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
}
