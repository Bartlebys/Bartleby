//
//  CompressionAlgorithms.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 06/11/2016.
//
//

import Foundation

/**
 Compression algorithm
 - `.lz4`: Fast compression
 - `.zlib`: Balances between speed and compression
 - `.lzma`: High compression
 - `.lzfse`: Apple-specific high performance compression
 */
@available(iOS 9.0, OSX 10.11, watchOS 2.0, tvOS 9.0, *)
public enum CompressionAlgorithm {
    /**
     LZ4 is an extremely high-performance compressor.
     */
    case lz4

    /**
     ZLIB encoder at level 5 only. This compression level provides a good balance between compression speed and compression ratio. The ZLIB decoder supports decoding data compressed with any compression level.
     */
    case zlib

    /**
     LZMA encoder at level 6 only. This is the default compression level for open source LZMA, and provides excellent compression. The LZMA decoder supports decoding data compressed with any compression level.
     */
    case lzma

    /**
     Apple’s proprietary compression algorithm. LZFSE is a new algorithm, matching the compression ratio of ZLIB level 5, but with much higher energy efficiency and speed (between 2x and 3x) for both encode and decode operations.

     LZFSE is only present in iOS and OS X, so it can’t be used when the compressed payload has to be shared to other platforms (Linux, Windows). In all other cases, LZFSE is recommended as a replacement for ZLIB.
     */
    case lzfse
}
