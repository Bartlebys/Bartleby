//
//  TestsConfiguration.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/03/2016.
//
//

import Foundation
import BartlebyKit

public class TestsConfiguration:BartlebyConfiguration{
    
    // The cryptographic key used to encrypt/decrypt the data
    public static var KEY:String{
        get{
            return "UnitTestsSharedConfiguration-!-lkJ-O9393972AA"
        }
    }
    
    public static var SHARED_SALT:String{
        get{
            return "xyx38-d890x-899h-123e-30x6-3234e"
        }
    }
    
    //MARK: - URLS
    
    static let useTestEnvironment=false
    
    static let trackAllApiCalls=true
    
    public static var API_BASE_URL:NSURL {
        get{
            if useTestEnvironment {
                return NSURL(string:"http://yd.local/api/v1")!
            } else {
                return NSURL(string:"https://pereira-da-silva.com/clients/lylo/www/api/v1")!
                //return NSURL(string:"https://api.lylo.tv/www/api/v1")!
            }
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
    public static var PASSWORD_CHAR_CART:String {
        get {
            return "ABCDEFGH1234567890"
        }
    }

}

