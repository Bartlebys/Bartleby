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

#elseif os(tvOS)

#endif

/// A concrete implementation of a consignee with multi platform basic support
open class Consignee: AbstractConsignee, ConcreteConsignee, ConcreteTracker, Consignation, AdaptiveConsignation {

    // MARK: - ConcreteConsignee protocol

    open func perform(_ reaction: Reaction, forContext: Consignable) {
        switch reaction {
            case  Reaction.nothing:
                break
            case let .dispatchAdaptiveMessage(context, title, body, trigger):
                self.dispatchAdaptiveMessage(context, title: title, body: body, onSelectedIndex:trigger)
            case let .track(result, context):
                self.track(result, context: context)
            case let .presentInteractiveMessage(title, body, trigger):
                self.presentInteractiveMessage(title, body: body, onSelectedIndex:trigger)
            case let .presentVolatileMessage(title, body):
                self.presentVolatileMessage(title, body: body)
            case let .logMessage(title, body):
                self.logMessage(title, body: body)
        }
    }


    // You can perform multiple reaction
    // var reactions = Array<Consignee.Reaction> ()


    open func perform(_ reactions: [Reaction], forContext: Consignable) {
        for reaction in reactions {
            self.perform(reaction, forContext: forContext)
        }
    }

    // MARK: - ConcreteTracker protocol

    open func track(_ result: Any?, context: Consignable) {
        if trackingIsEnabled == true {
            trackingStack.append((result:result, context:context))
        }
        if bprintTrackedEntries == true {
            var resultString=""
            if result != nil{
                resultString="\(result!)"
                resultString=resultString.replacingOccurrences(of: " ", with:"")
                resultString=resultString.replacingOccurrences(of: "\n", with:"")
            }
            let contextString="\(context)"
            bprint("Context:\(contextString)", file:#file, function:#function, line:#line)
        }
    }

    // MARK:  Simple stack management


    open var trackingIsEnabled: Bool=false

    open var bprintTrackedEntries: Bool=false

    open var trackingStack=[(result:Any?, context:Consignable)]()

    open func dumpStack() {
        for (result, context) in trackingStack {
            print("\n\(context):\n\(result)\n")
        }
    }

    // MARK: - AdaptiveConsignation protocol

    open func dispatchAdaptiveMessage(_ context: Consignable, title: String, body: String, onSelectedIndex:@escaping (_ selectedIndex: UInt)->())->() {
        // You can override t Consignee and implement your own adaptive mapping
        self.presentInteractiveMessage(title, body: body, onSelectedIndex: onSelectedIndex)
        bprint("presentInteractiveMessage title:\(title) body:\(body)", file: #file, function: #function, line: #line, category: "AdaptiveConsignation", decorative: false)
    }


    // MARK: - Consignation


    open func presentInteractiveMessage(_ title: String, body: String, onSelectedIndex:@escaping (_ selectedIndex: UInt)->())->() {
        #if os(OSX)
            #if !USE_EMBEDDED_MODULES

                // Return if this is a unit test
                if let _ = NSClassFromString("XCTest") {
                    onSelectedIndex(0)
                    return
                }

                if let window=NSApp.mainWindow {
                    let alert = NSAlert()
                    alert.messageText = title
                    alert.addButton(withTitle: "OK")
                    alert.informativeText = body
                    alert.beginSheetModal( for: window, completionHandler: { (returnCode) -> Void in
                        switch returnCode {
                        case NSAlertFirstButtonReturn:
                            onSelectedIndex(0)
                        case NSAlertSecondButtonReturn:
                            onSelectedIndex(1)
                        case NSAlertThirdButtonReturn:
                            onSelectedIndex(3)
                        default:
                            onSelectedIndex(0)
                        }
                    })
                } else {
                    // ERROR
                    onSelectedIndex(0)
                }
            #else
            #endif

        #elseif os(iOS)

            let alert=UIAlertController(title: title, message: body, preferredStyle:.alert)
            let action=UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                onSelectedIndex(0)
            })
            alert.addAction(action)
            if let popPresenter=alert.popoverPresentationController {
                popPresenter.sourceView = self.rootViewController.view
                popPresenter.sourceRect = self.rootViewController.view.bounds
            }

            self.rootViewController.present(alert, animated: true, completion:nil)

        #elseif os(watchOS)
        #elseif os(tvOS)
        #endif
    }

    open func presentVolatileMessage(_ title: String, body: String)->() {
        #if os(OSX)
            #if !USE_EMBEDDED_MODULES

                // Return if this is a unit test
                if let _ = NSClassFromString("XCTest") {
                    return
                }

                if let window=NSApp.mainWindow {
                    let alert = NSAlert()
                    alert.messageText = title
                    alert.addButton(withTitle: "OK")
                    alert.informativeText = body
                    alert.beginSheetModal( for: window, completionHandler: nil)
                    let dispatchTime=DispatchTime.now() + Double(Int64(Consignee.VOLATILE_DISPLAY_DURATION * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) { () -> Void in
                        window.attachedSheet?.close()
                    }
                } else {
                    // ERROR
                }
            #else
            #endif

        #elseif os(iOS)

            let a=UIAlertController(title: title, message: body, preferredStyle:.alert)

            if let popPresenter=a.popoverPresentationController {
                popPresenter.sourceView = self.rootViewController.view
                popPresenter.sourceRect = self.rootViewController.view.bounds
            }

            self.rootViewController.present(a, animated: true, completion:nil)

            DispatchQueue.main.asyncAfter(deadline: .now() + Consignee.VOLATILE_DISPLAY_DURATION * Double(NSEC_PER_SEC)) {
                self.rootViewController.dismiss(animated: true, completion: { () -> Void in
                })
            }



        #elseif os(watchOS)
        #elseif os(tvOS)

        #endif

    }


    #if os(OSX)
    //#if !USE_EMBEDDED_MODULES
    open func presentVolatileMessage(_ window: NSWindow, title: String, body: String)->() {
        DispatchQueue.main.async { () -> Void in
            let alert = NSAlert()
            alert.messageText = title
            alert.addButton(withTitle: "OK")
            alert.informativeText = body
            alert.beginSheetModal( for: window, completionHandler: nil)
            let dispatchTime=DispatchTime.now() + Double(Int64(Consignee.VOLATILE_DISPLAY_DURATION * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) { () -> Void in
                if let sheet=window.attachedSheet {
                    sheet.close()
                }
            }
            bprint("presentVolatileMessage title:\(title) body:\(body)", file: #file, function: #function, line: #line, category: "AdaptiveConsignation", decorative: false)
        }

    }
    //#endif
    #endif


    open func logMessage(_ title: String, body: String)->() {
        bprint("\(title):\n\(body)", file:#file, function:#function, line: #line)
    }

    // MARK: - IOS only

    #if os(iOS)

    public var rootViewController: UIViewController {
        get {
            let appDelegate  = UIApplication.shared.delegate
            return appDelegate!.window!!.rootViewController!
        }
    }
    #endif
}
