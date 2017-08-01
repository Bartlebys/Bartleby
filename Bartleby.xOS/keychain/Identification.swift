//
//  Identification.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 30/12/2016.
//
//

import Foundation

public struct Identification:Codable {

    public var email:String=""
    public var phoneCountryCode:String=""
    public var phoneNumber:String=""
    public var password:String=""
    public var externalID:String=Default.NO_UID
    public var supportsPasswordSyndication:Bool=Bartleby.configuration.SUPPORTS_PASSWORD_SYNDICATION_BY_DEFAULT

    public static func identificationFrom(user:User)->Identification{
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
