//
//  BSFSTestBase.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 26/11/2016.
//
//

import XCTest
import BartlebyKit

class BSFSTestBase: XCTestCase {

    static var document:BartlebyDocument=BartlebyDocument()

    static var documentURL:URL=urlByAppending(path:"blockTest.document")

    static var createdURI=[URL]()


    static func urlByAppending(path:String)->URL{
        return URL(fileURLWithPath: Bartleby.getSearchPath(FileManager.SearchPathDirectory.desktopDirectory)!+"/"+path)
    }

    static func createFile(size:UInt,fileName:String,letter:String="z"){
        let data=String(repeating: letter, count: Int(size)).data(using: .utf8)!
        do{
            let u=urlByAppending(path: fileName)
            try data.write(to: u )
            createdURI.append(u)
        }catch{
            XCTFail("Enable to create file \(fileName) \(error)")
        }
    }

    override static func setUp(){
        XCTestCase.setUp()
        Bartleby.sharedInstance.configureWith(TestsConfiguration.self)
        BSFSTestBase.document.configureSchema()
        Bartleby.sharedInstance.declare(BlocksTests.document)
        var catched:Error?=nil
        let group=AsyncGroup()
        group.enter()
        BSFSTestBase.document.save(to:BlocksTests.documentURL , ofType: "", for: NSSaveOperationType.saveOperation, completionHandler: { error in
            catched=error
            group.leave()
        })
        group.wait()
        if let error = catched{
            assertionFailure("Setup Precondition failed \(error)")
        }else{
            BSFSTestBase.createdURI.append(documentURL)
        }
    }

    override static func tearDown() {
        XCTestCase.tearDown()
        for url in BSFSTestBase.createdURI{
            do{
                try FileManager.default.removeItem(at: url)
            }catch{
                print("\(error)")
            }
        }
    }

    func data(size:Int)->Data{
        let s=Bartleby.randomStringWithLength(UInt(size))
        return s.data(using: .utf8)!
    }

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }



}
