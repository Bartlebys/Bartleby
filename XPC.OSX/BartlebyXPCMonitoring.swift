//
//  BartlebyXPCMonitoring.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 31/08/2016.
//
//

import Foundation

#if !USE_EMBEDDED_MODULES && !IN_BARTLEBY_KIT
    import BartlebyKit
#endif

/*
 
 
# How to create a bidirectionnal XPC service ? 
 
Let's consider for example the YouDubXPC service.

## in the app 
 ```


 // Lazy XPC bidirectionnal connection
 lazy var ydXPCConnection: NSXPCConnection = {
     let connection = NSXPCConnection(serviceName: "tv.lylo.YouDubXPC")
     // Declare the XPC Remote interface
     connection.remoteObjectInterface = NSXPCInterface(withProtocol: YouDubXPCProtocol.self)
     // Export the manager interface
     connection.exportedInterface =  NSXPCInterface(withProtocol: BartlebyXPCMonitoring.self)
     connection.exportedObject = self
     // Resume the connection
     connection.resume()
     return connection
 }()


 // The XPC instance
 var ydXPC:YouDubXPCProtocol?{
     let remoteObjectProxy=ydXPCConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
        bprint(NSLocalizedString("XPC connection error ", comment:"XPC connection error ")+"\(error.localizedDescription)", file:#file, function:#function, line:#line)
     }
     if let xpc: YouDubXPCProtocol = remoteObjectProxy as? YouDubXPCProtocol {
        return xpc
     }
     return nil
 }


 // MARK: BartlebyXPCMonitoring

 public func receiveProgression(progression:Progression,identifiedBy identifier:String){
 bprint("\(identifier) \(progression)",file:#file,function:#function,line:#line,category:DEFAULT_BPRINT_CATEGORY,decorative:false)
 }

 public func receiveCompletion(completion:Completion,identifiedBy identifier:String){
 bprint("\(identifier) \(completion)",file:#file,function:#function,line:#line,category:DEFAULT_BPRINT_CATEGORY,decorative:false)
 }

```

## in  main.swift of the XPC service :

```
 class ServiceDelegate: NSObject, NSXPCListenerDelegate {

     func listener(listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
         // Export the handling Instance
         newConnection.exportedObject = YouDubXPC.sharedInstance
         newConnection.exportedInterface = NSXPCInterface(withProtocol:YouDubXPCProtocol.self)
         
        // Declare the remote interface to permit XPC -> App communication
         newConnection.remoteObjectInterface = NSXPCInterface(withProtocol:BartlebyXPCMonitoring.self)
         YouDubXPC.sharedInstance.connection=newConnection
        
        // Resume the connection
        newConnection.resume()
        return true
     }

 }


 // Create the listener and resume
 let delegate = ServiceDelegate()
 let listener = NSXPCListener.serviceListener()
 listener.delegate = delegate
 listener.resume()

 ```

 */
@objc public protocol BartlebyXPCMonitoring {

    /**
     Called by an XPC service  (XPC -> app)

     - parameter progression: the progression state
     - parameter identifier:  a unique identifier corresponding to the "process"
     */
    func receiveProgression(progression:Progression,identifiedBy identifier:String)

    /**
     Called by an XPC service (XPC -> app)

     - parameter completion: the completion state
     - parameter identifier:  a unique identifier corresponding to the "process"
     */
    func receiveCompletion(completion:Completion,identifiedBy identifier:String)

    
}