//
//  JSON.swift
//  Bartleby macOS
//
//  Created by Benoit Pereira da silva on 04/08/2017.
//

import Foundation

// A bunch of preconfigured encoder and decoders
public struct JSON{

    public static var encoder:JSONEncoder{
        get{
            let encoder = JSONEncoder()
            if #available(iOS 10.0, OSX 10.12, *){
                encoder.dateEncodingStrategy = .iso8601
            } else {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                encoder.dateEncodingStrategy = .formatted(formatter)
            }
            return encoder
        }
    }

    public static var prettyEncoder:JSONEncoder{
        let encoder = JSON.encoder
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }


    public static var base64Encoder:JSONEncoder{
        let encoder = JSON.encoder
        encoder.dataEncodingStrategy = .base64
        return encoder
    }

    public static var decoder:JSONDecoder{
        get{
            let decoder = JSONDecoder()
            if #available(iOS 10.0, OSX 10.12, *) {
                decoder.dateDecodingStrategy = .iso8601
            } else {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                decoder.dateDecodingStrategy = .formatted(formatter)
            }
            return decoder
        }
    }


    public static var base64Decoder:JSONDecoder{
        let decoder = JSON.decoder
        decoder.dataDecodingStrategy = .base64
        return decoder
    }

}