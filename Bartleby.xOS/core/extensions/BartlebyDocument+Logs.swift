//
//  BartlebyDocument+Logs.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 21/10/2016.
//
//

import Foundation

extension BartlebyDocument:Logger{

    /**
     Logs contextual informations.

     - parameter message: the message
     - parameter file:  the file
     - parameter line:  the line
     - parameter function : the function name
     - parameter category: a categorizer string
     - parameter decorative: if set to true only the message will be displayed.
     */
    open func log(_ message: Any, file: String, function: String, line: Int, category: String=Default.LOG_CATEGORY,decorative:Bool=false) {
        if(self.enableLog) {
            let elapsed=Bartleby.elapsedTime
            let entry=LogEntry(counter: self.logs.count+1, message: "\(message)", file: file, function: function, line: line, category: category,elapsed:elapsed,decorative:decorative)
            self.logs.insert(entry, at: 0)
            for observers in self.logsObservers{
                observers.receive(entry)
            }
            if (self.printLogsToTheConsole){
                Swift.print(entry)
            }
        }
    }

 
    /**
     Returns a printable string for the Log entries matching a specific criteria

     - parameter matching: the filter closure

     - returns: a dump of the entries
     */
    open func getLogs(_ matching:@escaping (_ entry: LogEntry) -> Bool )->String{
        let entries=self.logs.filter { (entry) -> Bool in
            return matching(entry)
        }
        var infos=""
        var counter = 1
        for entry in entries{
            infos += "\(counter)# \(entry)\n"
            counter += 1
        }
        return infos
    }


    /**
     Cleans up all the entries
     */
    open func cleanUpLogs(){
        self.logs.removeAll()
    }

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
    open func dumpLogsEntries(_ matching:@escaping (_ entry: LogEntry) -> Bool,fileName:String?){

        let log=self.getLogs(matching)
        let date=Date()
        let df=DateFormatter()
        df.dateFormat = "yyyy-MM-dd-HH-mm"
        let dateFolder = df.string(from: date)
        var id = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier")
        if id == nil{
            id=Bundle.main.executableURL?.lastPathComponent
        }
        let groupFolder = (id ?? "Shared")!

        let folderPath=Bartleby.getSearchPath(FileManager.SearchPathDirectory.applicationSupportDirectory)! + "Bartlebys/logs/\(groupFolder)/\(dateFolder)/"
        let filePath=folderPath+"\(fileName ?? "" ).txt"

        Async.main{
            let fileCreationHandler=Handlers { (folderCreation) in
                if folderCreation.success {
                    Bartleby.fileManager.writeString(log, path:filePath, handlers: Handlers.withoutCompletion())
                }
            }
            Bartleby.fileManager.createDirectoryAtPath(folderPath, handlers:fileCreationHandler)
        }
    }
    
    
}
