//
//  BsyncImageDiskManager.swift
//  Bartleby's Sync client aka "bsync"
//
//  BsyncImageDiskManager is available for OSX
//  And excluded from other targets.
//
//  Created by Benoit Pereira da silva on 26/12/2015.
//  Copyright © 2015 Benoit Pereira da silva. All rights reserved.
//
//  The ImageDiskManager.swift is a wrapper around hdiutil
//  that perform DMG management operations
//  It allows to create DMGs with password and strong encryption
//  And to attach/detach the Volume programmatically.

#if os(OSX)
    
    import Cocoa
#if !USE_EMBEDDED_MODULES
    import ObjectMapper
    import BartlebyKit
#endif
        
    public class BsyncImageDiskManager {
        
        var type="SPARSE"
        var encryption="AES-128"
        var file_system="HFS+J"
        
        // TODO: @md ???
        var password: String?
        
        // https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/hdiutil.1.html
        // echo -n popok|hdiutil create -size 30g -type SPARSE -fs HFS+J -volname "Video Locker" -nospotlight -stdinpass -encryption AES-128 ~/Desktop/V
        // echo -n popok|hdiutil attach -stdinpass /Users/bpds/Desktop/V.sparseimage
        
        
        //MARK: - Image Disk Creation
        
        public func createImageDiskWithName(imageFilePath: String, size: String, password: String?, handlers: Handlers) {
            if let volumeName=NSString(string: imageFilePath).pathComponents.last {
                self.createImageDisk(imageFilePath, volumeName:volumeName, size: size, password: password, handlers: handlers)
            } else {
                handlers.on(Completion.failureState("Bad image file path: \(imageFilePath)", statusCode: .Bad_Request))
            }
        }
        
        /**
         Creates an image disk
         
         - parameter imageFilePath: the file path (absolute nix style)
         - parameter volumeName:    the volume name
         - parameter size:          a size e.g : "10m" = 10MB "1g"=1GB
         - parameter password:      the password (if omitted the disk image will not be crypted
         */
        public func createImageDisk(imageFilePath: String, volumeName: String, size: String, password: String?, handlers: Handlers) {
            
            // TODO: @md ???
            let path: NSString=NSString(string: imageFilePath)
            let imagePath: String=path as String
            self.password=password
            
            // Main task
            let createImageDiskTask=NSTask()
            createImageDiskTask.launchPath="/usr/bin/hdiutil"
            
            if let password=password {
                let interPipe=NSPipe()
                // Password injection task
                let passwordTask=NSTask()
                passwordTask.launchPath="/bin/echo"
                passwordTask.standardOutput=interPipe
                passwordTask.arguments=["-n", password]
                createImageDiskTask.standardInput=interPipe
                createImageDiskTask.arguments=[
                    "create",
                    "-size", size,
                    "-type", self.type,
                    "-fs", self.file_system,
                    "-nospotlight",
                    // "-debug",
                    // TODO: @md Try to get progress with puppetstring
                    //"-puppetstrings",
                    //"-verbose",
                    "-stdinpass",
                    "-volname", volumeName,
                    "-encryption", self.encryption, imagePath
                ]
                
                passwordTask.launch()
                passwordTask.waitUntilExit()
            } else {
                // No password, No Encryption
                createImageDiskTask.arguments=[
                    "create",
                    "-size", size,
                    "-type", self.type,
                    "-fs", self.file_system,
                    "-nospotlight",
                    //"-debug",
                    //"-puppetstrings",
                    //"-verbose",
                    "-volname", volumeName,
                    imagePath
                ]
            }
            
            let outPipe=NSPipe()
            createImageDiskTask.standardOutput=outPipe
            createImageDiskTask.launch()
            createImageDiskTask.waitUntilExit()
            
            
            switch createImageDiskTask.terminationReason {
            case NSTaskTerminationReason.Exit:
                print("Exit")
            case NSTaskTerminationReason.UncaughtSignal:
                print("UncaughtSignal")
            }
            
            let completion = Completion.defaultState()
            if createImageDiskTask.terminationStatus==0 {
                completion.success = true
                completion.setStringResult("\(imageFilePath).sparseimage")
            } else {
                completion.message = "Error during image disk creation: \(imageFilePath)"
            }
            handlers.on(completion)
        }
        
        //MARK: - Image Disk Attach / Detach
        
        /**
         Attaches a Volume from a Dmg path
         
         - parameter path:         the path
         - parameter withPassword: the password
         
         - returns: return value description
         */
        public func attachVolume(from path: String, withPassword: String?, handlers: Handlers) {
            // Main task
            let attachDiskTask=NSTask()
            attachDiskTask.launchPath="/usr/bin/hdiutil"
            
            if let password=withPassword {
                let interPipe=NSPipe()
                // Password injection task
                let passwordTask=NSTask()
                passwordTask.launchPath="/bin/echo"
                passwordTask.standardOutput=interPipe
                passwordTask.arguments=["-n", password]
                attachDiskTask.standardInput=interPipe
                attachDiskTask.arguments=[
                    "attach",
                    "-stdinpass",
                    "-noverify",
                    path
                    
                    
                ]
                passwordTask.launch()
                passwordTask.waitUntilExit()
            } else {
                // No password, No Encryption
                attachDiskTask.arguments=[
                    "attach",
                    "-noverify",
                    path
                ]
            }
            
            let outPipe=NSPipe()
            attachDiskTask.standardOutput=outPipe
            
            attachDiskTask.launch()
            attachDiskTask.waitUntilExit()
            
            
            switch attachDiskTask.terminationReason {
            case NSTaskTerminationReason.Exit:
                print("Exit")
            case NSTaskTerminationReason.UncaughtSignal:
                print("UncaughtSignal")
            }
            
            let completion = Completion.defaultState()
            if attachDiskTask.terminationStatus==0 {
                completion.success = true
            } else {
                completion.message = "Error attaching volume: \(path)"
            }
            handlers.on(completion)
        }
        
        
        /**
         Detaches the volume
         
         - parameter named: the name of the Volume
         
         - returns: true on success
         */
        public func detachVolume(named: String, handlers: Handlers) {
            // Main task
            let detachDiskTask=NSTask()
            let path="/Volumes/\(named)"
            detachDiskTask.launchPath="/usr/bin/hdiutil"
            detachDiskTask.arguments=[
                "detach",
                path
                
            ]
            detachDiskTask.launch()
            detachDiskTask.waitUntilExit()
            
            switch detachDiskTask.terminationReason {
            case NSTaskTerminationReason.Exit:
                print("Exit")
            case NSTaskTerminationReason.UncaughtSignal:
                print("UncaughtSignal")
            }
            
            let completion = Completion.defaultState()
            if detachDiskTask.terminationStatus==0 {
                completion.success = true
            } else {
                completion.message = "Error detaching volume: \(path)"
            }
            handlers.on(completion)
            
        }
    }
    
#endif
