//
//  StatusView.swift
//  LockBox
//
//  Created by Geoff Noton on 9/19/14.
//  Copyright (c) 2014 sublimeintervention. All rights reserved.
//

import Foundation
import Cocoa
import Security

class StatusView : NSView {
    @IBOutlet weak var popover: NSPopover!
    @IBOutlet weak var popoverController: NSViewController!
    var popoverTransiencyMonitor : AnyObject!
    var active : Bool = false
    var dataSource : StatusViewDataSource!
    var tableView : NSTableView!
    
    func setPassword(sender : AnyObject!) {
        var alert = NSAlert()
        
        alert.messageText = "Configure password"
        alert.addButtonWithTitle("Set")
        alert.addButtonWithTitle("Cancel")
        alert.informativeText = "Please enter your password"
        alert.icon = nil
        
        var input = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        
        alert.accessoryView = input
        
        popover.close()
        var button = alert.runModal()
        
        if (button == 1000) {
            SecKeychainAddGenericPassword(nil, 31, "com.sublimeintervention.lockbox", 7, "lockbox", 8, input.stringValue, nil)
        }
    }
    
    func getPassword() -> String {
        var passLength : UInt32 = 0
        var passPtr : UnsafeMutablePointer<Void> = nil
        var pass : String = ""
        
        SecKeychainFindGenericPassword(nil, 31, "com.sublimeintervention.lockbox", 7, "lockbox", &passLength, &passPtr, nil)
        
        if (passLength > 0) {
            pass = NSString(bytes: passPtr, length: Int(passLength), encoding: NSASCIIStringEncoding)!
            SecKeychainItemFreeContent(nil, passPtr)
        }
        return pass
    }
    
    override func awakeFromNib() {
        dataSource = StatusViewDataSource(statusView: self)
        tableView = NSTableView(frame: NSRect(x: 5, y: 5, width: 200, height: 35))
        tableView.setDataSource(dataSource)
        tableView.addTableColumn(NSTableColumn(identifier: "cells"))
        tableView.setDelegate(dataSource)
        popoverController.view = tableView
    }
    
    override func mouseDown(theEvent: NSEvent!) {
        if (popover.shown) {
            popover.close()
        } else {
            popover.contentSize = tableView.frame.size
            popover.showRelativeToRect(self.frame, ofView: self, preferredEdge: NSMinYEdge)
            popoverTransiencyMonitor = NSEvent.addGlobalMonitorForEventsMatchingMask(.LeftMouseDownMask | .RightMouseDownMask | .KeyUpMask, handler: { (evt) -> Void in
                    NSEvent.removeMonitor(self.popoverTransiencyMonitor)
                    self.popoverTransiencyMonitor = nil;
                    self.popover.close()
            })
        }
        active = true
        self.setNeedsDisplayInRect(self.frame)
    }
    
    override func mouseUp(theEvent: NSEvent!) {
        active = false
        self.setNeedsDisplayInRect(self.frame)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        if (active) {
            NSColor.selectedMenuItemColor().setFill()
        } else {
            NSColor.clearColor().setFill()
        }
        NSRectFill(dirtyRect)
    }

    required init(coder: NSCoder)
    {
        super.init(coder: coder)
        let width = NSStatusBar.systemStatusBar().thickness
        let height = NSStatusBar.systemStatusBar().thickness
        let rect = NSRect(x: 0, y: 0, width: width, height: height)
        
        self.frame = rect
        
        let imageView = NSImageView(frame: rect)
        imageView.image = NSImage(named: "offline.png")
        
        self.addSubview(imageView)
    }
}

class StatusViewDataSource : NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var statusView : StatusView
    var views : [NSView]

    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        return views[row]
    }
    
    func connect(deviceView : NSButton!) {
        let del : AppDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        
        del.centralManagerController.connectToSavedDevice(deviceView.alternateTitle)
    }
    
    func addBluetoothDevice(uuid : NSString, name : NSString) {
        var deviceView = NSButton(frame: NSRect(x:0, y:0, width:190, height:20))
        deviceView.title = name
        deviceView.alternateTitle = uuid
        deviceView.bordered = false
        deviceView.action = "connect:"
        deviceView.target = self
        views.insert(deviceView, atIndex:1)
        
        statusView.tableView.reloadData()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        return views.count
    }
    
    init(statusView: StatusView) {
        self.statusView = statusView
        
        var passwordView = NSButton(frame: NSRect(x: 0, y: 0, width: 190, height: 20))
        
        if (statusView.getPassword() != "") {
            passwordView.title = "Credentials Set"
        } else {
            
            passwordView.title = "Set Password"
        }
        passwordView.alignment = .LeftTextAlignment
        passwordView.bordered = false
        passwordView.action = "setPassword:"
        passwordView.target = statusView
        
        self.views = [passwordView]
        super.init()
    }
}
