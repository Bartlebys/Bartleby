//
//  ConsigneeDelegate.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 16/09/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation

#if os(OSX)
    import AppKit
#elseif os(iOS)
    import UIKit
#elseif os(watchOS)
    // TODO: watchOS
#elseif os(tvOS)
    // TODO: tvOS
    
#endif

/// A concrete implementation of a consignee with multi platform basic support
public class Consignee:AbstractConsignee,ConcreteConsignee,ConcreteTracker,Consignation,AdaptiveConsignation {
    
    // MARK: - ConcreteConsignee protocol
    
    public func perform(reaction:Reaction,forContext:Consignable){
        switch reaction{
            case  Reaction.Nothing:
                break
            case let .DispatchAdaptiveMessage(context,title, body, trigger):
                self.dispatchAdaptiveMessage(context, title: title, body: body, onSelectedIndex:trigger)
            case let .Track(result,context):
                self.track(result, context: context)
            case let .PresentInteractiveMessage(title, body, trigger):
                self.presentInteractiveMessage(title, body: body, onSelectedIndex:trigger)
            case let .PresentVolatileMessage(title, body):
                self.presentVolatileMessage(title, body: body)
            case let .LogMessage(title, body):
                self.logMessage(title, body: body)
        }
    }
    
    
    // You can perform multiple reaction
    // var reactions = Array<Consignee.Reaction> ()
    
    
    public func perform(reactions:[Reaction],forContext:Consignable){
        for reaction in reactions{
            self.perform(reaction, forContext: forContext)
        }
    }
    
    // MARK: - ConcreteTracker protocol
    
    public func track(result: AnyObject?, context: Consignable) {
        if trackingIsEnabled == true {
            trackingStack.append((result:result,context:context))
            Bartleby.bprint("\(result)\n\(context)")
        }
    }
    
    // MARK:  Simple stack management
    
    public var trackingIsEnabled:Bool=false
    
    public var trackingStack=[(result:AnyObject?,context:Consignable)]()
    
    public func dumpStack(){
        for (result,context) in trackingStack{
            Bartleby.bprint("\n\(context):\n\(result)\n")
        }
    }
    
    // MARK: - AdaptiveConsignation protocol
    
    public func dispatchAdaptiveMessage(context:Consignable,title:String,body:String,onSelectedIndex:(selectedIndex:UInt)->())->(){
        // You can override t Consignee and implement your own adaptive mapping
        self.presentInteractiveMessage(title, body: body, onSelectedIndex: onSelectedIndex)
        
    }
    
    
    // MARK: - Consignation
    
    
    public func presentInteractiveMessage(title:String,body:String,onSelectedIndex:(selectedIndex:UInt)->())->(){
        #if os(OSX)
            #if !USE_EMBEDDED_MODULES
                
                // Return if this is a unit test
                if let _ = NSClassFromString("XCTest") {
                    onSelectedIndex(selectedIndex: 0)
                    return
                }
                
                if let window=NSApp.mainWindow{
                    let alert = NSAlert()
                    alert.messageText = title
                    alert.addButtonWithTitle("OK")
                    alert.informativeText = body
                    alert.beginSheetModalForWindow( window, completionHandler: { (returnCode) -> Void in
                        switch returnCode{
                        case NSAlertFirstButtonReturn:
                            onSelectedIndex(selectedIndex: 0)
                        case NSAlertSecondButtonReturn:
                            onSelectedIndex(selectedIndex: 1)
                        case NSAlertThirdButtonReturn:
                            onSelectedIndex(selectedIndex: 3)
                        default:
                            onSelectedIndex(selectedIndex: 0)
                        }
                    })
                }else{
                    // ERROR
                    onSelectedIndex(selectedIndex: 0)
                }
            #else
                self.logMessage(title, body: body)
            #endif
            
        #elseif os(iOS)
            
            let alert=UIAlertController(title: title, message: body, preferredStyle:.Alert)
            let action=UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                onSelectedIndex(selectedIndex: 0)
            })
            alert.addAction(action)
            if let popPresenter=alert.popoverPresentationController{
                popPresenter.sourceView = self.rootViewController.view
                popPresenter.sourceRect = self.rootViewController.view.bounds
            }
            
            self.rootViewController.presentViewController(alert, animated: true, completion:nil)
            
        #elseif os(watchOS)
        #elseif os(tvOS)
        #endif
    }
    
    public func presentVolatileMessage(title:String,body:String)->(){
        #if os(OSX)
            #if !USE_EMBEDDED_MODULES
                
                // Return if this is a unit test
                if let _ = NSClassFromString("XCTest") {
                    return
                }
                
                if let window=NSApp.mainWindow {
                    let alert = NSAlert()
                    alert.messageText = title
                    alert.addButtonWithTitle("OK")
                    alert.informativeText = body
                    alert.beginSheetModalForWindow( window, completionHandler: nil)
                    let dispatchTime=dispatch_time(DISPATCH_TIME_NOW, Int64(Consignee.VOLATILE_DISPLAY_DURATION * Double(NSEC_PER_SEC)))
                    dispatch_after(dispatchTime, dispatch_get_main_queue()) { () -> Void in
                        window.attachedSheet?.close()
                    }
                }else{
                    // ERROR
                }
            #else
                self.logMessage(title, body: body)
            #endif
            
        #elseif os(iOS)
            
            let a=UIAlertController(title: title, message: body, preferredStyle:.Alert)
            
            if let popPresenter=a.popoverPresentationController{
                popPresenter.sourceView = self.rootViewController.view
                popPresenter.sourceRect = self.rootViewController.view.bounds
            }
            
            self.rootViewController.presentViewController(a, animated: true, completion:nil)
            
            let dispatchTime=dispatch_time(DISPATCH_TIME_NOW, Int64(Consignee.VOLATILE_DISPLAY_DURATION * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue()) { () -> Void in
                self.rootViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
                })
            }
            
        #elseif os(watchOS)
        #elseif os(tvOS)
            
        #endif
        
    }
    
    
    #if os(OSX)
    //#if !USE_EMBEDDED_MODULES
    public func presentVolatileMessage(window:NSWindow,title:String,body:String)->(){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let alert = NSAlert()
            alert.messageText = title
            alert.addButtonWithTitle("OK")
            alert.informativeText = body
            alert.beginSheetModalForWindow( window, completionHandler: nil)
            let dispatchTime=dispatch_time(DISPATCH_TIME_NOW, Int64(Consignee.VOLATILE_DISPLAY_DURATION * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue()) { () -> Void in
                if let sheet=window.attachedSheet {
                    sheet.close()
                }
            }
        }
        
    }
    //#endif
    #endif
    
    
    public func logMessage(title:String,body:String)->(){
        Bartleby.bprint("\(title):\n\(body)")
    }
    
    // MARK: - IOS only
    
    #if os(iOS)
    
    public var rootViewController:UIViewController{
        get{
            let appDelegate  = UIApplication.sharedApplication().delegate
            return appDelegate!.window!!.rootViewController!
        }
    }
    #endif
}
