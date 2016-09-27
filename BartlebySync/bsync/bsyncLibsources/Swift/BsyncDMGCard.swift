//
//  BsyncDMGCard.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 28/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
    import BartlebyKit
#endif



/**
 *  A DMG card enable store the data required to unlock the DMG.
 */
@objc(BsyncDMGCard) open class BsyncDMGCard: JObject {

    override open class func typeName() -> String {
        return "BsyncDMGCard"
    }

    open static let NO_PATH="none"
    open static let NOT_SET="not-set"
    open static let DMG_EXTENSION="sparseimage"

    /// The user Unique Identifier
    open var userUID: String=BsyncDMGCard.NOT_SET

    // Associated to a context (e.g. project UID)
    open var contextUID: String=BsyncDMGCard.NOT_SET

    // The last kwnow path (if not correct the client should ask for a path)
    // The full path including the ".sparseimage" extension.
    open var imagePath: String=BsyncDMGCard.NO_PATH

    // The associated volumeName
    open var volumeName: String=BsyncDMGCard.NOT_SET

    // You can provide an optionnal sync directive path.
    open var directivesRelativePath: String=BsyncDMGCard.NO_PATH

    // The size of the disk image.
    open var size: String="1g"

    /// Returns the absolute volume path
    open var volumePath: String {
        get {
            return "/Volumes/\(volumeName)/"
        }
    }


    open var standardDirectivesPath: String {
        get {
            if self.directivesRelativePath != BsyncDMGCard.NO_PATH {
                return self.volumePath+"\(self.directivesRelativePath)"
            } else {
                return self.volumePath+"\(BsyncDirectives.DEFAULT_FILE_NAME)"
            }

        }
    }

    // MARK: Mappable


    public required init() {
        super.init()
    }

    required public init?(map: Map) {
        super.init()
        self.mapping(map:map)
    }


    /**
     Evaluates the validity of the card

     - returns: a block
     */
    open func evaluate() -> Completion {
        // Test the path
        let url=URL(fileURLWithPath:imagePath, isDirectory:false)
        let ext=url.pathExtension
        if ext != BsyncDMGCard.DMG_EXTENSION {
            return Completion.failureState(NSLocalizedString("Invalid path extension. The path must end by .\(BsyncDMGCard.DMG_EXTENSION). Current path:", comment: "Invalid path extension.")+"\(imagePath)", statusCode: .bad_Request)
        }

        // Verify that everything has been set.
        if (userUID == BsyncDMGCard.NOT_SET ||
            contextUID == BsyncDMGCard.NOT_SET ||
            imagePath == BsyncDMGCard.NO_PATH ||
            volumeName == BsyncDMGCard.NOT_SET) {
            return Completion.failureState(NSLocalizedString("The card is not correctly configured userUID,contextUID,path and volumeName must be set.", comment: "The card is not correctly configured.")+"\nuserUID = \(userUID),\ncontextUID = \(contextUID),\npath= \(imagePath),\n volumeName = \(volumeName)\n", statusCode: .bad_Request)
        } else {
            return Completion.successState()
        }
    }


    open override func mapping(map: Map) {
        super.mapping(map:map)
        self.silentGroupedChanges {
            userUID <- (map["userUID"], CryptedStringTransform())
            contextUID <- (map["contextUID"], CryptedStringTransform())
            imagePath <- (map["path"], CryptedStringTransform())
            volumeName <- (map["volumeName"], CryptedStringTransform())
            directivesRelativePath <- (map["directivesRelativePath"], CryptedStringTransform())
            size <- map["size"]
        }
    }

    // MARK: NSecureCoding


    open override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(userUID, forKey: "userUID")
        coder.encode(contextUID, forKey: "contextUID")
        coder.encode(imagePath, forKey: "path")
        coder.encode(volumeName, forKey: "volumeName")
        coder.encode(directivesRelativePath, forKey: "directivesRelativePath")
        coder.encode(size, forKey: "size")
    }

    public required init?(coder decoder: NSCoder) {
        super.init(coder:decoder)
        self.silentGroupedChanges {
            self.userUID=String(decoder.decodeObject(of: NSString.self, forKey: "userUID")! as NSString)
            self.contextUID=String(decoder.decodeObject(of: NSString.self, forKey: "contextUID")! as NSString)
            self.imagePath=String(decoder.decodeObject(of: NSString.self, forKey: "path")! as NSString)
            self.volumeName=String(decoder.decodeObject(of: NSString.self, forKey: "volumeName")! as NSString)
            self.directivesRelativePath=String(decoder.decodeObject(of: NSString.self, forKey: "directivesRelativePath")! as NSString)
            self.size=String(decoder.decodeObject(of: NSString.self, forKey: "size")! as NSString)
        }
    }

    override open class var supportsSecureCoding:Bool{
        return true
    }

    /**
     Returns a password.
     To be valid the userUID, contextUID must be consistant
     and bartleby should have be correctly initialized.

     - returns: the password
     */
    open func getPasswordForDMG() -> String {
        // This method will not return a correct password if Bartleby is not correctly initialized.
        do {
            return try CryptoHelper.hash(Bartleby.cryptoDelegate.encryptString(contextUID+userUID+Bartleby.configuration.SHARED_SALT))
        } catch {
            bprint("\(error)", file: #file, function: #function, line: #line)
            return "default-password-on-crypto-failure"
        }
    }


    // MARK: Identifiable

    override open class var collectionName: String {
        return "BsyncDMGCard"
    }
    
    override open var d_collectionName: String {
        return BsyncDMGCard.collectionName
    }
    
    
}
