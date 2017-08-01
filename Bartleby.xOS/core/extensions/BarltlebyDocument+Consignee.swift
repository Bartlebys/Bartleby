//
//  BarltlebyDocument+Consignee.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 22/10/2016.
//
//

import Foundation
#if os(OSX)
    import AppKit
#else
    import UIKit
#endif

extension BartlebyDocument:ConcreteConsignee, ConcreteTracker, Consignation, AdaptiveConsignation {


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
        case let .putMessageInLogs(title, body):
            self.putMessageInLogs(title, body: body)
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
        if self.trackingIsEnabled == true {
            self.trackingStack.append((result:result, context:context))
        }
        if glogTrackedEntries == true {
            var resultString=""
            if result != nil{
                resultString="\(result!)"
                resultString=resultString.replacingOccurrences(of: " ", with:"")
                resultString=resultString.replacingOccurrences(of: "\n", with:"")
            }
            let contextString="\(context)"
            glog("Context:\(contextString)", file:#file, function:#function, line:#line)
        }
    }

    // MARK:  Simple stack management


    open func dumpStack() {
        for (result, context) in trackingStack {
            Swift.print("\n\(context):\n\(String(describing:result))\n")
        }
    }

    // MARK: - AdaptiveConsignation protocol

    open func dispatchAdaptiveMessage(_ context: Consignable, title: String, body: String, onSelectedIndex:@escaping (_ selectedIndex: UInt)->())->() {
        // You can override t Consignee and implement your own adaptive mapping
        self.presentInteractiveMessage(title, body: body, onSelectedIndex: onSelectedIndex)
        glog("presentInteractiveMessage title:\(title) body:\(body)", file: #file, function: #function, line: #line, category: "AdaptiveConsignation", decorative: false)
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
                // Return if NSApp is not available (e.g : call has occured from an XPC service)
                guard let _ = NSClassFromString("NSApp") else {
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
                        case NSApplication.ModalResponse.alertFirstButtonReturn:
                            onSelectedIndex(0)
                        case NSApplication.ModalResponse.alertSecondButtonReturn:
                            onSelectedIndex(1)
                        case NSApplication.ModalResponse.alertThirdButtonReturn:
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

                // Return if NSApp is not available (e.g : call has occured from an XPC service)
                guard let _ = NSClassFromString("NSApp") else {
                    return
                }

                if let window=NSApp.mainWindow {
                    let alert = NSAlert()
                    alert.messageText = title
                    alert.addButton(withTitle: "OK")
                    alert.informativeText = body
                    alert.beginSheetModal( for: window, completionHandler: nil)
                    Async.main(after: BartlebyDocument.VOLATILE_DISPLAY_DURATION,{
                        window.attachedSheet?.close()
                    })

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
            Async.main(after: BartlebyDocument.VOLATILE_DISPLAY_DURATION,{
                self.rootViewController.dismiss(animated: true, completion: { () -> Void in
                })

            })

        #elseif os(watchOS)
        #elseif os(tvOS)

        #endif

    }


    #if os(OSX)
        //#if !USE_EMBEDDED_MODULES
        open func presentVolatileMessage(_ window: NSWindow, title: String, body: String)->() {
            Bartleby.syncOnMain{() -> Void in
                let alert = NSAlert()
                alert.messageText = title
                alert.addButton(withTitle: "OK")
                alert.informativeText = body
                alert.beginSheetModal( for: window, completionHandler: nil)
                Async.main(after: BartlebyDocument.VOLATILE_DISPLAY_DURATION , {
                    if let sheet=window.attachedSheet {
                        sheet.close()
                    }
                })
                glog("presentVolatileMessage title:\(title) body:\(body)", file: #file, function: #function, line: #line, category: "AdaptiveConsignation", decorative: false)
            }

        }
        //#endif
    #endif


    open func putMessageInLogs(_ title: String, body: String)->() {
        glog("\(title):\n\(body)", file:#file, function:#function, line: #line,category:Default.LOG_DEFAULT)
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
