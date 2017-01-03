//
//  User+Auth.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 01/04/2016.
//
//

import Foundation

extension User {


    /// Returns the commplete singIn URL
    open func signInURL(for document:BartlebyDocument)->URL?{
        let password=self.cryptoPassword
        if let encoded=password.data(using: Default.STRING_ENCODING)?.base64EncodedString(){
            let signin=document.baseURL.absoluteString.replacingOccurrences(of: "/api/v1", with: "")+"/signIn?spaceUID=\(document.spaceUID)&userUID=\(self.UID)&password=\(encoded)"
            return URL(string: signin)
        }

        return nil
    }


    /// Returns an encrypted hashed version of the password
    open var cryptoPassword:String{
        if let p=self.password{
            do{
                let encrypted=try Bartleby.cryptoDelegate.encryptString(p,useKey:Bartleby.configuration.KEY)
                return encrypted
            }catch{
                return  "CRYPTO_ERROR"
            }
        }
        return Default.NO_STRING_ERROR
    }


    open func login(sucessHandler success:@escaping()->(),
                    failureHandler failure:@escaping(_ context: HTTPContext)->()) {
        LoginUser.execute(self, sucessHandler:success, failureHandler:failure)
    }

    open func logout(sucessHandler success:@escaping()->(),
                     failureHandler failure:@escaping(_ context: HTTPContext)->()) {
        LogoutUser.execute(self, sucessHandler: success, failureHandler: failure)
    }
    
}
