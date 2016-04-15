//
//  CommandsFacade.swift
//  Bartleby's Sync client aka "bsync"
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license

import Cocoa

public struct CommandsFacade {
    
    static let args = Process.arguments
    
    let executableName = NSString(string: args.first!).pathComponents.last!
    let firstArgumentAfterExecutablePath: String? = (args.count >= 2) ? args[1] : nil
    
    public func actOnArguments(){
        switch firstArgumentAfterExecutablePath{
        case nil:
            print(self._noArgMessage())
            exit(EX_NOINPUT)
        case "-h"?,"-help"?,"h"?,"help"?:
            print(self._noArgMessage())
            exit(EX_USAGE)
        case "create-uid"?:
            let _ = CreateUIDCommand()
        case "create-user"?:
            let _ = CreateUserCommand()
        case "login"?:
            let _ = LoginCommand()
        case "logout"?:
            let _ = LogoutCommand()
        case "verify"?,"verify-credentials"?:
            let _ = VerifyCredentialsCommand()
        case "synchronize"?:
            // Proceed to authentication if necessary
            // Synchronizes from and to local or distant tree
            // Starts a new session or resumes the current session
            // Uses a snapshot most of the time
             let _ = SynchronizeCommand().executeCMD()
        case "cd"?,"create-directives"?:
            // Runs the synchronization directives
            let _ = CreateDirectiveCommand()
            
        case "rd"?,"reveal-directives"?:
            let _ = RevealDirectivesCommand()
        case "run"?,"run-directives"?:
            // Runs the synchronization directives
             let _ = RunDirectivesCommand().executeCMD()
        case "create-hashmap"?,"create-hashMap"?:
            // Creates a hash map for given folder
            let _ = CreateHashMapCommand()
        case "kvs"?,"key-value-storage"?,"keystore"?:
            // Runs the synchronization directives
            let _ = KeyValueStorageCommand()
        case "cleanup"?:
            // Deletes the snapshots and hashmaps from the .bsync folder
            // Even if locked.
             let _ = CleanupCommand()
        case "create-dmg"?,"create-disk-image"?:
            // Creates and mount a dmg
             let _ = CreateDmgCommand()
        case "snapshot"?:
            // Creates a crypted chunked snapshot with its own hashmap for each chunk
             let _ = SnapshotCommand()
        case "recover"?,"recover-from-snapshot"?:
            // Recovers a tree from crypted snapshot
             let _ = RecoverCommand()
        default:
            // We want to propose the best verb candidate
            let reference=[
                "h","help",
                "login",
                "logout",
                "verify","verify-credentials",
                "create-hashmap",
                "synchronize",
                "cd","create-directives",
                "run","run-directives",
                "rd","reveal-directives",
                "kvs","key-value-storage","keystore",
                "cleanup",
                "create-dmg","create-disk-image",
                "snapshoot",
                "recover","recover-from-snapshot"
            ]
            let bestCandidate=self.bestCandidate(firstArgumentAfterExecutablePath!, reference: reference)
            print("Hey ...\"bsync \(firstArgumentAfterExecutablePath!)\" is unexpected!")
            print("Did you mean:\"bsync \(bestCandidate)\"?")
            exit(EX__BASE)
        }
    }
    
    private func _noArgMessage()->String {
        var s=""
        s += "Bartleby's Sync client aka \"bsync\" is a delta synchronizer v1.0 R3"
        s += "\nCreated by Benoit Pereira da Silva"
        s += "\nhttps://pereira-da-silva.com for Chaosmos SAS"
        s += "\n"
        s += "\nvalid calls are S.V.O sentences like:\"bsync <verb> [options]\""
        s += "\n"
        s += "\n... TODO bpds => control the signatures !!!!!! "
        s += "\n"
        s += "\nAvailable verbs:"
        s += "\n"
        s += "\n\t# For synchronization #"
        s += "\n"
        s += "\n\t\(executableName) create-uid"
        s += "\n\t\(executableName) create-user [options]"
        s += "\n\t\(executableName) login -u <base api URL> [options]"
        s += "\n\t\(executableName) logout -u <base api URL> [options]"
        s += "\n\t\(executableName) verify-credentials -u <base api URL> [options]"
        s += "\n\t\(executableName) synchronize -s <source URL> -d <dest URL> ..."
        s += "\n\t\(executableName) create-directives -s <source URL> -d <dest URL> ..."
        s += "\n\t\(executableName) run <directive path>"
        s += "\n\t\(executableName) reveal-directives <directive path>"
        s += "\n\t\(executableName) create-hashmap <folder path> [options]"
        s += "\n"
        s += "\n\t#Crypted Key value storage aka \"bsync kvs\" #"
        s += "\n"
        s += "\n\t\(executableName) kvs -do upsert -f <folder path> -k <key> -v <value> -p <password> [options]"
        s += "\n\t\(executableName) kvs -do emumerate -f <folder path> -p <password> [options]"
        s += "\n\t\(executableName) kvs -do read -f <folder path> -k <key> -p <password> [options]"
        s += "\n\t\(executableName) kvs -do delete -f <folder path> -k <key> -p <password> [options]"
        s += "\n\t\(executableName) kvs -do remove-all -f <folder path> -p <password> [options]"
        s += "\n"
        s += "\n\t# Utilities #"
        s += "\n"
        s += "\n\t\(executableName) cleanup <folder path> [options]"
        s += "\n\t\(executableName) create-dmg -f <folder path> -n <volume name> [options]"
        s += "\n"
        s += "\n\t# Snapshots #"
        s += "\n"
        s += "\n\t\(executableName) snapshot -f <folder path> [options]"
        s += "\n\t\(executableName) recover -f <folder path> [options]"
        s += "\n"
        s += "\nRemember that you can call help for each verb"
        s += "\n"
        s += "\n\te.g:\t\"bsync synchronize help\""
        s += "\n\te.g:\t\"bsync snapshoot help\""
        s += "\n"
        return s
    }
    
    // MARK: levenshtein distance
    // https://en.wikipedia.org/wiki/Levenshtein_distance
    
    private func bestCandidate(string:String,reference:[String])->String{
        var selectedCandidate=string
        var minDistance:Int=Int.max
        for candidate in reference{
            let distance=self.levenshtein(string,candidate)
            if distance<minDistance{
                minDistance=distance
                selectedCandidate=candidate
            }
        }
        return selectedCandidate
    }
    
    private func min(numbers: Int...) -> Int {
        return numbers.reduce(numbers[0], combine: {$0 < $1 ? $0 : $1})
    }
    
    private class Array2D {
        var cols:Int, rows:Int
        var matrix: [Int]
        
        init(cols:Int, rows:Int) {
            self.cols = cols
            self.rows = rows
            matrix = Array(count:cols*rows, repeatedValue:0)
        }

        subscript(col:Int, row:Int) -> Int {
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
    
    private func levenshtein(aStr: String,_ bStr: String) -> Int {
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
                    dist[i, j] = min(
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