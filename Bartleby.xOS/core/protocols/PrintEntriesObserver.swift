//
//  PrintEntriesObserver.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 17/10/2016.
//
//

import Foundation

public protocol PrintEntriesObserver{
    func receive(_ entry:PrintEntry);
}
