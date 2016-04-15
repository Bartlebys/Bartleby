//
//  TestConfiguration.swift
//  bsync
//
//  Created by Benoit Pereira da silva on 29/12/2015.
//  Copyright © 2015 Benoit Pereira da silva. All rights reserved.
//

import Foundation

// A shared configuration Model 
struct TestConfiguration {
    static let localSyncApiUrl=NSURL(string:"http://yd.local/api/v1/BartlebySync/")!
    static let distantTestTreeUrl=localSyncApiUrl.URLByAppendingPathComponent("tree/testTree")
    static let creativeKey="default-creative-key"
}