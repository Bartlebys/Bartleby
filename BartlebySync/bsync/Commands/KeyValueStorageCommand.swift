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


class KeyValueStorageCommand: CryptedCommand {

    enum Actions: String {
        case Upsert  = "upsert"
        case Read = "read"
        case Delete = "delete" // the key
        case Enumerate = "enumerate"
        case RemoveAll = "remove-all" // the file
    }

    required init(completionHandler: CompletionHandler?) {
        super.init(completionHandler: completionHandler)

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

        let notInteractive = BoolOption(shortFlag: "x", longFlag: "not-interactive", required: false,
                                        helpMessage: "If you setup this option the execution of remove-all will not require an interaction")

        let help = BoolOption(shortFlag: "h", longFlag: "help",
                              helpMessage: "\nBartleby's standard command\nReads and write persitent key-values for a given path.\nAll the values are Crypted Using AES128 with a different key for each folder\n")

        addOptions( op,
                    keyArg,
                    value,
                    path,
                    password,
                    help,
                    notInteractive)

        if self.parse() {

            let key = secretKey + password.value!

            // Configure Bartleby without a specific URL
            Bartleby.configuration.KEY=key
            Bartleby.configuration.SHARED_SALT=sharedSalt
            Bartleby.configuration.API_CALL_TRACKING_IS_ENABLED=false
            Bartleby.configuration.BPRINT_API_TRACKED_CALLS = false
            Bartleby.sharedInstance.configureWith(Bartleby.configuration)

            let folderPath=path.value!+"/"
            let filePath=folderPath + "kvs.json"
            let fm=NSFileManager.defaultManager()
            var isAFolder: ObjCBool = false
            if fm.fileExistsAtPath(folderPath, isDirectory: &isAFolder) {
                if !isAFolder {
                    print("\(folderPath) is not a directory")
                    exit(EX__BASE)
                }
            } else {
                print("Unexisting folder \(folderPath)")
                exit(EX__BASE)
            }

            let kvs = BsyncKeyValueStorage(url: NSURL(fileURLWithPath: filePath))

            do {
                try kvs.open()


                switch op.value {
                case .Upsert?:
                    if let k=keyArg.value, v=value.value {
                        kvs.setStringValue(v, forKey: k)
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
                    if let k=keyArg.value {
                        if let v = kvs.getStringValueForKey(k) {
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
                    if let k=keyArg.value {
                        kvs.delete(k)
                    } else {
                        print("Undefined key")
                        exit(EX__BASE)
                    }
                case .Enumerate?:
                    for (k, v) in kvs.enumerate() {
                        print("\(k)=\(v)")
                    }
                case .RemoveAll?:
                    if notInteractive.value==true {
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
                self.on(Completion.successState())
            } catch {
                self.on(Completion.failureStateFromError(error))
            }
        }
    }

    func input() -> String? {
        let keyboard = NSFileHandle.fileHandleWithStandardInput()
        let inputData = keyboard.availableData
        return NSString(data: inputData, encoding:Default.STRING_ENCODING) as? String
    }

}
