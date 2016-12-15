//
//  Logger.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 22/10/2016.
//
//

import Foundation


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
     return entry.category==Default.LOG_DEFAULT
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
