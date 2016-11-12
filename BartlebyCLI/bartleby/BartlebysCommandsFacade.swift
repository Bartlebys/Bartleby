//
//  BartlebysCommandsFacade.swift
//  bartleby
//
//  Created by Benoit Pereira da silva on 24/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

struct BartlebysCommandFacade {

    static let args = Swift.CommandLine.arguments

    let executableName = NSString(string: args.first!).pathComponents.last!
    let firstArgumentAfterExecutablePath: String? = (args.count >= 2) ? args[1] : nil

    func actOnArguments() {
        switch firstArgumentAfterExecutablePath {
        case nil:
            print(self._noArgMessage())
            exit(EX_NOINPUT)
        case "-h"?, "-help"?, "h"?, "help"?:
            print(self._noArgMessage())
            exit(EX_USAGE)
        case "testShadower"?:
            let startTime=CFAbsoluteTimeGetCurrent()
            let shadower=Shadower()
            if let userDir=Bartleby.getSearchPath(FileManager.SearchPathDirectory.desktopDirectory){
                shadower.blocksShadowsFromFolder(folderPath: userDir,
                                                 success: { fileShadows in

                                                    let duration=CFAbsoluteTimeGetCurrent()-startTime
                                                    print("blocksShadowsFromFile Duration \(duration) files:\(fileShadows.count)")
                                                    var totalSize=0
                                                    var blocksNb=0
                                                    for n:NodeBlocksShadows in fileShadows{
                                                        totalSize += n.node.size
                                                        blocksNb += n.blocks.count
                                                    }
                                                    print("\(totalSize/MB) MB")
                                                    print("\(Int(Double(totalSize/MB)/duration)) MB/s")
                                                    print("For \(blocksNb) blocks")
                                                    exit(EX_OK)
                }
                    , progression: { progression in

                },
                      failure: { message in
                        print(message)
                        exit(EX_DATAERR)
                }
                )
            }else{
                exit(EX_OK)
            }
        case "testChunker"? :
            // Chunk trials
            Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration.self)
            let chunker=Chunker(fileManager: FileManager.default)

            let startTime=CFAbsoluteTimeGetCurrent()
            if let userDir=Bartleby.getSearchPath(FileManager.SearchPathDirectory.desktopDirectory){
                chunker.breakIntoChunk(fileAt:"\(userDir)/FileChunker/large.mp4", destination: "\(userDir)/chunkerTest/", compress: true, encrypt: true
                    ,progression:{ progression in
                        print(progression)
                }, success: { chunks in
                    print("Break to Chunk Duration \(CFAbsoluteTimeGetCurrent()-startTime)")
                    let joinStartTime=CFAbsoluteTimeGetCurrent()
                    let absolutePaths=chunks.map({ (chunk) -> String in
                        return chunk.baseDirectory+chunk.relativePath
                    })
                    chunker.joinChunks(from: absolutePaths, to: "/Users/bpds/Desktop/TTT/result.mp4", decompress: true, decrypt: true
                        ,progression:{ progression in
                            print(progression)
                    }
                        , success: {
                            print("Join Chunks Duration \(CFAbsoluteTimeGetCurrent()-joinStartTime)")
                            exit(EX_OK)
                    }, failure: { (message) in
                        print(message)
                        exit(EX_DATAERR)
                    })
                }, failure:{ message in
                    print(message)
                    exit(EX_DATAERR)
                })
            }else{
                exit(EX_OK)
            }

        default:
            // We want to propose the best verb candidate
            let reference=[
                "h", "help",
                "install",
                "create",
                "generate",
                "update",
                "testShadower",
                "testChunker",
                ]
            let bestCandidate=self.bestCandidate(string: firstArgumentAfterExecutablePath!, reference: reference)
            print("Hey ...\"bartleby \(firstArgumentAfterExecutablePath!)\" is unexpected!")
            print("Did you mean:\"bartleby \(bestCandidate)\"?")
        }
    }



    private func _noArgMessage() -> String {
        var s=""
        s += "Bartleby's CLI"
        s += "\nCreated by Benoit Pereira da Silva"
        s += "\nhttps://pereira-da-silva.com for Chaosmos SAS"
        s += "\n"
        s += "\nvalid calls are S.V.O sentences like:\"bartleby <verb> [options]\""
        s += "\nAvailable verbs:"
        s += "\n"
        s += "\n\t\(executableName) install -m <Manifest FilePath>"
        s += "\n\t\(executableName) create <Manifest FilePath>"
        s += "\n\t\(executableName) generate <Manifest FilePath>"
        s += "\n\t\(executableName) update <Manifest FilePath>"
        s += "\n\t\(executableName) testShadower"
        s += "\n\t\(executableName) testChunker"
        s += "\n"
        s += "\nRemember that you can call help for each verb"
        s += "\n"
        s += "\n\te.g:\t\"bartleby synchronize help\""
        s += "\n\te.g:\t\"bartleby snapshoot help\""
        s += "\n"
        return s
    }

    // MARK: levenshtein distance
    // https://en.wikipedia.org/wiki/Levenshtein_distance

    private func bestCandidate(string: String, reference: [String]) -> String {
        var selectedCandidate=string
        var minDistance: Int=Int.max
        for candidate in reference {
            let distance=self.levenshtein(string, candidate)
            if distance<minDistance {
                minDistance=distance
                selectedCandidate=candidate
            }
        }
        return selectedCandidate
    }

    private func min(numbers: Int...) -> Int {
        return numbers.reduce(numbers[0], {$0 < $1 ? $0 : $1})
    }

    private class Array2D {
        var cols: Int, rows: Int
        var matrix: [Int]

        init(cols: Int, rows: Int) {
            self.cols = cols
            self.rows = rows
            matrix = Array(repeating:0, count:cols*rows)
        }

        subscript(col: Int, row: Int) -> Int {
            get {
                return matrix[cols * row + col]
            }
            set {
                matrix[cols*row+col] = newValue
            }
        }

        func colCount() -> Int {
            return self.cols
        }

        func rowCount() -> Int {
            return self.rows
        }
    }

    private func levenshtein(_ aStr: String, _ bStr: String) -> Int {
        let a = Array(aStr.utf16)
        let b = Array(bStr.utf16)

        let dist = Array2D(cols: a.count + 1, rows: b.count + 1)
        for i in 1...a.count {
            dist[i, 0] = i
        }

        for j in 1...b.count {
            dist[0, j] = j
        }

        for i in 1...a.count {
            for j in 1...b.count {
                if a[i-1] == b[j-1] {
                    dist[i, j] = dist[i-1, j-1]  // noop
                } else {
                    dist[i,j] = min(numbers:
                        dist[i-1, j] + 1,  // deletion
                        dist[i, j-1] + 1,  // insertion
                        dist[i-1, j-1] + 1  // substitution
                    )
                }
            }
        }
        return dist[a.count, b.count]
    }
}
