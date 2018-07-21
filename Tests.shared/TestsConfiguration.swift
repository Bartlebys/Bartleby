//
//  TestsConfiguration.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 29/12/2015.
//  Copyright © 2015 Benoit Pereira da silva. All rights reserved.
//

import Foundation

#if !USE_EMBEDDED_MODULES && !IN_YOUDUBROBOT && !IN_BARTLEBY_KIT
    import BartlebyKit
#endif


// A shared configuration Model
open class TestsConfiguration: BartlebyConfiguration {


    // The cryptographic key used to encrypt/decrypt the data
    public static let KEY: String=Bartleby.randomStringWithLength(1024)


    public static let SHARED_SALT: String="xyx38-d890x-899h-123e-30x6-3234e"

    // To conform to crypto legal context
    public static var KEY_SIZE: KeySize = .s128bits


    //MARK: - URLS

    static let trackAllApiCalls=true

    public static var API_BASE_URL=__BASE_URL

    public static var defaultBaseURLList: [String] {
        return ["http://yd.local:8001/api/v1","https://dev.api.lylo.tv/api/v1","https://api.lylo.tv/api/v1","https://demo.bartlebys.org/www/api/v1"]
    }



    // Bartleby Bprint
    public static var ENABLE_GLOG: Bool=true

    // Should Bprint entries be printed
    public static var PRINT_GLOG_ENTRIES: Bool=true

    // Use NoCrypto as CryptoDelegate (should be false)
    public static var DISABLE_DATA_CRYPTO: Bool=false

    //If set to true the created instances will be remove on maintenance Purge
    public static var EPHEMERAL_MODE=true

    //Should the app try to be online by default
    public static var ONLINE_BY_DEFAULT=true

    // Consignation
    public static var API_CALL_TRACKING_IS_ENABLED: Bool=true
    public static var BPRINT_API_TRACKED_CALLS: Bool=true


    // Should we save the password by Default ?
    public static var SAVE_PASSWORD_BY_DEFAULT: Bool=false

    // If set to JSON for example would be Indented
    public static var HUMAN_FORMATTED_SERIALIZATON_FORMAT: Bool=false

    // Supervision loop interval (1 second min )
    public static var LOOP_TIME_INTERVAL_IN_SECONDS: Double = 1

     // To guarantee the sequential Execution use 1
    public static var MAX_OPERATIONS_BUNCH_SIZE: Int = 10

    // The min password size
    public static var MIN_PASSWORD_SIZE: UInt=6

    // E.g : Default.DEFAULT_PASSWORD_CHAR_CART
    public static var PASSWORD_CHAR_CART: String="ABCDEFGH1234567890"

    // If set to true the keyed changes are stored in the ManagedModel - When opening the Inspector this default value is remplaced by true
    public static var CHANGES_ARE_INSPECTABLES_BY_DEFAULT: Bool = false

    // If set to true the confirmation code will be for example printed in the console...
    public static let DEVELOPER_MODE: Bool = true // Should be turned to false in production

    // If set to true identification will not require second auth factor.
    public static var SECOND_AUTHENTICATION_FACTOR_IS_DISABLED:Bool = false

    // Supports by default KeyChained password synchronization between multiple local accounts (false is more secured)
    public static let SUPPORTS_PASSWORD_SYNDICATION_BY_DEFAULT: Bool = false

    // Supports by default the ability to update the password. Recovery procedure for accounts that have allready be saved in the KeyChain (false is more secured)
    public static var SUPPORTS_PASSWORD_UPDATE_BY_DEFAULT: Bool = false

    // Allows by default users to memorize password (false is more secured)
    public static var SUPPORTS_PASSWORD_MEMORIZATION_BY_DEFAULT: Bool = false

    // If set to true the user can skip the account creation and stay fully offline.
    public static var ALLOW_ISOLATED_MODE: Bool = false

    // If set to true each document has it own isolated user
    public static var AUTO_CREATE_A_USER_AUTOMATICALLY_IN_ISOLATED_MODE: Bool = false

    //MARK: - Variable base URL

    enum Environment {
        case local
        case development
        case alternative
        case production
    }

    static var currentEnvironment: Environment = .development

    static fileprivate var __BASE_URL: URL {
        get {
            switch currentEnvironment {
            case .local:
                // On macOS you should point "yd.local" to your IP by editing /etc/host
                return URL(string:"http://yd.local:8001/api/v1")!
            case .development:
                return URL(string:"https://dev.api.lylo.tv/api/v1")!
            case .alternative:
                return URL(string: "https://demo.bartlebys.org/www/api/v1")!
            case .production:
                return URL(string:"https://api.lylo.tv/api/v1")!
            }
        }
    }

    public static let TIME_OUT_DURATION = 10.0

    public static let LONG_TIME_OUT_DURATION = 360.0


    public static let ENABLE_TEST_OBSERVATION=true
}
