//
//  TestsConfiguration.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 29/12/2015.
//  Copyright © 2015 Benoit Pereira da silva. All rights reserved.
//

import Alamofire
import BartlebyKit


// A shared configuration Model
open class PlaygroundsConfiguration: BartlebyConfiguration {


    // The cryptographic key used to encrypt/decrypt the data
    public static var KEY: String="UDJDJJDJJDJDJDJDJJDDJJDJDJJDJ-O9393972AA"

    public static var SHARED_SALT: String="xyx38-d890x-899h-123e-30x6-3234e"

    // To conform to crypto legal context
    public static var KEY_SIZE: KeySize = .s128bits


    //MARK: - URLS

    static let trackAllApiCalls=true

    public static var API_BASE_URL=__BASE_URL

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

    // Should the registries metadata be crypted on export (should be true)!
    public static var CRYPTED_REGISTRIES_METADATA_EXPORT: Bool = true

    // Should we save the password by Default ?
    public static var SAVE_PASSWORD_DEFAULT_VALUE: Bool=false

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
