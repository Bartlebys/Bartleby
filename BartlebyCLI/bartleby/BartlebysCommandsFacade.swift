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
        case "testChunkerDigest"?:
            let startTime=CFAbsoluteTimeGetCurrent()
            // Chunk trials
            Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration.self)
            let chunker=Chunker(fileManager: FileManager.default,mode:.digestOnly)
            // let folder=Bartleby.getSearchPath(FileManager.SearchPathDirectory.desktopDirectory)!
            // let folder="/Users/bpds/Documents/Entrepot/Autoformation/Videos"
            let folder="/Users/bpds/Documents/Entrepot/Autoformation/Videos"
            let destFolder=Bartleby.getSearchPath(FileManager.SearchPathDirectory.desktopDirectory)!
            chunker.breakFolderIntoChunk(filesIn: folder,
                                         chunksFolderPath:destFolder+"ChunkerTestSimulated",
                                         progression: { (progression) in
                                            //print(progression)

            }, success: { (chunks) in
                let duration=CFAbsoluteTimeGetCurrent()-startTime

                var totalSize=0
                var blocksNb=0
                var i=0
                var filesAbsolutePaths=[String]()
                for chunk in chunks{
                    i += 1
                    print("\(i) \(chunk.originalSize) \(totalSize) \( (chunk.nodePath) )")
                    totalSize += chunk.originalSize
                    if !filesAbsolutePaths.contains(chunk.nodePath){
                        filesAbsolutePaths.append(chunk.nodePath)
                    }
                    blocksNb += 1
                }
                print("Chunker .digestOnly on large files Duration \(duration) seconds")
                print("Number of files:\(filesAbsolutePaths.count)")
                print("For \(blocksNb) blocks")
                print("\(totalSize/MB) MB")
                print("\(Int(Double(totalSize/MB)/duration)) MB/s")

                exit(EX_OK)
            }, failure: { (chunks, message) in
                print(message)
                exit(EX_DATAERR)
            })

            break
        case "testChunker"? :
            // Chunk trials
            Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration.self)
            let chunker=Chunker(fileManager: FileManager.default)

            let startTime=CFAbsoluteTimeGetCurrent()
            if let userDir=Bartleby.getSearchPath(FileManager.SearchPathDirectory.desktopDirectory){
                chunker.breakIntoChunk(fileAt:"\(userDir)/FileChunker/large.mp4", relativePath:"/large.mp4", chunksFolderPath: "\(userDir)/Tests-One-Large-File/.blocks", compress: true, encrypt: true
                    ,progression:{ progression in
                        print(progression)
                }, success: { chunks in

                    let breakToChunkDuration=CFAbsoluteTimeGetCurrent()-startTime
                    let joinStartTime=CFAbsoluteTimeGetCurrent()
                    let absolutePaths=chunks.map({ (chunk) -> String in
                        return chunk.chunksFolderPath+chunk.relativePath
                    })
                    chunker.joinChunksToFile(from: absolutePaths, to: "/Users/bpds/Desktop/Tests-One-Large-File/result.mp4", decompress: true, decrypt: true
                        ,progression:{ progression in
                            print(progression)
                    }
                        , success: { path in
                            print("----------------------------------------------------")
                            print("\(path)")
                            print("Break to Chunks Duration \(breakToChunkDuration)")
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

            break
        case "testChunkerFolder"? :

            print("Processing...")

            Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration.self)
            var chunker=Chunker(fileManager: FileManager.default)
            chunker.destroyChunksFolder=true// Destruct the chunks 

            if let userDir=Bartleby.getSearchPath(FileManager.SearchPathDirectory.desktopDirectory){
                let sourceFolder="\(userDir)/FolderForTests"
                let destinationFolder="\(userDir)/TestsFolder"
                chunker.breakFolderIntoChunk(filesIn:sourceFolder,
                                             chunksFolderPath: destinationFolder+"/.blocks",
                                             progression: { (progression) in
                }, success: { (chunks) in

                    // Joins the chunks
                    chunker.joinsChunks(chunks: chunks,
                                        assemblyFolderPath: destinationFolder,
                                        progression: { (progression) in
                        print (progression)
                    }, success: {
                        print ("Success")
                        exit(EX_OK)
                    }, failure: { (paths, error) in
                        print ("Failure \(error)")
                        exit(EX_DATAERR)
                    })

                    /*

                    // #1 Compute the file path to chunk.
                    var filePathToChunks=[String:[Chunk]]()
                    for chunk in chunks{
                        if !filePathToChunks.contains(where: { (k,v) -> Bool in
                            return k==chunk.nodePath
                        }){
                            filePathToChunks[chunk.nodePath]=[Chunk]()
                        }
                        filePathToChunks[chunk.nodePath]!.append(chunk)
                    }

                    // #2 re-join the files
                    var counter=0
                    for (_,v) in filePathToChunks{
                        let destinationFile=destinationFolder+v[0].nodePath
                        let nodeNature=v[0].nodeNature

                        if nodeNature == .file{

                            let chunksPaths=v.map({ (chunk) -> String in
                                return destinationFolder+"/.blocks"+chunk.relativePath //chunk.absolutePath
                            })

                            print ("Joining \(destinationFile)")
                            chunker.joinChunksToFile(from: chunksPaths,
                                               to: destinationFile,
                                               decompress: true,
                                               decrypt: true,
                                               progression: { (progression) in
                                                //
                            }, success: { path in
                                counter += 1
                                print ("\(counter)/\(filePathToChunks.count) \(path)")
                                if counter==filePathToChunks.count{
                                    exit(EX_OK)
                                }
                            }, failure: { (message) in
                                print("ERROR \(message)")
                                exit(EX_DATAERR)
                            })

                        }else if nodeNature == .folder{
                            counter += 1
                            print ("\(nodeNature): \(counter)/\(filePathToChunks.count) \(destinationFile)")
                            Async.utility{
                                try? FileManager.default.createDirectory(atPath: destinationFile, withIntermediateDirectories: true, attributes: nil)
                            }


                        }else if nodeNature == .alias{
                            counter += 1
                            print ("\(nodeNature): \(counter)/\(filePathToChunks.count) \(destinationFile)")
                            Async.utility{
                                try? FileManager.default.createSymbolicLink(atPath: destinationFile, withDestinationPath: v[0].aliasDestination)
                            }

                        }

                        if counter==filePathToChunks.count{
                            exit(EX_OK)
                        }
                    }
*/

                }, failure: { (chunks, message) in
                    print(message)
                    exit(EX_DATAERR)
                })
            }else{
                exit(EX_OK)
            }
            break
        default:
            // We want to propose the best verb candidate
            let reference=[
                "h", "help",
                "install",
                "create",
                "generate",
                "update",
                "testChunker",
                "testChunkerDigest",
                "testChunkerFolder",
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
        s += "\n\t\(executableName) testChunker"
        s += "\n\t\(executableName) testChunkerDigest"
        s += "\n\t\(executableName) testChunkerFolder"
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
