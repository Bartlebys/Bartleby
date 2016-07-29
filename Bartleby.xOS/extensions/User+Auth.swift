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
    public var registryUID:String{
        get{
            return self.document?.UID ?? "User_Extension_NO_UID_defined"
        }
    }

    public func login(withPassword password: String,
        sucessHandler success:()->(),
        failureHandler failure:(context: JHTTPResponse)->()) {
        LoginUser.execute(self, withPassword: password, sucessHandler:success, failureHandler:failure)

    }

    public func logout(sucessHandler success:()->(),
            failureHandler failure:(context: JHTTPResponse)->()) {
        LogoutUser.execute(self, sucessHandler: success, failureHandler: failure)
    }

}
