//
//  Profile.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//
//

import Foundation

public struct Profile:Codable{

    public var url:URL=Bartleby.configuration.API_BASE_URL
    public var documentUID:String=Default.NO_UID
    public var documentSpaceUID:String=Default.NO_UID
    public var user:User?
    public var requiresPatch=false

    public init() {}

}
