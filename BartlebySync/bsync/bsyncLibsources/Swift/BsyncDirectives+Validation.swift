//
//  BsyncDirectives.swift
//  Bartleby's Sync client aka "bsync"
//
//
//  Created by Benoit Pereira da silva on 30/12/2015.
//  Copyright © 2015 Benoit Pereira da silva. All rights reserved.
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
    import BartlebyKit
#endif

/**
 *  Directives are serializeed in files
 *  One of the URL must be local, to mark it is local it is set to nil
 *  and we use its parent folder as tree root
 *  It suppports NSSecureCoding as it can be to perform XPC calls.
 */
extension BsyncDirectives{

    open func areValid()->(valid: Bool, message: String) {
        if let sourceURL = self.sourceURL, let destinationURL = self.destinationURL {

            let destinationScheme=destinationURL.scheme ?? "NOT_FOUND"
            let sourceScheme=sourceURL.scheme ?? "NOT_FOUND"
            let destinationIsDistant = BsyncDirectives.distantSchemes.index(of: destinationScheme) != nil
            let sourceIsDistant = BsyncDirectives.distantSchemes.index(of: sourceScheme) != nil

            if (sourceIsDistant || destinationIsDistant) {
                if self.user == nil {
                    return (false, NSLocalizedString("Distant directives need a user", comment: ""))
                }
                if self.password == nil {
                    return (false, NSLocalizedString("Distant directives need a password", comment: ""))
                }
                if self.salt == nil {
                    return (false, NSLocalizedString("Distant directives need a shared salt", comment: ""))
                }
            }

            if (self.hashMapViewName != nil) && destinationIsDistant {
                return (false, NSLocalizedString("Hash map view must be restricted when synchronizing to the final consumer", comment: ""))
            }

        } else {
            return (false, NSLocalizedString("The source and the destination must be set", comment: "The source and the destination must be set"))
        }

        return (true, "")
    }

    /**
     Creates an upStream directives.

     - parameter distantURL:  distantURL should conform with ${API_BASE_URL}BartlebySync/tree/${TREE_ID}
     - parameter localPath:  path to local folder

     - returns: the directives
     */
    open static func upStreamDirectivesWithDistantURL(_ distantURL: URL, localPath: String) -> BsyncDirectives {
        let directives=BsyncDirectives()
        directives.sourceURL = URL(fileURLWithPath: localPath)
        directives.destinationURL = distantURL
        return directives

    }
    /**
     Creates a downStream directives.

     - parameter distantURL:  distantURL should conform with ${API_BASE_URL}BartlebySync/tree/${TREE_ID}
     - parameter localPath:  path to local folder

     - returns: the directives
     */
    open static func downStreamDirectivesWithDistantURL(_ distantURL: URL, localPath: String) -> BsyncDirectives {
        let directives=BsyncDirectives()
        directives.sourceURL = distantURL
        directives.destinationURL = URL(fileURLWithPath: localPath)
        return directives
    }

    /**
     Creates a local directives.

     - parameter sourcePath:  path to source folder
     - parameter localPath:  path to destination folder

     - returns: the directives
     */
    open static func localDirectivesWithPath(_ sourcePath: String, destinationPath: String) -> BsyncDirectives {
        let directives=BsyncDirectives()
        directives.sourceURL = URL(fileURLWithPath: sourcePath)
        directives.destinationURL = URL(fileURLWithPath: destinationPath)
        return directives
    }

}
