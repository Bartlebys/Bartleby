//
//  User+Auth.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 01/04/2016.
//
//

import Foundation

extension User : UserProtocol {

    public func login(withPassword password: String,
        sucessHandler success:()->(),
        failureHandler failure:(context: JHTTPResponse)->()) {
        LoginUser.execute(self, withPassword: password, sucessHandler:success, failureHandler:failure)

    }

    public func logout(sucessHandler success:()->(),
            failureHandler failure:(context: JHTTPResponse)->()) {
        LogoutUser.execute(fromDataSpace: self.spaceUID, sucessHandler: success, failureHandler: failure)

    }

}
