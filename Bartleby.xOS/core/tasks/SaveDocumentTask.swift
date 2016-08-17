//
//  SaveDocumentTask.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/08/2016.
//
//
import Foundation

#if os(OSX)
#elseif os(iOS)
#elseif os(watchOS)
#elseif os(tvOS)
#endif

/// This task produc
public class  SaveDocumentTask:Task, ConcreteTask {

    public typealias ArgumentType=JString

    // Universal type support
    override public class func typeName() -> String {
        return "SimulatedTask"
    }

    /**
     This initializer **MUST:** call configureWithArguments
     - parameter arguments: the arguments

     - returns: a well initialized task.
     */
    convenience required public init (arguments: ArgumentType) {
        self.init()
        self.configureWithArguments(arguments)
    }

    /**
     Proceed to a simulated action extraction.
     */
    override public func invoke() {
        super.invoke()
        if let documentUID: ArgumentType = try? self.arguments() {
            if let documentUIDString=documentUID.string{
                if let document=Bartleby.sharedInstance.getDocumentByUID(documentUIDString){
                    #if os(OSX)
                        document.saveDocument(self)
                    #elseif os(iOS)
                        //@bpds (#IOS) UIDocument support url = app documents + document.UID
                        Bartleby.todo("SAVE NEEDS AND IMPLEMENTATION", message: "url = app documents + document.UID")
                        /*
                        document.saveToURL(NSURL(), ofType: "", forSaveOperation: NSSaveOperationType, completionHandler: { (error) in

                        })
    */
                    #elseif os(watchOS)
                    #elseif os(tvOS)
                    #endif
                    let completion = Completion.successState(NSLocalizedString( "Save Task as been accomplished", tableName:"operations", comment:"Save Task as been accomplished") + " \(documentUIDString)", statusCode: StatusOfCompletion.OK, data: nil)
                    self.complete(completion)
                    bprint(completion, file: #file, function: #function, line: #line, category: bprintCategoryFor(self))

                }else{
                    let completion=Completion.failureState(NSLocalizedString( "Save Document Task has failed its document UID was not found", tableName:"operations", comment:"Save Document Task has failed its document UID was not found"), statusCode: StatusOfCompletion.Precondition_Failed)
                    bprint(completion, file: #file, function: #function, line: #line, category: bprintCategoryFor(self))
                    self.complete(completion)
                }
            }else{
                let completion=Completion.failureState(NSLocalizedString( "Save Document Task Document UID is not defined", tableName:"operations", comment:"Save Document Task Document UID is not defined"), statusCode: StatusOfCompletion.Precondition_Failed)
                bprint(completion, file: #file, function: #function, line: #line, category: bprintCategoryFor(self))
                self.complete(completion)
            }
        } else {
            let completion=Completion.failureState(NSLocalizedString( "Save Document Task Invocation argument type missmatch", tableName:"operations", comment:"Simulated Task Invocation argument type missmatch"), statusCode: StatusOfCompletion.Precondition_Failed)
            bprint(completion, file: #file, function: #function, line: #line, category: bprintCategoryFor(self))
            self.complete(completion)
        }
    }
    
}



