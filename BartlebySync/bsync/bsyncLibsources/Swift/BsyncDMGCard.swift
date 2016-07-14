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
 *  A protocol used to designate minimal contract to be an identifiable card context.
 */
protocol IdentifiableCardContext {
    var UID: String {get}
    var name: String {get set}
}

/**
 *  A DMG card enable store the data required to unlock the DMG.
 */
@objc(BsyncDMGCard) public class BsyncDMGCard: JObject {

    override public class func typeName() -> String {
        return "BsyncDMGCard"
    }

    public static let NO_PATH="none"
    public static let NOT_SET="not-set"
    public static let DMG_EXTENSION="sparseimage"

    /// The user Unique Identifier
    public var userUID: String=BsyncDMGCard.NOT_SET

    // Associated to a context (e.g. project UID)
    public var contextUID: String=BsyncDMGCard.NOT_SET

    // The last kwnow path (if not correct the client should ask for a path)
    // The full path including the ".sparseimage" extension.
    public var imagePath: String=BsyncDMGCard.NOT_SET

    // The associated volumeName
    public var volumeName: String=BsyncDMGCard.NOT_SET

    // You can provide an optionnal sync directive path.
    public var directivesRelativePath: String=BsyncDMGCard.NO_PATH

    // The size of the disk image.
    public var size: String="1g"

    /// Returns the absolute volume path
    public var volumePath: String {
        get {
            return "/Volumes/\(volumeName)"
        }
    }


    public var standardDirectivesPath: String {
        get {
            if self.directivesRelativePath != BsyncDMGCard.NO_PATH {
                 return self.volumePath+"/\(self.directivesRelativePath)"
            } else {
                return self.volumePath+"/\(BsyncDirectives.DEFAULT_FILE_NAME)"
            }

        }
    }

    // MARK: Mappable


    public required init() {
        super.init()
    }

    required public init?(_ map: Map) {
        super.init()
        self.mapping(map)
    }


    /**
     Evaluates the validity of the card

     - returns: a block
     */
    public func evaluate() -> Completion {
        // Test the path
        let url=NSURL(fileURLWithPath:imagePath, isDirectory:false)
        let ext=url.pathExtension
        if ext != BsyncDMGCard.DMG_EXTENSION {
            return Completion.failureState(NSLocalizedString("Invalid path extension. The path must end by .\(BsyncDMGCard.DMG_EXTENSION). Current path:", comment: "Invalid path extension.")+"\(imagePath)", statusCode: .Bad_Request)
        }

        // Verify that everything has been set.
        if (userUID == BsyncDMGCard.NOT_SET ||
            contextUID == BsyncDMGCard.NOT_SET ||
            imagePath == BsyncDMGCard.NOT_SET ||
            volumeName == BsyncDMGCard.NOT_SET) {
            return Completion.failureState(NSLocalizedString("The card is not correctly configured userUID,contextUID,path and volumeName must be set.", comment: "The card is not correctly configured.")+"\nuserUID = \(userUID),\ncontextUID = \(contextUID),\npath= \(imagePath),\n volumeName = \(volumeName)\n", statusCode: .Bad_Request)
        } else {
            return Completion.successState()
        }
    }


    public override func mapping(map: Map) {
        super.mapping(map)
        self.disableSupervision()
        userUID <- (map["userUID"], CryptedStringTransform())
        contextUID <- (map["contextUID"], CryptedStringTransform())
        imagePath <- (map["path"], CryptedStringTransform())
        volumeName <- (map["volumeName"], CryptedStringTransform())
        directivesRelativePath <- (map["directivesRelativePath"], CryptedStringTransform())
        self.enableSupervision()
    }

    // MARK: NSecureCoding


    public override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        coder.encodeObject(userUID, forKey: "userUID")
        coder.encodeObject(contextUID, forKey: "contextUID")
        coder.encodeObject(imagePath, forKey: "path")
        coder.encodeObject(volumeName, forKey: "volumeName")
        coder.encodeObject(directivesRelativePath, forKey: "directivesRelativePath")
    }

    public required init?(coder decoder: NSCoder) {
        super.init(coder:decoder)
        self.disableSupervision()
        self.userUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "userUID")! as NSString)
        self.contextUID=String(decoder.decodeObjectOfClass(NSString.self, forKey: "contextUID")! as NSString)
        self.imagePath=String(decoder.decodeObjectOfClass(NSString.self, forKey: "path")! as NSString)
        self.volumeName=String(decoder.decodeObjectOfClass(NSString.self, forKey: "volumeName")! as NSString)
        self.directivesRelativePath=String(decoder.decodeObjectOfClass(NSString.self, forKey: "directivesRelativePath")! as NSString)
        self.enableSupervision()
    }

    public override static func supportsSecureCoding() -> Bool {
        return true
    }

    /**
     Returns a password.
     To be valid the userUID, contextUID must be consistant
     and bartleby should have be correctly initialized.

     - returns: the password
     */
    public func getPasswordForDMG() -> String {
        // This method will not return a correct password if Bartleby is not correctly initialized.
        do {
            return try CryptoHelper.hash(Bartleby.cryptoDelegate.encryptString(contextUID+userUID+Bartleby.configuration.SHARED_SALT))
        } catch {
            bprint("\(error)", file: #file, function: #function, line: #line)
            return "default-password-on-crypto-failure"
        }
    }


    // MARK: Identifiable

    override public class var collectionName: String {
        return "BsyncDMGCard"
    }

    override public var d_collectionName: String {
        return BsyncDMGCard.collectionName
    }


}
