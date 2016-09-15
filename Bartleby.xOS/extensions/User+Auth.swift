//
//  User+Auth.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 01/04/2016.
//
//

import Foundation

extension User {

    /// Returns the document UID
    open var registryUID:String{
        get{
            return self.document?.UID ?? "User_Extension_NO_UID_defined"
        }
    }

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
        let encrypted:String = (try? Bartleby.cryptoDelegate.encryptString(self.password)) ?? self.password
        return encrypted
    }


    open func login(withPassword password: String,
        sucessHandler success:@escaping()->(),
        failureHandler failure:@escaping(_ context: JHTTPResponse)->()) {
        LoginUser.execute(self, withPassword: password, sucessHandler:success, failureHandler:failure)
    }

    open func logout(sucessHandler success:@escaping()->(),
            failureHandler failure:@escaping(_ context: JHTTPResponse)->()) {
        LogoutUser.execute(self, sucessHandler: success, failureHandler: failure)
    }

}
