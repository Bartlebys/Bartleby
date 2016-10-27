//
//  HTTPRequest+URLRequest.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 27/10/2016.
//
//

import Foundation

extension HTTPRequest{

    public convenience init(urlRequest:URLRequest){
        self.init()
    }

    public func urlRequest()->URLRequest?{
        return nil
    }

}
