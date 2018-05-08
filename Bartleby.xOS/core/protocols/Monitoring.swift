//
//  Monitoring.swift
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
The Monitoring protocol can be used by apps or XPC services to transmit progression or completion states
 */
@objc public protocol Monitoring {

    /**
     Called by an XPC service  (XPC -> app)
     Or by the app -> app to aggregate identified progressions

     - parameter progression: the progression state
     */
    func receiveProgression(_ progression:Progression)

    /**
     Called by an XPC service (XPC -> app)
     Or by the app -> app to aggregate identified progressions

     - parameter completion: the completion state
     */
    func receiveCompletion(_ completion:Completion)
}


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
 connection.exportedInterface =  NSXPCInterface(withProtocol: Monitoring.self)
 connection.exportedObject = self
 // Resume the connection
 connection.resume()
 return connection
 }()


 // The XPC instance
 var ydXPC:YouDubXPCProtocol?{
 let remoteObjectProxy=ydXPCConnection.remoteObjectProxyWithErrorHandler { (error) -> Void in
 self.log(NSLocalizedString("XPC connection error ", comment:"XPC connection error ")+"\(error.localizedDescription)", file:#file, function:#function, line:#line)
 }
 if let xpc: YouDubXPCProtocol = remoteObjectProxy as? YouDubXPCProtocol {
 return xpc
 }
 return nil
 }


 // MARK: Monitoring

 public func receiveProgression(progression:Progression){
 self.log("\(identifier) \(progression)",file:#file,function:#function,line:#line,category:Default.LOG_DEFAULT,decorative:false)
 }

 public func receiveCompletion(completion:Completion){
 self.log("\(identifier) \(completion)",file:#file,function:#function,line:#line,category:Default.LOG_DEFAULT,decorative:false)
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
 newConnection.remoteObjectInterface = NSXPCInterface(withProtocol:Monitoring.self)
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
