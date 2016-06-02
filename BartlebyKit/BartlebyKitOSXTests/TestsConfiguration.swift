//
//  TestsConfiguration.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/03/2016.
//
//

import Foundation
import BartlebyKit

public class TestsConfiguration: BartlebyConfiguration {

    // The cryptographic key used to encrypt/decrypt the data
    public static var KEY: String="UnitTestsSharedConfiguration-!-lkJ-O9393972AA"

    public static var SHARED_SALT: String="xyx38-d890x-899h-123e-30x6-3234e"

    //MARK: - URLS


    static let trackAllApiCalls=true

    public static var API_BASE_URL=__BASE_URL

    // Bartleby Bprint
    public static var ENABLE_BPRINT: Bool=true

    // CryptoDelegate should normally be set to false
    public static var DISABLE_DATA_CRYPTO: Bool { return true }

    // Consignation
    public static var API_CALL_TRACKING_IS_ENABLED: Bool=true
    public static var BPRINT_API_TRACKED_CALLS: Bool=true


    // Should we save the password by Default ?
    public static var SAVE_PASSWORD_DEFAULT_VALUE: Bool=false

    // If set to JSON for example would be Indented
    public static var HUMAN_FORMATTED_SERIALIZATON_FORMAT: Bool=false

    public static var DELAY_BETWEEN_OPERATIONS_IN_SECONDS: Double=Double(1/100)

    // The min password size
    public static var MIN_PASSWORD_SIZE: UInt=6

    // E.g : Default.DEFAULT_PASSWORD_CHAR_CART
    public static var PASSWORD_CHAR_CART: String="ABCDEFGH1234567890"


    //MARK: - Variable base URL


    enum Environment {
        case Local
        case Development
        case Alternative
        case Production
    }

    static var currentEnvironment: Environment = .Local

    static private var __BASE_URL: NSURL {
        get {
            switch currentEnvironment {
            case .Local:
                return NSURL(string:"http://yd.local/api/v1")!
            case .Development:
                return NSURL(string:"https://dev.api.lylo.tv/api/v1")!
            case .Alternative:
                return NSURL(string: "https://pereira-da-silva.com/clients/lylo/www/api/v1")!
            case .Production:
                return NSURL(string:"https://api.lylo.tv/api/v1")!
            }
        }
    }


    public static let TIME_OUT_DURATION = 5.0
    public static let LONG_TIME_OUT_DURATION = 1000.0

    public static let ASSET_PATH = Bartleby.getSearchPath(.DesktopDirectory)! + "BartlebyKitTests/"
}
