//
//  JHTTPCommand.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 15/12/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation
#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif
/**
 *  A JSON Flavoured HTTPCommand
 */
public protocol JHTTPCommand:  Collectible, Mappable, NSCopying, NSSecureCoding,HTTPCommand {

}
