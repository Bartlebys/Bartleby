//
//  LogEntriesObserver.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 21/10/2016.
//
//

import Foundation

public protocol LogEntriesObserver {
    func receive(_ entry: LogEntry)
}
