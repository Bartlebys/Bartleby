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
            // Main task
            let createImageDiskTask=NSTask()
            createImageDiskTask.launchPath="/usr/bin/hdiutil"

            if let password = password {
                let interPipe=NSPipe()
                // Password injection task
                let passwordTask = NSTask()
                passwordTask.launchPath = "/bin/echo"
                passwordTask.standardOutput = interPipe
                passwordTask.arguments=["-n", password]
                createImageDiskTask.standardInput = interPipe
                createImageDiskTask.arguments=[
                    "create",
                    "-size", size,
                    "-type", self.type,
                    "-fs", self.file_system,
                    "-nospotlight",
                    // "-debug",
                    // TODO: @md #bsync Try to get progress with puppetstring
                    //"-puppetstrings",
                    //"-verbose",
                    "-stdinpass",
                    "-volname", volumeName,
                    "-encryption", self.encryption, imageFilePath
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
                    imageFilePath
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
                completion.setStringResult("\(imageFilePath)."+BsyncDMGCard.DMG_EXTENSION)
            } else {
                completion.success = false
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
            let outPipe=NSPipe()
            detachDiskTask.standardOutput=outPipe
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
                completion.success = false
                completion.message = "Error detaching volume: \(path)"
            }
            handlers.on(completion)

        }

        /**
         # Man hdiutil extraction

         `resize size_spec image`

         Resize a disk image or the containers within it.  For an image containing a trailing Apple_HFS partition, the default
         is to resize the image container, the partition, and the filesystem within it by aligning the end of the hosted struc-
         tures with the end of the image.  hdiutil resize cannot resize filesystems other than HFS+ and its variants.

         resize can shrink an image so that its HFS+ partition can be converted to CD-R/DVD-R format and still be burned.
         hdiutil resize will not reclaim gaps because it does not move data.  diskutil(8)'s resize can move filesystem data
         which can help hdiutil resize create a minimally-sized image.  -fsargs can also be used to minimize filesystem gaps
         inside an image.

         resize is limited by the disk image container format (e.g. UDSP vs. UDSB), any partition scheme, the hosted filesys-
         tem, and the filesystem hosting the image.  In the case of HFS+ inside of GPT inside of a UDRW on HFS+ with adequate
         free space, the limit is approximately 2^63 bytes.  Older images created with an APM partition scheme are limited by
         it to 2TB.  Before Mac OS X 10.4, resize was limited by how the filesystem was created (see hdiutil create -stretch).

         hdiutil burn does not burn Apple_Free partitions at the end of the devices, so an image with a resized filesystem can
         be burned to create a CD-R/DVD-R master that contains only the actual data in the hosted filesystem (assuming minimal
         data fragmentation).

         Common options: -encryption, -stdinpass, -srcimagekey, -shadow and related, and -plist.

         Size specifiers:
         -size ??b|??k|??m|??g|??t|??p|??e
         data fragmentation).

         Common options: -encryption, -stdinpass, -srcimagekey, -shadow and related, and -plist.

         Size specifiers:
         -size ??b|??k|??m|??g|??t|??p|??e
         -sectors sector_count | min
         Specify the number of 512-byte sectors to which the partition should be resized.  If this falls out-
         side the mininum valid value or space remaining on the underlying file system, an error will be
         returned and the partition will not be resized.  min automatically determines the smallest possible
         size.

         Other options:
         -imageonly       only resize the image file, not the partition(s) and filesystems inside of it.
         -partitiononly   only resize a partition / filesystem in the image, not the image.  -partitiononly will fail if the
         new size won't fit inside the image.  On APM, shrinking a partition results in an explicit Apple_Free
         entry taking up the remaining space in the image.
         -partitionNumber partitionNumber
         specifies which partition to resize (UDIF only -- see HISTORY below).  partitionNumber is 0-based,
         but, per hdiutil pmap, partition 0 is the partition map itself.

         -growonly        only allow the image to grow
         -shrinkonly      only allow the image to shrink
         -nofinalgap      allow resize to entirely eliminate the trailing free partition in an APM map.  Restoring such images
         to very old hardware may interfere with booting.
         
         -limits          Displays the minimum, current, and maximum sizes (in 512-byte sectors) for the image.  In addition to
         any hosted filesystem constraints, UDRW images are constrained by available disk space in the
         filesystem hosting the image.  -limits does not modify the image.
         
         Resizes the image the image must be mounted.

         - parameter size:       the size according to sizeSpecs ??b|??k|??m|??g|??t|??p|??e
         - parameter volumePath: the volume path
         - parameter handler:    the handler
         */
        public func resizeDMG(size:String,imageFilePath:String,password:String?,completionHandler:CompletionHandler){
            // Main task
            let resizeTask=NSTask()
            resizeTask.launchPath="/usr/bin/hdiutil"

            if let password=password {
                let interPipe=NSPipe()
                // Password injection task
                let passwordTask=NSTask()
                passwordTask.launchPath="/bin/echo"
                passwordTask.standardOutput=interPipe
                passwordTask.arguments=["-n", password]
                resizeTask.standardInput=interPipe
                resizeTask.arguments=[
                    "resize",
                    "-size",
                    size,
                    imageFilePath,
                    "-stdinpass",
                    //"-growonly"
                ]
                passwordTask.launch()
                passwordTask.waitUntilExit()
            } else {
                // No password
                resizeTask.arguments=[
                    "resize",
                    "-size",
                    size,
                    imageFilePath
                   // "-growonly"
                ]
            }

            let outPipe=NSPipe()
            resizeTask.standardOutput=outPipe
            resizeTask.launch()
            resizeTask.waitUntilExit()

            switch resizeTask.terminationReason {
            case NSTaskTerminationReason.Exit:
                print("Exit")
            case NSTaskTerminationReason.UncaughtSignal:
                print("UncaughtSignal")
            }

            let completion = Completion.defaultState()
            if resizeTask.terminationStatus==0 {
                completion.success = true
            } else {
                completion.success = false
                completion.message = "Error resizing volume: \(imageFilePath) size\(size)"
            }
            completionHandler(completion)
        }
    }
    
#endif
