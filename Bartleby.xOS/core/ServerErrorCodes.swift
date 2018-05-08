//
//  ServerErrorCodes.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 26/10/2016.
//
//

import Foundation

// Those code are critical  server side error codes 
// that need to be handled by the client 
// Those code are not HTTP status codes but encoded semantics.
public enum ServerErrorCodes : Int{

    case semaphores_are_not_available = 800;
    case semaphores_acquistion_failed = 801;

}
