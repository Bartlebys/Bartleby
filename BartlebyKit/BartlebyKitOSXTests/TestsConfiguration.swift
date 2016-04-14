//
//  TestsConfiguration.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 08/03/2016.
//
//

import Foundation

class TestsConfiguration{
    
    // The cryptographic key used to encrypt/decrypt the data
    static var KEY:String{
        get{
            return "UnitTestsSharedConfiguration-!-lkJ-O9393972AA"
        }
    }
    
    // This 32Bytes strin is used to validate the tokens consistency
    // Should be the same server and client side and should not be disclosed
    static let SHARED_SALT="xyx38-d890x-899h-123e-30x6-3234e"
    
    //MARK: - URLS
    
    static let useTestEnvironment=false
    
    static let trackAllApiCalls=true
    
    static var BASE_URL:NSURL {
        get{
            if useTestEnvironment {
                return NSURL(string:"http://yd.local/api/v1")!
            } else {
                return NSURL(string:"https://pereira-da-silva.com/clients/lylo/www/api/v1")!
                //return NSURL(string:"https://api.lylo.tv/www/api/v1")!
            }
        }
    }
}

