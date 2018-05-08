//
//  CompressionErrors.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 06/11/2016.
//
//

import Foundation

@available(iOS 9.0, OSX 10.11, watchOS 2.0, tvOS 9.0, *)
public enum CompressionError: Error {
    /**
     The error received when trying to compress/decompress empty data (when length equals zero).
     */
    case emptyData

    /**
     The error received when `compression_stream_init` failed. It also fails when trying to decompress `Data` compressed with different compression algorithm or uncompressed raw data.
     */
    case initError

    /**
     The error received when `compression_stream_process` failed.
     */
    case processError
}
