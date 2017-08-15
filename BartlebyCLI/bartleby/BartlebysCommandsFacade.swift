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
            exit(EX_USAGE)        default:
            // We want to propose the best verb candidate
            let reference=[
                "h", "help",
                "install",
                "create",
                "generate",
                "update"
            ]
            let bestCandidate=firstArgumentAfterExecutablePath!.bestCandidate(candidates: reference).string
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
        s += "\n\t\(executableName) addKey --app-shared-key <app shared key> --file <key FilePath>"
        s += "\n\t\(executableName) install -m <Manifest FilePath>"
        s += "\n\t\(executableName) create <Manifest FilePath>"
        s += "\n\t\(executableName) generate <Manifest FilePath>"
        s += "\n\t\(executableName) update <Manifest FilePath>"
        s += "\n\t\(executableName) testChunker"
        s += "\n\t\(executableName) testChunkerDigest"
        s += "\n\t\(executableName) testChunkerFolder"
        s += "\n\t\(executableName) testFlocker"
        s += "\n"
        s += "\nRemember that you can call help for each verb"
        s += "\n"
        s += "\n\te.g:\t\"bartleby synchronize help\""
        s += "\n\te.g:\t\"bartleby snapshoot help\""
        s += "\n"
        return s
    }


}
