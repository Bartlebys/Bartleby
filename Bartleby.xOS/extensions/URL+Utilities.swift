//
//  String+Paths.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 14/11/2016.
//
//

import Foundation


extension URL{

    var isAnAlias:Bool{
        // Alias? https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/URL.swift#L417
        let resv:URLResourceValues? = try? self.resourceValues(forKeys: [URLResourceKey.isAliasFileKey])
        return resv?.isAliasFile ?? false
    }

    var isInMainBundle:Bool{
        return self.absoluteString.contains(Bundle.main.bundleURL.path)
    }

}
