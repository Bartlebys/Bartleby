//
//  BlocksTests.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 26/11/2016.
//
//

import XCTest
import BartlebyKit

// IMPORTANT TO UNDERSTAND
// in Those tests we use file wrappers that are not explicitly saved.
// At the end of the chunk process it calls :
// try self.document?.put(data: data, identifiedBy: chunk.sha1)
// there is no guarantee the data is written within the package( we use the document file wrappers)
class BlocksTests: BartlebyTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test001_Add_File_to_box() {

        let e = self.expectation(description: "Add a file to a box in the document")
        BlocksTests.createFile(size: 20*1000*1000+1, fileName: "file1.txt")
        let url: URL = BlocksTests.urlByAppending(path: "file1.txt")
        let fr: FileReference = FileReference.publicFileReference(at:url.path)
        let box:Box = BlocksTests.document.newManagedModel()
        BlocksTests.document.bsfs.add(reference: fr,
                                      in:box
            , to: "/a/file1.txt",
              progressed: { progression in
                print("\(progression)")
        },
              completed: { completion in
                if let nodeExtRef:String=completion.getResultExternalReference(){
                    if let node:Node = try? Bartleby.registredObjectByUID(nodeExtRef) {
                        let blocks:[Block] = node.relations(Relationship.owns)
                        XCTAssert(blocks.count == 3, "3 blocks expected \(blocks.count)")
                        XCTAssert(node.isAssemblable, "Node is assemblable")
                    }else{
                        XCTFail("Node not found")
                    }
                }else{
                    XCTFail("Node external Reference not found")
                }
                XCTAssert(completion.success, completion.message)
                e.fulfill()

        })

        waitForExpectations(timeout: TestsConfiguration.LONG_TIME_OUT_DURATION, handler: nil)
    }
    
    
}
