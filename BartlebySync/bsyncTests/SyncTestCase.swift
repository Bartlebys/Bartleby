//
//  SyncTestCase.swift
//  bsync
//
//  Created by Martin Delille on 06/06/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation
import XCTest
import BartlebyKit

/// Dummy synchronization class where the source and the destination are the same folder
class SyncTestCase : TestCase {

    // Source and destination for the synchronization
    var sourceFolderPath = ""
    var destinationFolderPath = ""

    override func setUp() {
        super.setUp()

        // Use the same folder for both source and destination folder
        self.sourceFolderPath = self.assetPath
        self.destinationFolderPath = self.assetPath
    }

    func prepareSync(_ handlers: Handlers) {
        // Create folders
        do {
            try _fm.createDirectory(atPath: sourceFolderPath, withIntermediateDirectories: true, attributes: nil)
            try _fm.createDirectory(atPath: destinationFolderPath, withIntermediateDirectories: true, attributes: nil)
            handlers.on(Completion.successState())
        } catch {
            handlers.on(Completion.failureStateFromError(error))

        }
    }

    func disposeSync(_ handlers: Handlers) {
        // Doing nothing
        handlers.on(Completion.successState())
    }

    func sync(_ handlers: Handlers) {
        // We don't perform sync, we just check the source and destination hashmap the same
        let analyzer = BsyncLocalAnalyzer()
        analyzer.recomputeHash = true
        analyzer.saveHashInAFile = false
        analyzer.createHashMapFromLocalPath(self.sourceFolderPath, handlers: Handlers { (computeSrc) in
            if let srcHashmap = computeSrc.getDictionaryResult() , computeSrc.success {
                analyzer.createHashMapFromLocalPath(self.destinationFolderPath, handlers: Handlers { (computeDst) in
                    if let dstHashmap = computeDst.getDictionaryResult() , computeDst.success {

                        var diagnostic=""
                        for (k,_) in srcHashmap{
                            if dstHashmap[k] == nil{
                                diagnostic += "\n\(k) do not exists in destination"
                            }
                            if srcHashmap[k] != dstHashmap[k]{
                                diagnostic += "\n\(k) value is not matching \(srcHashmap[k])!=\(dstHashmap[k])"
                            }
                        }

                        for (k,_) in dstHashmap{
                            if srcHashmap[k] == nil{
                                diagnostic += "\n\(k) do not exists in source"
                            }
                        }


                        if srcHashmap == dstHashmap {
                            handlers.on(Completion.successState())
                        } else {
                            let completion=Completion.failureState("Different hashmap:\(diagnostic)", statusCode: .undefined)
                            handlers.on(completion)
                            bprint(completion, file: #file, function: #function, line: #line, category: bprintCategoryFor(self))                        }
                    } else {
                        handlers.on(computeDst)
                    }
                    })
            } else {
                handlers.on(computeSrc)
            }
            })
    }

    func test001_preparation() {
        let expectation = self.expectation(description: "Preparation")
        prepareSync(Handlers { (preparation) in
            expectation.fulfill()
            XCTAssert(preparation.success, preparation.message)
            })

        waitForExpectations()
    }

    let _fileName = "file.txt"
    let _fileContent1 = "first synchronization content"

    func test002_Add_single_file() {
        do {
            // Create file in up folder

            try self.writeStrinToPath(_fileContent1, path: sourceFolderPath + _fileName)

            let expectation = self.expectation(description: "Synchronization should complete")

            // Perform synchronization
            sync(Handlers { (sync) in
                expectation.fulfill()
                XCTAssertTrue(sync.success, sync.message)

                // Check result is correct
                do {
                    // List files, excluding path starting with "." (like .bsync folder or prefinalization files if applicable)
                    let files = try self._fm.contentsOfDirectory(atPath: self.destinationFolderPath).filter({ (filename) -> Bool in
                        return !filename.hasPrefix(".")
                    })
                    XCTAssertEqual(files, ["file.txt"])
                    let content = try String(contentsOfFile: self.destinationFolderPath + self._fileName)
                    XCTAssertEqual(content, self._fileContent1)
                } catch {
                    XCTFail("\(error)")
                }

                })

            self.waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)

        } catch {
            XCTFail("\(error)")
        }
    }

    let _fileContent2 = "second synchronization content"

    func test003_Edit_existing_file() {
        do {

            try self.writeStrinToPath(_fileContent2, path: sourceFolderPath + _fileName)

            let expectation = self.expectation(description: "Synchronization should complete")

            // Perform synchronization
            sync(Handlers { (sync) in
                expectation.fulfill()
                XCTAssertTrue(sync.success, sync.message)

                // Check result is correct
                do {
                    // List files, excluding path starting with "." (like .bsync folder or prefinalization files if applicable)
                    let files = try self._fm.contentsOfDirectory(atPath: self.destinationFolderPath).filter({ (filename) -> Bool in
                        return !filename.hasPrefix(".")
                    })
                    XCTAssertEqual(files, ["file.txt"])
                    let content = try String(contentsOfFile: self.destinationFolderPath + self._fileName)
                    XCTAssertEqual(content, self._fileContent2)
                } catch {
                    XCTFail("\(error)")
                }
                })

            self.waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)

        } catch {
            XCTFail("\(error)")
        }
    }

