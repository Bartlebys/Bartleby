//
//  DirectivesSerializationTests.swift
//  bsync
//
//  Created by Martin Delille on 31/05/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import XCTest

class DirectivesSerializationTests: TestCase {
    fileprivate var _treeName = ""
    fileprivate var _localSourcePath = ""
    fileprivate var _localDestinationPath = ""
    fileprivate var _directivesPath = ""

    fileprivate var _distantTreeURL = URL()
    
    override func setUp() {
        super.setUp()
        
        self._treeName = Bartleby.randomStringWithLength(6)
        self._localSourcePath = DirectivesSerializationTests.assetPath + self._treeName + "/Source"
        self._localDestinationPath = DirectivesSerializationTests.assetPath + self._treeName + "/Destination"
        self._distantTreeURL = TestsConfiguration.API_BASE_URL.appendingPathComponent("BartlebySync/tree/\(self._treeName)")
        self._directivesPath = DirectivesSerializationTests.assetPath + BsyncDirectives.DEFAULT_FILE_NAME
    }

    // MARK: 1 - Local

    func test101_Valid_local_directives_without_hashmapview() {
        let directives1 = BsyncDirectives.localDirectivesWithPath(self._localSourcePath, destinationPath: self._localDestinationPath)
        directives1.automaticTreeCreation = true
        
        // Test directives before serialization
        XCTAssert(directives1.areValid().valid)
        XCTAssertEqual(directives1.areValid().message, "")
        XCTAssert(directives1.computeTheHashMap)
        XCTAssertEqual(directives1.sourceURL, URL(fileURLWithPath: self._localSourcePath))
        XCTAssertNil(directives1.hashMapViewName)
        
        let admin = BsyncAdmin()
        do {
            try admin.saveDirectives(directives1, path: _directivesPath)
            let directives2 = try admin.loadDirectives(_directivesPath)
            
            XCTAssert(directives2.areValid().valid)
            XCTAssertEqual(directives2.areValid().message, "")
            
            XCTAssert(directives2.computeTheHashMap)
            
            XCTAssertEqual(directives2.sourceURL, URL(fileURLWithPath: self._localSourcePath))
            XCTAssertEqual(directives2.destinationURL, URL(fileURLWithPath: self._localDestinationPath))
            
            XCTAssertNil(directives2.user)
            XCTAssertNil(directives2.password)
            XCTAssertNil(directives2.salt)
            XCTAssertNil(directives2.hashMapViewName)
        } catch {
            XCTFail("\(error)")
        }
    }
 
