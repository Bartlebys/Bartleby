//
//  DefaultCommand.swift
//  Bartleby's generic command.
//
//  Used in Bsync and repackagable has a standalone commandline.
//  Allows to manipulate crypted key value storage.
//
//  Created by Benoit Pereira da Silva on 06/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license


import Cocoa

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif


class KeyValueStorageCommand: CommandBase {
    
    enum Actions : String {
        case Upsert  = "upsert"
        case Read = "read"
        case Delete = "delete" // the key
        case Enumerate = "enumerate"
        case RemoveAll = "remove-all" // the file
    }
    
    override init() {
        super.init()
        
        let op = EnumOption<KeyValueStorageCommand.Actions>(shortFlag: "d", longFlag: "do", required: true,
            helpMessage:"What to do on key-values for a given path"+"\n\t\"upsert\"to insert or create a new key-value, \n\t\"delete\" to delete a key-value pair,\n\t\"enumerate\" to enumerate the current key-value,\n\t\"read\" for read\n\tremove-all to destroy the file")
       
        let keyArg = StringOption(shortFlag: "k", longFlag: "key", required: false,
            helpMessage: "The key name")
        
        let value = StringOption(shortFlag: "v", longFlag: "value", required: false,
            helpMessage: "The string value")
        
        let path = StringOption(shortFlag: "f", longFlag: "folder", required: true,
            helpMessage: "Path to the folder ")
        
        let password = StringOption(shortFlag: "p", longFlag: "password", required: true,
            helpMessage: "The password")
        
        
        let secretKey = StringOption(shortFlag: "i", longFlag: "secretKey",required: true,
            helpMessage: "The secret key to encryp the data (if not set we use bsync's default)")
        
        let sharedSalt = StringOption(shortFlag: "t", longFlag: "salt",required: true,
            helpMessage: "The salt (if not set we use bsync's default)")
        
        let notInteractive = BoolOption(shortFlag: "x", longFlag: "not-interactive", required: false,
            helpMessage: "If you setup this option the execution of remove-all will not require an interaction")
        
        let help = BoolOption(shortFlag: "h", longFlag: "help",
            helpMessage: "\nBartleby's standard command\nReads and write persitent key-values for a given path.\nAll the values are Crypted Using AES128 with a different key for each folder\n")
        
        cli.addOptions( op,
                        keyArg,
                        value,
                        path,
                        password,
                        help,
                        secretKey,
                        sharedSalt,
                        notInteractive)
        
        do {
            try cli.parse()
            do{
               
                let key = secretKey.value!+password.value!
                let salt = sharedSalt.value!
                
                // Configure Bartleby without a specific URL
                Bartleby.configuration.KEY=key
                Bartleby.configuration.SHARED_SALT=salt
                Bartleby.configuration.API_CALL_TRACKING_IS_ENABLED=false
                Bartleby.configuration.BPRINT_API_TRACKED_CALLS = false
                Bartleby.sharedInstance.configureWith(Bartleby.configuration)
                
                let folderPath=path.value!+"/"
                let filePath=folderPath + "kvs.data"
                let fm=NSFileManager.defaultManager()
                var isAFolder : ObjCBool = false
                if fm.fileExistsAtPath(folderPath, isDirectory: &isAFolder){
                    if !isAFolder{
                        print("\(folderPath) is not a directory")
                        exit(EX__BASE)
                    }
                } else {
                    print("Unexisting folder \(folderPath)")
                    exit(EX__BASE)
                }
                
                let kvs = BsyncKeyValueStorage(filePath: filePath)
                
                try kvs.open()
                
                switch op.value {
                case .Upsert?:
                    if let k=keyArg.value,v=value.value{
                        if let v = v as? Serializable {
                            kvs[k] = v
                        }
                    } else {
                        print("We creating or updating a (key,value) pair")
                        print("key and value must be defined!")
                        let k = (keyArg.value ?? "is void" )
                        let v = (value.value ?? "is void" )
                        print("Key: \(k)")
                        print("Value: \(v)")
                        exit(EX__BASE)
                    }
                case .Read?:
                    if let k=keyArg.value{
                        if let v = kvs[k] {
                            print("The value of \(k) is: ")
                            print("")
                            print(v)
                            print("")
                        } else {
                            print("Error retrieving key")
                        }
                    } else {
                        print("Undefined key")
                        exit(EX__BASE)
                    }
                case .Delete?:
                    if let k=keyArg.value{
                        kvs.delete(k)
                    } else {
                        print("Undefined key")
                        exit(EX__BASE)
                    }
                case .Enumerate?:
                    for (k,v) in kvs.enumerate() {
                        print("\(k)=\(v)")
                    }
                case .RemoveAll?:
                    if notInteractive.value==true{
                        try kvs.removeAll()
                    } else {
                        print("This deletion is irreversible - Do you want to delete all the data Y/N?")
                        if let s=input() {
                            if s.lowercaseString == "y" {
                                try kvs.removeAll()
                            }
                        } else {
                            print("Infinite loop?")
                            exit(EX__BASE)
                        }
                    }
                case nil:
                    break
                }
                
                try kvs.save()

                exit(EX_OK)
            }
        } catch BsyncKeyValueStorageError.CorruptedData {
            print("Raw Deserialization failed - Corrupted data")
            exit(EX__BASE)
        } catch BsyncKeyValueStorageError.OtherDataProblem {
            print("Humm there is a problem with your data")
            exit(EX__BASE)
        } catch {
            cli.printUsage(error)
            exit(EX_USAGE)
        }
    }
    
    func input() -> String?{
        let keyboard = NSFileHandle.fileHandleWithStandardInput()
        let inputData = keyboard.availableData
        return NSString(data: inputData, encoding:NSUTF8StringEncoding) as? String
    }
    
}