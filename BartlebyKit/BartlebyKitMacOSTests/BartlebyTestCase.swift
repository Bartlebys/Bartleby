//
//  BartlebyTestCase.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/11/2016.
//
//

import XCTest
import BartlebyKit

/// A base test case with document and file oriented facilities
public class BartlebyTestCase: XCTestCase {

    static var documents=[BartlebyDocument]()

    static var createdURI=[URL]()

    public static func urlByAppending(path:String)->URL{
        return URL(fileURLWithPath: Bartleby.getSearchPath(FileManager.SearchPathDirectory.desktopDirectory)!+"/"+path)
    }

    public static var document:BartlebyDocument{
        return documents.first ?? newDocument()
    }

    public static func newDocument()->BartlebyDocument{
        let document=BartlebyDocument()
        document.configureSchema()
        document.metadata.sugar=Bartleby.randomStringWithLength(1024)
        Bartleby.sharedInstance.declare(document)
        let group=AsyncGroup()
        group.enter()
        let documentURL=urlByAppending(path:"testDocument\(documents.count+1).document")
        var catched:Error?=nil
        document.save(to:documentURL , ofType: "", for: NSSaveOperationType.saveOperation, completionHandler: { error in
            catched=error
            group.leave()
        })
        group.wait()
        if let error = catched{
            assertionFailure("Setup Precondition failed \(error)")
        }else{
            BartlebyTestCase.createdURI.append(documentURL)
        }
        documents.append(document)
        return document
    }


   public static func createFile(size:UInt,fileName:String,letter:String="z"){
        let data=String(repeating: letter, count: Int(size)).data(using: .utf8)!
        do{
            let u=urlByAppending(path: fileName)
            try data.write(to: u )
            createdURI.append(u)
        }catch{
            XCTFail("Enable to create file \(fileName) \(error)")
        }
    }

    override public static func setUp(){
        XCTestCase.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration.self)
        Bartleby.ephemeral=true
    }

    override public static func tearDown() {
        XCTestCase.tearDown()
        for url in BartlebyTestCase.createdURI{
            do{
                try FileManager.default.removeItem(at: url)
            }catch{
                print("\(error)")
            }
        }
    }


}
