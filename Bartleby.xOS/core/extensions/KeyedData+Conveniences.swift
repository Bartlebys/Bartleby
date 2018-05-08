//
//  ?.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 29/11/2016.
//
//

import Foundation

extension KeyedData {
    convenience init(key: String, data: Data) {
        self.init()
        self.key = key
        self.data = data
    }
}
