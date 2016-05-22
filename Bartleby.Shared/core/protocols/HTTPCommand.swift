//
//  HTTPCommand.swift
//  Bartleby
//
//  Created by Benoit Pereira da Silva on 15/12/2015.
//  Copyright © 2015 https://pereira-da-silva.com for Chaosmos SAS
//  All rights reserved you can ask for a license.



import Foundation


public protocol HTTPCommand {


    /**
     An http command implements a push method with success and failure contextual responses

     - parameter success: the successful HTTPRreponse
     - parameter failure: the unsucessful HTTPRreponse
     */
    func push(sucessHandler success:(context: HTTPResponse)->(), failureHandler failure:(context: HTTPResponse)->())

}
