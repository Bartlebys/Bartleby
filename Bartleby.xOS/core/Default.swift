//
//  Default.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 18/12/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation


// MARK: - BartlebyConfiguration
public protocol BartlebyConfiguration {

    // The key used to encrypt / decrypt
    static var KEY: String { get set }

    // This 32Bytes string is used to validate the tokens consistency
    // Should be the same server and client side and should not be disclosed
    static var SHARED_SALT: String { get set }

    // Collaboration server base URL
    // eg : https://demo.bartlebys.org/www/api/v1
    static var API_BASE_URL: URL { get set }

    // Bartleby Bprint
    static var ENABLE_BPRINT: Bool { get set }

    // Should Bprint entries be printed
    static var PRINT_BPRINT_ENTRIES: Bool { get set }

    // Use NoCrypto as CryptoDelegate
    static var DISABLE_DATA_CRYPTO: Bool { get }

    //If set to true the created instances will be remove on maintenance Purge
    static var EPHEMERAL_MODE: Bool { get set }

    //Should the app try to be online by default
    static var ONLINE_BY_DEFAULT: Bool { get set }

    // Consignation
    static var API_CALL_TRACKING_IS_ENABLED: Bool { get set }
    static var BPRINT_API_TRACKED_CALLS: Bool { get set }

    // Should we save the password by Default ?
    static var SAVE_PASSWORD_DEFAULT_VALUE: Bool { get set }

    // If set to JSON for example would be Indented
    static var HUMAN_FORMATTED_SERIALIZATON_FORMAT: Bool { get set }

    // The min password size
    static var MIN_PASSWORD_SIZE: UInt { get set }

    // E.g : Default.DEFAULT_PASSWORD_CHAR_CART
    static var PASSWORD_CHAR_CART: String { get set }

    // Supervision loop interval (1 second min )
    static var SUPERVISION_LOOP_TIME_INTERVAL_IN_SECONDS: Double { get set }

     // To guarantee the sequential Execution use 1 (!)
    static var MAX_OPERATIONS_BUNCH_SIZE: Int { get set }

    // Should the registries metadata be crypted on export
    static var CRYPTED_REGISTRIES_METADATA_EXPORT: Bool { get set }

    // If set to true the keyed changes are stored in the BartlebyObject - When opening the Inspector this default value is remplaced by true
    static var CHANGES_ARE_INSPECTABLES_BY_DEFAULT: Bool { get set }

}


// MARK: - BartlebyDefaultConfiguration

public struct BartlebyDefaultConfiguration: BartlebyConfiguration {

    // The key used to encrypt / decrypt
    public static var KEY: String="zHfAKvIb5DexA5hB18Jih92fKyv01niSMU38l8hPRddwduaJ_client"

    // This 32Bytes string is used to validate the tokens consistency
    // Should be the same server and client side and should not be disclosed
    public static var SHARED_SALT: String="rQauWtd9SFheA2koarKhMmHDvKjlB12qOIzVLmvAf7lOH6xdjQlSV9WG4TBYkYxK"

    // Collaboration server base URL
    // This bartlebys default ephemeral demo server (data are erased chronically)
    public static var API_BASE_URL: URL = URL(string: "https://demo.bartlebys.org/www/api/v1")!

    // Bartleby Bprint
    public static var ENABLE_BPRINT: Bool=true

    // Should Bprint entries be printed
    public static var PRINT_BPRINT_ENTRIES: Bool=true

    // Use NoCrypto as CryptoDelegate (should be false)
    public static var DISABLE_DATA_CRYPTO: Bool { return false }

    //If set to true the created instances will be remove on maintenance Purge
    public static var EPHEMERAL_MODE=true

    //Should the app try to be online by default
    public static var ONLINE_BY_DEFAULT=true

    // Consignation
    public static var API_CALL_TRACKING_IS_ENABLED: Bool=true
    public static var BPRINT_API_TRACKED_CALLS: Bool=true

    // Should we save the password by Default ?
    public static var SAVE_PASSWORD_DEFAULT_VALUE: Bool=false

    // If set to JSON for example would be Indented
    public static var HUMAN_FORMATTED_SERIALIZATON_FORMAT: Bool=false

    // The min password size
    public static var MIN_PASSWORD_SIZE: UInt=6

    // Supervision loop interval (1 second min )
    public static var SUPERVISION_LOOP_TIME_INTERVAL_IN_SECONDS: Double = 1

    // To guarantee the sequential Execution use 1
    public static var MAX_OPERATIONS_BUNCH_SIZE: Int=10

    // E.g : Default.DEFAULT_PASSWORD_CHAR_CART
    public static var  PASSWORD_CHAR_CART: String=Default.DEFAULT_PASSWORD_CHAR_CART

    // Should the registries metadata be crypted on export (should be true)!
    public static var CRYPTED_REGISTRIES_METADATA_EXPORT: Bool = true

    // If set to true the keyed changes are stored in the BartlebyObject - When opening the Inspector this default value is remplaced by true
    public static var CHANGES_ARE_INSPECTABLES_BY_DEFAULT: Bool = false


}

// MARK: - Default values

public struct Default {

    // B
    static public let LOG_CATEGORY="default"

    //MARK: UserDefault key/values
    static public let SERVER_KEY="user_default_server"
    static public let USER_EMAIL_KEY="user_default_email"
    static public let USER_PASSWORD_KEY="user_default_password"

    //Misc constants

    static public let UID_KEY = "_id"
    static public let TYPE_NAME_KEY = "typeName"

    static public let VOID_STRING=""

    static public let NOT_OBSERVABLE: String="NOT_OBSERVABLE"
    static public let NO_UID: String="NO_UID"
    static public let NO_NAME: String="NO_NAME"
    static public let NO_COMMENT: String="NO_COMMENT"
    static public let NO_MESSAGE: String="NO_MESSAGE"
    static public let NO_KEY: String="NO_KEY"
    static public let NO_PATH: String="NO_PATH"
    static public let NO_GEM: String="NO_GEM"
    static public let NO_GROUP: String="NO_GROUP"
    static public let NO_INT_INDEX=Int.max
    static public let STRING_ENCODING = String.Encoding.utf8


    // A bunch of char in wich to pick to compose a random password
    static let DEFAULT_PASSWORD_CHAR_CART="123456789ABCDEFGHJKMNPQRSTUVWXYZ"

}
