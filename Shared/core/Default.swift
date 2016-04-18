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
    static var KEY:String { get set }
    
    // This 32Bytes string is used to validate the tokens consistency
    // Should be the same server and client side and should not be disclosed
    static var SHARED_SALT:String { get set }

    // Collaboration server base URL
    // eg : https://demo.bartlebys.org/api/v1
    static var API_BASE_URL:NSURL { get set }
    
    // Bartleby Bprint
    static var ENABLE_BPRINT:Bool { get set }
    
    // Consignation
    static var API_CALL_TRACKING_IS_ENABLED:Bool { get set }
    static var BPRINT_API_TRACKED_CALLS:Bool { get set }

    // Should we save the password by Default ?
    static var SAVE_PASSWORD_DEFAULT_VALUE:Bool { get set }
    
    // If set to JSON for example would be Indented
    static var HUMAN_FORMATTED_SERIALIZATON_FORMAT:Bool { get set }
    
    // The min password size
    static var MIN_PASSWORD_SIZE:UInt { get set }
    
    // E.g : Default.DEFAULT_PASSWORD_CHAR_CART
    static var PASSWORD_CHAR_CART:String { get set }
    
    // Delay between chained operations
    static var DELAY_BETWEEN_OPERATIONS_IN_SECONDS:Double { get set }
    
}


// MARK: - BartlebyDefaultConfiguration

public struct BartlebyDefaultConfiguration:BartlebyConfiguration{
    
    // The key used to encrypt / decrypt
    public static var KEY:String=""
    
    // This 32Bytes string is used to validate the tokens consistency
    // Should be the same server and client side and should not be disclosed
    public static var SHARED_SALT:String=""
    
    // Collaboration server base URL
    // eg : https://demo.bartlebys.org/api/v1
    public static var API_BASE_URL:NSURL=NSURL()
    
    // Bartleby Bprint
    public static var ENABLE_BPRINT:Bool=true

    // Consignation
    public static var API_CALL_TRACKING_IS_ENABLED:Bool=true
    public static var BPRINT_API_TRACKED_CALLS:Bool=true

    
    // Should we save the password by Default ?
    public static var SAVE_PASSWORD_DEFAULT_VALUE:Bool=false

    // If set to JSON for example would be Indented
    public static var HUMAN_FORMATTED_SERIALIZATON_FORMAT:Bool=false

    // The min password size
    public static var MIN_PASSWORD_SIZE:UInt=6

    // Delay between chained operations
    public static var DELAY_BETWEEN_OPERATIONS_IN_SECONDS:Double=Double(1/10)
    
    // E.g : Default.DEFAULT_PASSWORD_CHAR_CART
    public static var  PASSWORD_CHAR_CART:String=Default.DEFAULT_PASSWORD_CHAR_CART
    
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
    
    // A bunch of char in wich to pick to compose a random password 
    static let DEFAULT_PASSWORD_CHAR_CART="123456789ABCDEFGHJKMNPQRSTUVWXYZ"
    
}

