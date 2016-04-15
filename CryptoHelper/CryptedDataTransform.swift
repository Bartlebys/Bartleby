//
//  CryptedDataTransform.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 05/01/2016.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.


import Foundation

#if !USE_EMBEDDED_MODULES
    import ObjectMapper
#endif

@objc public class CryptedDataTransform:NSObject,TransformType{
    
    public typealias Object = NSData
    public typealias JSON = String
    
    
    public func transformFromJSON(value: AnyObject?) -> Object?{
        if let s=value as? String{
            do{
                if let data=s.dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion:false){
                    return try Bartleby.cryptoDelegate.decryptData(data)
                }
                
            }catch{
                // SILENT CATCH
            }
        }
        return nil
    }
    
    public func transformToJSON(value: Object?) -> JSON?{
        if let d=value as NSData? {
            do{
                let d = try Bartleby.cryptoDelegate.encryptData(d)
                return String(data: d,encoding:NSUTF8StringEncoding)
            }catch{
                // SILENT CATCH
            }
        }
        return nil
    }
}
