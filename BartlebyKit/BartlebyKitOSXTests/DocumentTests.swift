///Users/bpds/Desktop/bartleby-document/groups.data
//  DocumentTests.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 20/05/2016.
//
//

import Foundation
import XCTest
import BartlebyKit

class DocumentTests: XCTestCase {


    func test_000() {

        let expectation=expectationWithDescription("createDocument")
        let document=BartlebyDocument()
        document.configureSchema()
        Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration.self)
        let path=Bartleby.getSearchPath(NSSearchPathDirectory.DesktopDirectory)!.stringByAppendingString("bartleby.document")
        let url=NSURL(fileURLWithPath: path)
        document.saveToURL(url, ofType:"bartleby", forSaveOperation: NSSaveOperationType.SaveToOperation) { (error) in
            if let error = error {
                XCTFail("\(error)")
            } else {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }

    }
}