    let _newFileName = "newfile.txt"

    func test004_Move_existing_file() {
        do {
            try _fm.moveItem(atPath: sourceFolderPath + _fileName, toPath: sourceFolderPath + _newFileName)

            let expectation = self.expectation(description: "Synchronization should complete")

            // Perform synchronization
            sync(Handlers { (sync) in
                expectation.fulfill()
                XCTAssertTrue(sync.success, sync.message)

                // Check result is correct
                do {
                    // List files, excluding path starting with "." (like .bsync folder or prefinalization files if applicable)
                    let files = try self._fm.contentsOfDirectory(atPath: self.destinationFolderPath).filter({ (filename) -> Bool in
                        return !filename.hasPrefix(".")
                    })
                    XCTAssertEqual(files, ["newfile.txt"])
                    let content = try String(contentsOfFile: self.destinationFolderPath + self._newFileName)
                    XCTAssertEqual(content, self._fileContent2)
                } catch {
                    XCTFail("\(error)")
                }
                })

            self.waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)


        } catch {
            XCTFail("\(error)")
        }
    }

    fileprivate let _subFileCount = 4
    fileprivate let _subFileContent = "sub file content"

    func test005_Add_files_in_subfolder() {
        do {

            let subFolderPath = sourceFolderPath + "sub/"
            try _fm.createDirectory(atPath: subFolderPath, withIntermediateDirectories: true, attributes: nil)

            for i in 1..._subFileCount {
                let filePath = subFolderPath + "file\(i).txt"
                let content = _subFileContent + "\(i)"
                try self.writeStrinToPath(content, path: filePath)
            }

            let expectation = self.expectation(description: "Synchronization should complete")

            // Perform synchronization
            sync(Handlers { (sync) in
                expectation.fulfill()
                XCTAssertTrue(sync.success, sync.message)

                // Check result is correct
                do {
                    // Check subfolder
                    let subFolderPath = self.destinationFolderPath + "sub/"
                    let subFiles = try self._fm.contentsOfDirectory(atPath: subFolderPath).sorted()
                    XCTAssertEqual(subFiles.count, self._subFileCount)

                    for i in 1...self._subFileCount {
                        XCTAssertEqual(subFiles[i - 1], "file\(i).txt")
                        let subContent = try String(contentsOfFile: subFolderPath + subFiles[i - 1])
                        XCTAssertEqual(subContent, self._subFileContent + "\(i)")
                    }
                } catch {
                    XCTFail("\(error)")
                }
                })

            self.waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)

        } catch {
            XCTFail("\(error)")
        }
    }

    func test006_Move_and_copy_existing_file() {
        do {
            try _fm.moveItem(atPath: sourceFolderPath + _newFileName, toPath: sourceFolderPath + _fileName)
            try _fm.copyItem(atPath: sourceFolderPath + _fileName, toPath: sourceFolderPath + "sub/" + _fileName)

            let expectation = self.expectation(description: "Synchronization should complete")

            // Perform synchronization
            sync(Handlers { (sync) in
                expectation.fulfill()
                XCTAssertTrue(sync.success, sync.message)

                // Check result is correct
                do {
                    // List files, excluding path starting with "." (like .bsync folder or prefinalization files if applicable)
                    let files = try self._fm.contentsOfDirectory(atPath: self.destinationFolderPath).filter({ (filename) -> Bool in
                        return !filename.hasPrefix(".")
                    })
                    XCTAssertEqual(files, ["file.txt", "sub"])
                    // Check root file content
                    let content1 = try String(contentsOfFile: self.destinationFolderPath + self._fileName)
                    XCTAssertEqual(content1, self._fileContent2)
                    // Check copied file content
                    let content2 = try String(contentsOfFile: self.destinationFolderPath + "sub/" + self._fileName)
                    XCTAssertEqual(content2, self._fileContent2)
                } catch {
                    XCTFail("\(error)")
                }
                })

            self.waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)

        } catch {
            XCTFail("\(error)")
        }
    }

    func test007_Doing_nothing() {
        let expectation = self.expectation(description: "Synchronization should complete")

        // Perform synchronization
        sync(Handlers { (sync) in
            expectation.fulfill()
            XCTAssertTrue(sync.success, sync.message)

            // Check result is correct
            do {
                // List files, excluding path starting with "." (like .bsync folder or prefinalization files if applicable)
                let files = try self._fm.contentsOfDirectory(atPath: self.destinationFolderPath).filter({ (filename) -> Bool in
                    return !filename.hasPrefix(".")
                })
                XCTAssertEqual(files, ["file.txt", "sub"])
                // Check root file content
                let content1 = try String(contentsOfFile: self.destinationFolderPath + self._fileName)
                XCTAssertEqual(content1, self._fileContent2)
                // Check copied file content
                let content2 = try String(contentsOfFile: self.destinationFolderPath + "sub/" + self._fileName)
                XCTAssertEqual(content2, self._fileContent2)

                let subFolderPath = self.destinationFolderPath + "sub/"
                let subFiles = try self._fm.contentsOfDirectory(atPath: subFolderPath).sorted()

                XCTAssertEqual(subFiles.count, self._subFileCount + 1)

                for i in 1...self._subFileCount {
                    XCTAssertEqual(subFiles[i], "file\(i).txt")
                    let subContent = try String(contentsOfFile: subFolderPath + subFiles[i])
                    XCTAssertEqual(subContent, self._subFileContent + "\(i)")
                }
            } catch {
                XCTFail("\(error)")
            }
            })

        self.waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }

    // @bpds: func test008_Remove_one_file()

    // MARK 9 - Cleaning
    func test009_Remove_all_files() {
        do {
            try _fm.removeItem(atPath: sourceFolderPath + _fileName)
            let subFolderPath = sourceFolderPath + "sub/"
            if _fm.fileExists(atPath: subFolderPath) {
                try _fm.removeItem(atPath: subFolderPath)
            }


            let expectation = self.expectation(description: "Synchronization should complete")

            // Perform synchronization
            sync(Handlers { (sync) in
                expectation.fulfill()
                XCTAssertTrue(sync.success, sync.message)

                // Check result is correct
                do {
                    // List files, excluding path starting with "." (like .bsync folder or prefinalization files if applicable)
                    let files = try self._fm.contentsOfDirectory(atPath: self.destinationFolderPath).filter({ (filename) -> Bool in
                        return !filename.hasPrefix(".")
                    })
                    XCTAssertEqual(files, [])
                } catch {
                    XCTFail("\(error)")
                }
                })

            self.waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
        } catch {
            XCTFail("\(error)")
        }
    }

    func test999_Dispose_sync() {
        let expectation = self.expectation(description: "Dispose sync")
        disposeSync(Handlers { (dispose) in
            expectation.fulfill()
            XCTAssert(dispose.success, dispose.message)
            })

        self.waitForExpectations(timeout: TestsConfiguration.TIME_OUT_DURATION, handler: nil)
    }
}
