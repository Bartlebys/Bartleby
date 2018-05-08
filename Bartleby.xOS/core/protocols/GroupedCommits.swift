//
//  GroupedCommits.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 20/07/2016.
//
//

import Foundation

public protocol GroupedCommits {
    /// Commits all the staged changes and planned deletions.
    func commitChanges()
}
