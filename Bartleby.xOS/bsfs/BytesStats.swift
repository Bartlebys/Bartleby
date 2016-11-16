//
//  BytesStats.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 16/11/2016.
//
//

import Foundation

public class BytesStats:CustomStringConvertible {

    var name:String

    var totalMB:UInt { return (_totalBytes / UInt(MB)) }

    var totalCompressedMB:UInt { return (_compressedBytes / UInt(MB)) }

    var elasped:Double { return (CFAbsoluteTimeGetCurrent() - _startTime) }

    var processingRateMBPerSeconds:UInt { return (UInt(Double(totalMB)/elasped)) }

    var compressionPercent:Int { return Int( _compressedBytes * 100 / _totalBytes ) }

    fileprivate var _totalBytes:UInt=0

    fileprivate var _compressedBytes:UInt=0

    fileprivate var _startTime:CFAbsoluteTime

    /// Initializer
    ///
    /// - Parameter name: the name of the bunch of stats
    init(name:String){
        self.name=name
        self._startTime=CFAbsoluteTimeGetCurrent()
    }

    /// Consign a progression
    ///
    /// - Parameter numberOfBytes: the number of processed bytes
    func consign(numberOfBytes:UInt,compressedBytes:UInt){
        self._totalBytes += numberOfBytes
        self._compressedBytes += compressedBytes
    }

    // MARK: CustomStringConvertible
    public var description:String { return "\(self.name)\nTotal: \(self.totalMB) MB\nTotal Compressed: \(self.totalCompressedMB) MB\nDuration:\(self.elasped)seconds\nProcessing Rate: \(self.processingRateMBPerSeconds) MB/s\nCompression : \(self.compressionPercent)%" }

}
