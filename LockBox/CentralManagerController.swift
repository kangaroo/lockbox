import Cocoa
import Foundation
import CoreBluetooth

class CentralManagerController : NSObject, CBCentralManagerDelegate {
    var centralManager : CBCentralManager!
    var currentPeripheral : CBPeripheral!
    var peripheralController : PeripheralController!
    var deviceTable : [String: String] = [:]
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if (central.state == .PoweredOn) {
            /*
            let uuid = NSUserDefaults.standardUserDefaults().stringForKey("chainUUID")
            let name = NSUserDefaults.standardUserDefaults().stringForKey("chainName")
            if (uuid != nil && name != nil) {
                connectToSavedDevice(uuid!)
            }
            */
            startScanning()
        }
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        let controller = currentPeripheral.delegate as PeripheralController
        currentPeripheral = nil
        controller.stopUpdating()
        println("reconnecting")
        centralManager.connectPeripheral(peripheral, options: nil)
        
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        let del : AppDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        let connectedItem = NSMenuItem(title: NSUserDefaults.standardUserDefaults().stringForKey("chainName"), action:nil, keyEquivalent: NSString())
        let controller = peripheral.delegate as PeripheralController

        controller.startUpdating()
        currentPeripheral = peripheral
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        if (deviceTable[peripheral.identifier.UUIDString] == nil && peripheral.name != nil) {
            let del : AppDelegate = NSApplication.sharedApplication().delegate as AppDelegate
            
            deviceTable[peripheral.identifier.UUIDString] = peripheral.name
            del.statusView?.dataSource.addBluetoothDevice(peripheral.identifier.UUIDString, name: peripheral.name)
        }
    }
    
    func startScanning() {
        if (currentPeripheral != nil) {
            centralManager.cancelPeripheralConnection(currentPeripheral)
        }
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func connectToSavedDevice(uuidString : NSString) {
        var uuid : NSUUID? = NSUUID(UUIDString: uuidString)
        var l = [NSUUID]()
        
        l.append(uuid!)
        var p : [AnyObject]! = centralManager.retrievePeripheralsWithIdentifiers(l)
        if (p.count == 1) {
            if (currentPeripheral != nil) {
                let controller = currentPeripheral.delegate as PeripheralController
                controller.stopUpdating()
                centralManager.cancelPeripheralConnection(currentPeripheral)
            }
            let peripheral = p[0] as CBPeripheral
            peripheralController = PeripheralController(peripheral: peripheral)
            peripheral.delegate = peripheralController
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    override init() {
        super.init();
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}
