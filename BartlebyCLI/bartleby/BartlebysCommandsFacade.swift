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
        s += "\n\t\(executableName) testFlocker"
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
