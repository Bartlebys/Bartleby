//
//  TestsConfiguration.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 29/12/2015.
//  Copyright © 2015 Benoit Pereira da silva. All rights reserved.
//

import Foundation

#if !USE_EMBEDDED_MODULES
    import BartlebyKit
#endif


// A shared configuration Model
open class PlaygroundsConfiguration: BartlebyConfiguration {



    // The cryptographic key used to encrypt/decrypt the data
    open static var KEY: String="UnitTestsSharedConfiguration-!-lkJ-O9393972AA"

    open static var SHARED_SALT: String="xyx38-d890x-899h-123e-30x6-3234e"

    public static var KEY_SIZE:KeySize = .s128bits

    //MARK: - URLS

    static let trackAllApiCalls=true

    open static var API_BASE_URL=__BASE_URL

    // Bartleby Bprint
    open static var ENABLE_GLOG: Bool=true

    // Should Bprint entries be printed
    public static var PRINT_GLOG_ENTRIES: Bool=true

    // Use NoCrypto as CryptoDelegate (should be false)
    open static var DISABLE_DATA_CRYPTO: Bool=false

    //If set to true the created instances will be remove on maintenance Purge
    open static var EPHEMERAL_MODE=true

    //Should the app try to be online by default
    open static var ONLINE_BY_DEFAULT=true

    // Consignation
    open static var API_CALL_TRACKING_IS_ENABLED: Bool=true
    open static var BPRINT_API_TRACKED_CALLS: Bool=true

    // Should the registries metadata be crypted on export (should be true)!
    open static var CRYPTED_REGISTRIES_METADATA_EXPORT: Bool = true

    // Should we save the password by Default ?
    open static var SAVE_PASSWORD_DEFAULT_VALUE: Bool=false

    // If set to JSON for example would be Indented
    open static var HUMAN_FORMATTED_SERIALIZATON_FORMAT: Bool=false

    // Supervision loop interval (1 second min )
    open static var SUPERVISION_LOOP_TIME_INTERVAL_IN_SECONDS: Double = 1

    // To guarantee the sequential Execution use 1
    open static var MAX_OPERATIONS_BUNCH_SIZE: Int = 10

    // The min password size
    open static var MIN_PASSWORD_SIZE: UInt=6

    // E.g : Default.DEFAULT_PASSWORD_CHAR_CART
    open static var PASSWORD_CHAR_CART: String="ABCDEFGH1234567890"

    // If set to true the keyed changes are stored in the BartlebyObject - When opening the Inspector this default value is remplaced by true
    public static var CHANGES_ARE_INSPECTABLES_BY_DEFAULT: Bool = false

    //MARK: - Variable base URL

    enum Environment {
        case local
        case development
        case alternative
        case production
    }

    static var currentEnvironment: Environment = .local

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

    open static let TIME_OUT_DURATION = 10.0

    open static let LONG_TIME_OUT_DURATION = 360.0
    
    
    open static let ENABLE_TEST_OBSERVATION=false
}
