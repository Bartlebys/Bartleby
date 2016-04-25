//
//  bsyncBasicTests.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 07/03/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class bsyncBasicTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test001_Create_invalid_directivesA() {
        let directives=BsyncDirectives.upStreamDirectivesWithDistantURL(NSURL(), localPath: "")
        XCTAssertFalse(directives.areValid().valid,"Directives should not be valid")
    }
    
    
    
    // Bad test ** that produces a success! **
    // WE NEED an expectationWithDescription
    // And a waitForExpectationsWithTimeout block
    func test002_Bad_Async_Test_Create_a_tree() {
        let context=BsyncContext()//No definition of the sync context
        let admin=BsyncAdmin(context: context)
        admin.createTreesWithCompletionBlock { (success, statusCode) -> () in
            XCTAssertFalse(success==true,"The creation should fail the context is not well defined")
        }
    }
    
    
    
    // Good syntax for the test but the test is failing
    // Asynchronous wait failed: Exceeded timeout of 5 seconds, with unfulfilled expectations: "Create a tree with a void context".
    func test003_Good_Test_Create_a_tree_with_a_real_functionnal_failure() {
        
        let expectation = expectationWithDescription("Create a tree with a void context")
        
        let context=BsyncContext()
        let admin=BsyncAdmin(context: context)
        admin.createTreesWithCompletionBlock { (success, statusCode) -> () in
            XCTAssertFalse(success==true,"The creation should fail the context is not well defined")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(TestsConfiguration.TIME_OUT_DURATION){ error -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                
            }
        }
    }
    
}
