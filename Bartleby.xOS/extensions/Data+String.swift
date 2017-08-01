//
//  Data+String.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 01/08/2017.
//

import Foundation

enum  DataEncodingError:Error {
    case stringEncodingHasFailed
}

extension Data{

    func optionalString(using:String.Encoding)->String?{
        return String(data: self, encoding: using)
    }

    func string(using:String.Encoding)throws->String{
        if let s = String(data: self, encoding: using){
            return s
        }
        throw DataEncodingError.stringEncodingHasFailed
    }

}
