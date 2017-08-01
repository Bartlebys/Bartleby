//
//  Profile.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/12/2016.
//
//

import Foundation

open class Profile:Codable{

    open var url:URL=Bartleby.configuration.API_BASE_URL
    open var documentUID:String=Default.NO_UID
    open var documentSpaceUID:String=Default.NO_UID
    open var user:User?
    open var requiresPatch=false

    public init() {}

}
