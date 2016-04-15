//
//  Default.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 18/12/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation


// MARK: - BartlebyConfiguration
public protocol BartlebyConfiguration{
    
    // The key used to encrypt / decrypt
    static var KEY:String { get }
    
    // This 32Bytes string is used to validate the tokens consistency
    // Should be the same server and client side and should not be disclosed
    static var SHARED_SALT:String { get }

    // Collaboration server base URL
    // eg : http://yd.local/api/v1
    static var API_BASE_URL:NSURL { get }
    
    // Bartleby Bprint
    static var ENABLE_BPRINT:Bool { get }
    
    // Consignation
    static var API_CALL_TRACKING_IS_ENABLED:Bool { get }

    // Should we save the password by Default ?
    static var SAVE_PASSWORD_DEFAULT_VALUE:Bool { get }
    
    // If set to JSON for example would be Indented
    static var HUMAN_FORMATTED_SERIALIZATON_FORMAT:Bool { get }
    
    // The min password size
    static var MIN_PASSWORD_SIZE:UInt { get }
    
    // E.g : Default.DEFAULT_PASSWORD_CHAR_CART
    static var PASSWORD_CHAR_CART:String { get }
    
}


// MARK: - BartlebyDefaultConfiguration

public struct BartlebyDefaultConfiguration:BartlebyConfiguration{
    
    
    // The key used to encrypt / decrypt
    public static var KEY:String {
        get {
            return ""
        }
    }
    
    // This 32Bytes string is used to validate the tokens consistency
    // Should be the same server and client side and should not be disclosed
    public static var SHARED_SALT:String {
        get {
            return ""
        }
    }
    
    // Collaboration server base URL
    // eg : http://yd.local/api/v1
    public static var API_BASE_URL:NSURL {
        get {
            return NSURL()
        }
    }
    // Bartleby Bprint
    public static var ENABLE_BPRINT:Bool{
        get {
            return true
        }
    }
    
    // Consignation
    public static var  API_CALL_TRACKING_IS_ENABLED:Bool{
        get {
            return true
        }
    }
    
    // Should we save the password by Default ?
    public static var SAVE_PASSWORD_DEFAULT_VALUE:Bool{
        get {
            return false
        }
    }


    // If set to JSON for example would be Indented
    public static var HUMAN_FORMATTED_SERIALIZATON_FORMAT:Bool{
        get {
            return false
        }
    }


    // The min password size
    public static var MIN_PASSWORD_SIZE:UInt {
        get {
            return 6
        }
    }

    
    // E.g : Default.DEFAULT_PASSWORD_CHAR_CART
    public static var  PASSWORD_CHAR_CART:String {
        get {
            return Default.DEFAULT_PASSWORD_CHAR_CART
        }
    }

    
}

// MARK: - Default values

public struct Default{
    
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
    
    static public let NO_INT_INDEX=Int.max
    
    static let DEFAULT_PASSWORD_CHAR_CART="123456789ABCDEFGHJKMNPQRSTUVWXYZ"
    
}

