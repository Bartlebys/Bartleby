    //
//  main.swift
//  bartleby
//
//  Created by Benoit Pereira da silva on 12/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

//Instanciate the facade
let facade=BartlebysCommandFacade()
facade.actOnArguments()

    // Chunk trials

/*
     
Bartleby.sharedInstance.configureWith(BartlebyDefaultConfiguration.self)

let chunker=Chunker(fileManager: FileManager.default)

let startTime=CFAbsoluteTimeGetCurrent()
    chunker.breakIntoChunk(fileAt:"/Users/bpds/Desktop/FileChunker/large.mp4", destination: "/Users/bpds/Desktop/TTT/", compress: true, encrypt: true
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
*/





    var holdOn=true
    let runLoop=RunLoop.current
    while (holdOn && runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: NSDate.distantFuture) ) {}
