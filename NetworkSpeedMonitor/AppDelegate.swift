//
//  AppDelegate.swift
//  NetworkSpeedMonitor
//
//  Created by admin on 11/27/21.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @EnvironmentObject var testViewModel:TestViewModel
    
    var popover = NSPopover.init()
    var statusBar: StatusBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        let tabContainerView = TabContainerView()
            .environmentObject(TestViewModel())
            .environmentObject(DataViewModel())
        
        popover.contentViewController = MainViewController()
        popover.contentViewController?.view = NSHostingView(rootView: tabContainerView)
//        popover.contentSize = NSSize(width: 360, height: 360)
        statusBar = StatusBarController.init(popover)
        
        
    }
    
    // App cannot be terminated/Cmd-Q normally so this is unnecessary
//    func applicationWillTerminate(_ notification: Notification) {
//        // Insert any tear-down code here
//
//    }
    
}
