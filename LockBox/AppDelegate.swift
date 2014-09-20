//
//  AppDelegate.swift
//  LockBox
//
//  Created by Geoff Noton on 9/18/14.
//  Copyright (c) 2014 sublimeintervention. All rights reserved.
//

import Cocoa
import CoreBluetooth

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusView : StatusView?
    var centralManagerController : CentralManagerController!
    var statusItem : NSStatusItem?
    
    func togglePopover(sender: AnyObject) {
        
    }
    
    func quit() {
        NSApplication.sharedApplication().terminate(nil)
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(CGFloat(-1))
        statusItem?.highlightMode = true
        statusItem?.action = "togglePopover:"
        statusItem?.image = NSImage(named: "offline.png")
        statusItem?.view = statusView
        
        centralManagerController = CentralManagerController()
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
}
