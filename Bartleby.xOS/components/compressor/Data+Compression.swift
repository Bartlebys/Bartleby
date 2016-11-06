//
//  Data+Compression.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 06/11/2016.
//  Adapted from : https://github.com/bleuground/LiViD/blob/59906df8c65ec9ee21fca15d037626d40dfaef17/LiViD/Data%2BCompression.swift
//

import Foundation
import Compression


@available(iOS 9.0, OSX 10.11, watchOS 2.0, tvOS 9.0, *)
extension Data {
    /**
     Returns a `Data` object created by compressing the receiver using the LZFSE algorithm.
     - returns: A `Data` object created by encoding the receiver's contents using the LZFSE algorithm.
     */
    public func compress() throws -> Data? {
        return try compress(algorithm: .lzfse, bufferSize: 4096)
    }

    /**
     Returns a `Data` object created by compressing the receiver using the given compression algorithm.
     - parameter algorithm: one of four compression algorithms to use during compression
     - returns: A `Data` object created by encoding the receiver's contents using the provided compression algorithm.
     */
    public func compress(algorithm compression: CompressionAlgorithm) throws -> Data? {
        return try compress(algorithm: compression, bufferSize: 4096)
    }

    /**
     Returns a Data object created by compressing the receiver using the given compression algorithm.
     - parameter algorithm: one of four compression algorithms to use during compression
     - parameter bufferSize: the size of buffer in bytes to use during compression
     - returns: A `Data` object created by encoding the receiver's contents using the provided compression algorithm.
     */
    public func compress(algorithm compression: CompressionAlgorithm, bufferSize: size_t) throws -> Data? {
        return try compress(compression, operation: .compression, bufferSize: bufferSize)
    }

    /**
     Returns a `Data` object by uncompressing the receiver using the LZFSE algorithm.
     - returns: A `Data` object created by decoding the receiver's contents using the LZFSE algorithm.
     */
    public func decompress() throws -> Data? {
        return try decompress(algorithm: .lzfse, bufferSize: 4096)
    }

    /**
     Returns a `Data` object by uncompressing the receiver using the given compression algorithm.
     - parameter algorithm: one of four compression algorithms to use during decompression
     - returns: A `Data` object created by decoding the receiver's contents using the provided compression algorithm.
     */
    public func decompress(algorithm compression: CompressionAlgorithm) throws -> Data? {
        return try decompress(algorithm: compression, bufferSize: 4096)
    }

    /**
     Returns a `Data` object by uncompressing the receiver using the given compression algorithm.
     - parameter algorithm: one of four compression algorithms to use during decompression
     - parameter bufferSize: the size of buffer in bytes to use during decompression
     - returns: A `Data` object created by decoding the receiver's contents using the provided compression algorithm.
     */
    public func decompress(algorithm compression: CompressionAlgorithm, bufferSize: size_t) throws -> Data? {
        return try compress(compression, operation: .decompression, bufferSize: bufferSize)
    }

    fileprivate enum Operation {
        case compression
        case decompression
    }

    fileprivate func compress(_ compression: CompressionAlgorithm, operation: Operation, bufferSize: size_t) throws -> Data? {
        // Throw an error when data to (de)compress is empty.
        guard count > 0 else { throw CompressionError.emptyData }

        // Variables
        var status: compression_status
        var op: compression_stream_operation
        var flags: Int32
        var algorithm: compression_algorithm

        // Output data
        let outputData = NSMutableData()

        switch compression {
        case .lz4:
            algorithm = COMPRESSION_LZ4
        case .zlib:
            algorithm = COMPRESSION_ZLIB
        case .lzma:
            algorithm = COMPRESSION_LZMA
        case .lzfse:
            algorithm = COMPRESSION_LZFSE
        }

        // Setup stream operation and flags depending on compress/decompress operation type
        switch operation {
        case .compression:
            op = COMPRESSION_STREAM_ENCODE
            flags = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
        case .decompression:
            op = COMPRESSION_STREAM_DECODE
            flags = 0
        }

        // Allocate memory for one object of type compression_stream
        let streamPointer = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
        defer {
            streamPointer.deallocate(capacity: 1)
        }

        // Stream and its buffer
        var stream = streamPointer.pointee
        let dstBufferPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            dstBufferPointer.deallocate(capacity: bufferSize)
        }

        // Create the compression_stream and throw an error if failed
        status = compression_stream_init(&stream, op, algorithm)
        guard status != COMPRESSION_STATUS_ERROR else {
            throw CompressionError.initError
        }
        defer {
            compression_stream_destroy(&stream)
        }

        // Stream setup after compression_stream_init
        withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
            stream.src_ptr = bytes
        }

        stream.src_size = count
        stream.dst_ptr = dstBufferPointer
        stream.dst_size = bufferSize

        repeat {
            status = compression_stream_process(&stream, flags)

            switch status {
            case COMPRESSION_STATUS_OK:
                if stream.dst_size == 0 {
                    outputData.append(dstBufferPointer, length: bufferSize)

                    stream.dst_ptr = dstBufferPointer
                    stream.dst_size = bufferSize
                }

            case COMPRESSION_STATUS_END:
                if stream.dst_ptr > dstBufferPointer {
                    outputData.append(dstBufferPointer, length: stream.dst_ptr - dstBufferPointer)
                }

            case COMPRESSION_STATUS_ERROR:
                throw CompressionError.processError
                
            default:
                break
            }
            
        } while status == COMPRESSION_STATUS_OK
        
        return outputData.copy() as? Data
    }
}