    func test101_Valid_local_directives_with_hashmapview() {
        let directives1 = BsyncDirectives.localDirectivesWithPath(self._localSourcePath, destinationPath: self._localDestinationPath)
        
        // Hash map view
        directives1.hashMapViewName = Bartleby.randomStringWithLength(6)
        
        // Test directives before serialization
        XCTAssert(directives1.areValid().valid)
        XCTAssertEqual(directives1.areValid().message, "")
        XCTAssert(directives1.computeTheHashMap)
        XCTAssertEqual(directives1.sourceURL, URL(fileURLWithPath: self._localSourcePath))
        
        let admin = BsyncAdmin()
        do {
            try admin.saveDirectives(directives1, path: _directivesPath)
            let directives2 = try admin.loadDirectives(_directivesPath)
            
            XCTAssert(directives2.areValid().valid)
            XCTAssertEqual(directives2.areValid().message, "")
            
            XCTAssert(directives2.computeTheHashMap)
            
            XCTAssertEqual(directives2.sourceURL, URL(fileURLWithPath: self._localSourcePath))
            XCTAssertEqual(directives2.destinationURL, URL(fileURLWithPath: self._localDestinationPath))
            
            XCTAssertNil(directives2.user)
            XCTAssertNil(directives2.password)
            XCTAssertNil(directives2.salt)
            
            XCTAssertEqual(directives2.hashMapViewName, directives1.hashMapViewName)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test102_Bad_directives_without_url() {
        let directives = BsyncDirectives()
        
        XCTAssertFalse(directives.areValid().valid)
        XCTAssertEqual(directives.areValid().message, "The source and the destination must be set")
    }

    // TODO: @md test local directives

    // MARK: 2 - Local to distant
    func test201_Valid_upstream_directives() {
        let user = User()
        user.creatorUID = user.UID
        let password = Bartleby.randomStringWithLength(6)
        
        let directives1 = BsyncDirectives.upStreamDirectivesWithDistantURL(_distantTreeURL, localPath: self._localSourcePath)
        directives1.automaticTreeCreation = true
        // Credentials:
        directives1.user = user
        directives1.password = password
        directives1.salt = TestsConfiguration.SHARED_SALT
        
        // Test directives before serialization
        XCTAssert(directives1.areValid().valid)
        XCTAssertEqual(directives1.areValid().message, "")
        XCTAssert(directives1.computeTheHashMap)
        XCTAssertEqual(directives1.sourceURL, URL(fileURLWithPath: self._localSourcePath))
        XCTAssertNil(directives1.hashMapViewName)
        
        let admin = BsyncAdmin()
        do {
            try admin.saveDirectives(directives1, path: _directivesPath)
            let directives2 = try admin.loadDirectives(_directivesPath)
            
            XCTAssert(directives2.areValid().valid)
            XCTAssertEqual(directives2.areValid().message, "")
            
            XCTAssert(directives2.computeTheHashMap)
            
            XCTAssertEqual(directives2.sourceURL, URL(fileURLWithPath: self._localSourcePath))
            XCTAssertEqual(directives2.destinationURL, self._distantTreeURL)
            
            //XCTAssert(directives2.user == user) // TODO: @md Wait for merge
            XCTAssertEqual(directives2.user?.UID, user.UID)
            XCTAssertEqual(directives2.password, password)
            XCTAssertEqual(directives2.salt, TestsConfiguration.SHARED_SALT)
            XCTAssertNil(directives2.hashMapViewName)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test202_Bad_upstream_directives_without_user() {
        let directives = BsyncDirectives.upStreamDirectivesWithDistantURL(self._distantTreeURL, localPath: self._localSourcePath)
        XCTAssertFalse(directives.areValid().valid)
        XCTAssertEqual(directives.areValid().message, "Distant directives need a user")
        let user = User()
        user.creatorUID = user.UID
        directives.user = user
        XCTAssertFalse(directives.areValid().valid)
        XCTAssertEqual(directives.areValid().message, "Distant directives need a password")
        directives.password = user.password
        XCTAssertFalse(directives.areValid().valid)
        XCTAssertEqual(directives.areValid().message, "Distant directives need a shared salt")
        directives.salt = TestsConfiguration.SHARED_SALT
        XCTAssert(directives.areValid().valid)
        XCTAssertEqual(directives.areValid().message, "")
    }
    
    func test203_Bad_upstream_directives_with_hashmapview() {
        let directives = BsyncDirectives.upStreamDirectivesWithDistantURL(self._distantTreeURL, localPath: self._localSourcePath)
        let user = User()
        user.creatorUID = user.UID
        directives.user = user
        directives.password = user.password
        directives.salt = TestsConfiguration.SHARED_SALT
        directives.hashMapViewName = Bartleby.randomStringWithLength(6)
        XCTAssertFalse(directives.areValid().valid)
        XCTAssertEqual(directives.areValid().message, "Hash map view must be restricted when synchronizing to the final consumer")
    }
    
    // MARK: 3 - Distant to local
    func test301_Valid_downstream_directives_without_hashmapview() {
        let user = User()
        user.creatorUID = user.UID
        let password = Bartleby.randomStringWithLength(6)
        
        let directives1 = BsyncDirectives.downStreamDirectivesWithDistantURL(_distantTreeURL, localPath: self._localDestinationPath)
        directives1.automaticTreeCreation = true
        // Credentials:
        directives1.user = user
        directives1.password = password
        directives1.salt = TestsConfiguration.SHARED_SALT
        
        // Test directives before serialization
        XCTAssert(directives1.areValid().valid)
        XCTAssertEqual(directives1.areValid().message, "")
        XCTAssert(directives1.computeTheHashMap)
        XCTAssertEqual(directives1.destinationURL, URL(fileURLWithPath: self._localDestinationPath))
        XCTAssertNil(directives1.hashMapViewName)
        
        let admin = BsyncAdmin()
        do {
            try admin.saveDirectives(directives1, path: _directivesPath)
            let directives2 = try admin.loadDirectives(_directivesPath)
            
            XCTAssert(directives2.areValid().valid)
            XCTAssertEqual(directives2.areValid().message, "")
            
            XCTAssert(directives2.computeTheHashMap)
            
            XCTAssertEqual(directives2.sourceURL, self._distantTreeURL)
            XCTAssertEqual(directives2.destinationURL, URL(fileURLWithPath: self._localDestinationPath))
            
            //XCTAssert(directives2.user == user) // TODO: @md Wait for merge
            XCTAssertEqual(directives2.user?.UID, user.UID)
            XCTAssertEqual(directives2.password, password)
            XCTAssertEqual(directives2.salt, TestsConfiguration.SHARED_SALT)
            XCTAssertNil(directives2.hashMapViewName)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test302_Valid_downstream_directives_with_hashmapview() {
        let user = User()
        user.creatorUID = user.UID
        let password = Bartleby.randomStringWithLength(6)
        
        let directives1 = BsyncDirectives.downStreamDirectivesWithDistantURL(_distantTreeURL, localPath: self._localDestinationPath)
        // Credentials:
        directives1.user = user
        directives1.password = password
        directives1.salt = TestsConfiguration.SHARED_SALT
        
        // Hash map view
        directives1.hashMapViewName = Bartleby.randomStringWithLength(6)
        
        // Test directives before serialization
        XCTAssert(directives1.areValid().valid)
        XCTAssertEqual(directives1.areValid().message, "")
        XCTAssert(directives1.computeTheHashMap)
        XCTAssertEqual(directives1.destinationURL, URL(fileURLWithPath: self._localDestinationPath))
        
        let admin = BsyncAdmin()
        do {
            try admin.saveDirectives(directives1, path: _directivesPath)
            let directives2 = try admin.loadDirectives(_directivesPath)
            
            XCTAssert(directives2.areValid().valid)
            XCTAssertEqual(directives2.areValid().message, "")
            
            XCTAssertEqual(directives2.hashMapViewName, directives1.hashMapViewName)

            XCTAssert(directives2.computeTheHashMap)
            
            XCTAssertEqual(directives2.sourceURL, self._distantTreeURL)
            XCTAssertEqual(directives2.destinationURL, URL(fileURLWithPath: self._localDestinationPath))
            
            //XCTAssert(directives2.user == user) // TODO: @md Wait for merge
            XCTAssertEqual(directives2.user?.UID, user.UID)
            XCTAssertEqual(directives2.password, password)
            XCTAssertEqual(directives2.salt, TestsConfiguration.SHARED_SALT)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test303_Bad_downstream_directives_without_user() {
        let directives = BsyncDirectives.downStreamDirectivesWithDistantURL(self._distantTreeURL, localPath: self._localSourcePath)
        XCTAssertFalse(directives.areValid().valid)
        XCTAssertEqual(directives.areValid().message, "Distant directives need a user")
        let user = User()
        user.creatorUID = user.UID
        directives.user = user
        XCTAssertFalse(directives.areValid().valid)
        XCTAssertEqual(directives.areValid().message, "Distant directives need a password")
        directives.password = user.password
        XCTAssertFalse(directives.areValid().valid)
        XCTAssertEqual(directives.areValid().message, "Distant directives need a shared salt")
        directives.salt = TestsConfiguration.SHARED_SALT
        XCTAssert(directives.areValid().valid)
        XCTAssertEqual(directives.areValid().message, "")
    }
}
