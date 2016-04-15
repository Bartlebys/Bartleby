//
//  Default.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 18/12/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation


// MARK: Default

public struct Default{
    
    // Bartleby Core Debug
    static public let BDEBUG_ENABLED=true
    
    // If set to JSON for example would be Indented
    static public let HUMAN_FORMATTED_SERIALIZATON_FORMAT=false
    
    //MARK: UserDefault key/values
    static public let SERVER_KEY="user_default_server"
    static public let USER_EMAIL_KEY="user_default_email"
    static public let USER_PASSWORD_KEY="user_default_password"
    
    //Misc constants
    
    
    static public let UID_KEY = "_id"
    
    static public let REFERENCE_NAME_KEY = "referenceName"
    
    static public let NOT_OBSERVABLE:String="NOT_OBSERVABLE"
    static public let NO_UID:String="NO_UID"
    static public let NO_NAME:String="NO_NAME"
    static public let NO_MESSAGE:String="NO_MESSAGE"
    static public let NO_KEY:String="NO_KEY"
    static public let NO_PATH:String="NO_PATH"
    static public let NO_CAKE:String="NO_CAKE"
    
    static public let MIN_PASSWORD_SIZE=6
    static public let SAVE_PASSWORD_DEFAULT_VALUE=false
    
    static public let NO_INT_INDEX=Int.max
    
    static let passwordsCharCart="123456789ABCDEFGHJKMNPQRSTUVWXYZ"
    
}

