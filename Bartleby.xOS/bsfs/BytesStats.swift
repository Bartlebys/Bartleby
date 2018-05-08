//
//  BytesStats.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 16/11/2016.
//
//

import Foundation

public class BytesStats: CustomStringConvertible {
    var name: String

    var totalMB: UInt { return (_totalBytes / UInt(MB)) }

    var totalCompressedMB: UInt { return (_compressedBytes / UInt(MB)) }

    var elasped: Double { return (CFAbsoluteTimeGetCurrent() - _startTime) }

    var processingRateMBPerSeconds: UInt { return (UInt(Double(totalMB) / elasped)) }

    var compressionPercent: Int { return 100 - Int(_compressedBytes * 100 / _totalBytes) }

    fileprivate var _totalBytes: UInt = 0

    fileprivate var _compressedBytes: UInt = 0

    fileprivate var _startTime: CFAbsoluteTime

    /// Initializer
    ///
    /// - Parameter name: the name of the bunch of stats
    init(name: String) {
        self.name = name
        _startTime = CFAbsoluteTimeGetCurrent()
    }

    /// Consign a progression
    ///
    /// - Parameter numberOfBytes: the number of processed bytes
    func consign(numberOfBytes: UInt, compressedBytes: UInt) {
        _totalBytes += numberOfBytes
        _compressedBytes += compressedBytes
    }

    // MARK: CustomStringConvertible

    public var description: String { return "\(name)\nTotal: \(totalMB) MB\nTotal Compressed: \(totalCompressedMB) MB\nDuration:\(elasped)seconds\nProcessing Rate: \(processingRateMBPerSeconds) MB/s\nCompression : \(compressionPercent)%" }
}
