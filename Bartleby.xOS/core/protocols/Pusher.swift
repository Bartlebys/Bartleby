//
//  Pusher.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 15/12/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.

import Foundation

public protocol Pusher {
    /**
     An http command implements a push method with success and failure contextual responses

     - parameter success: the successful HTTPContext
     - parameter failure: the unsucessful HTTPContext
     */
    func push(sucessHandler success: @escaping (_ context: HTTPContext) -> Void, failureHandler failure: @escaping (_ context: HTTPContext) -> Void)
}
