//
//  Global.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 06/05/2016.
//
//  A set of general global functions

import Foundation



// MARK: - bartleby Print


public protocol LogCategorizable {
    static var logCategory: String { get }
}


public protocol Logger:Identifiable{

    /**
     Logs contextual informations.

     - parameter message: the message
     - parameter file:  the file
     - parameter line:  the line
     - parameter function : the function name
     - parameter category: a categorizer string
     - parameter decorative: if set to true only the message will be displayed.
     */
    func log(_ message: Any, file: String, function: String, line: Int, category: String,decorative:Bool)
    

    /**
     Returns a printable string for the Log entries matching a specific criteria

     - parameter matching: the filter closure

     - returns: a dump of the entries
     */
    func getLogs(_ matching:@escaping (_ entry: LogEntry) -> Bool )->String


    /**
     Dumps the logs entries to a file.

     Samples
     ```
     // Writes logs in ~/Library/Application\ Support/Bartleby/logs
     Bartleby.dumpLogsEntries ({ (entry) -> Bool in
     return true // all the Entries
     }, fileName: "All")

     Bartleby.dumpLogsEntries ({ (entry) -> Bool in
     return entry.file=="TransformTests.swift"
     },fileName:"TransformTests.swift")



     Bartleby.dumpLogsEntries({ (entry) -> Bool in
     return true // all the Entries
     }, fileName: "Tests_zorro")



     Bartleby.dumpLogsEntries ({ (entry) -> Bool in
     // Entries matching default category
     return entry.category==Default.LOG_CATEGORY
     },fileName:"Default")


     // Clean up the entries
     Bartleby.cleanUpLogs()
     ```


     - parameter matching: the filter closure
     */
    func dumpLogsEntries(_ matching:@escaping (_ entry: LogEntry) -> Bool,fileName:String?)


    /**
     Cleans up all the entries
     */
    func cleanUpLogs()
    
}



/**
 Returns a category for glog

 - parameter subject: the subject to classify

 - returns: a string representing the category
 */
public func logsCategoryFor(_ subject: Any) -> String {
    if let s = subject as? Collectible {
        return s.d_collectionName
    }
    return Default.LOG_CATEGORY
}


/// Global logs Observers

internal var glogObservers=[Logger]()

public func addGlobalLogsObserver(_ logger:Logger){
    glogObservers.append(logger)
}

public func removeGlobalLogsObserver(_ logger:Logger){
    if let idx=glogObservers.index(where: { $0.UID == logger.UID }){
        glogObservers.remove(at: idx)
    }
}



/**
Global log  indirection with guided contextual info is relayed to any openned document log
Usage : glog("<Message>",file:#file,function:#function,line:#line")
You can create code snippet

- parameter items: the items to print
- parameter file:  the file
- parameter line:  the line
- parameter function : the function name
- parameter context: a contextual string
*/
public func glog(_ message: Any, file: String, function: String, line: Int, category: String=Default.LOG_CATEGORY,decorative:Bool=false) {
    for observer in glogObservers{
        observer.log(message, file: file, function: function, line: line, category: category, decorative: decorative)
    }
}


// MARK: - ExternalReferences facilities


/**
 Removes and external references

 - parameter instanceUID:        its UID
 - parameter externalReferences: the reference to the externalReferences collection
 */
public func removeExternalReferenceWith(_ instanceUID: String, from externalReferences: inout [ExternalReference]) {
    if let idx=externalReferences.index(where: {$0.iUID == instanceUID}){
        externalReferences.remove(at: idx)
    }
}



public func instancesToExternalReferences<T: Collectible>(_ instances: [T]) -> [ExternalReference] {
    var externalReferences=[ExternalReference]()
    for instance in instances {
        externalReferences.append(ExternalReference(from:instance))
    }
    return externalReferences
}


public func instancesFromExternalReferences<T: Collectible>(_ externalReferences: [ExternalReference]) -> [T] {
    var instances=[T]()
    for reference in externalReferences {
        if let instance: T=reference.toLocalInstance() {
            instances.append(instance)
        }
    }
    return instances
}




public enum GlobalQueue {

    case main
    case userInteractive
    case userInitiated
    case utility
    case background

     public func get() -> DispatchQueue {
        switch self {
        case .main:
            return DispatchQueue.main
        case .userInteractive:
            return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
        case .userInitiated:
            return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
        case .utility:
            return DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
        case .background:
            return DispatchQueue.global(qos: DispatchQoS.QoSClass.background)

        }
    }
}
