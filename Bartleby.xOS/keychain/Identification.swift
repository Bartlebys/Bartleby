//
//  Identification.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 30/12/2016.
//
//

import Foundation

open class Identification:Codable {

    open var email:String=""
    open var phoneCountryCode:String=""
    open var phoneNumber:String=""
    open var password:String=""
    open var externalID:String=Default.NO_UID
    open var supportsPasswordSyndication:Bool=Bartleby.configuration.SUPPORTS_PASSWORD_SYNDICATION_BY_DEFAULT

    open static func identificationFrom(user:User)->Identification{
        var identification=Identification()
        identification.email=user.email
        identification.phoneCountryCode=user.phoneCountryCode
        identification.phoneNumber=user.phoneNumber
        identification.password=user.password
        identification.externalID=user.externalID
        identification.supportsPasswordSyndication=user.supportsPasswordSyndication
        return identification
    }
}
