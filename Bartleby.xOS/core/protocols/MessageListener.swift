//
//  MessageListener.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 06/03/2017.
//
//

import Foundation

public protocol MessageListener:Identifiable{

    func handle<T:StateMessage>(message:T)
    
}
