//
//  PdSSync.h
//  PdSSync
//
//  Created by Benoit Pereira da Silva on 15/02/2014.
//

// VERSION 1.0 Of the ObjC & PHP version


typedef NS_ENUM (NSUInteger,
                  BsyncCommand) {
    BCreate   = 0 , // W destination and source
    BUpdate   = 1 , // W destination and source
    BMove     = 2 , // R source W destination
    BCopy     = 3 , // R source W destination
    BDelete   = 4   // W source
} ;


typedef NS_ENUM(NSUInteger,
                BsyncCMDParamRank) {
    BCommand     = 0,
    BDestination = 1,
    BSource      = 2
} ;

typedef NS_ENUM (NSUInteger,
                 BsyncMode) {
    SourceIsLocalDestinationIsDistant   = 0 ,
    SourceIsDistantDestinationIsLocal   = 1 ,
    SourceIsLocalDestinationIsLocal     = 2 ,
    SourceIsDistantDestinationIsDistant = 3 // currently not supported 
};

#define kBsyncModeStrings @[\
                                @("SourceIsLocalDestinationIsDistant"),\
                                @("SourceIsDistantDestinationIsLocal"),\
                                @("SourceIsLocalDestinationIsLocal"),\
                                @("SourceIsDistantDestinationIsDistant")\
                            ]

// The global hash map name
#define kBsyncHashMashMapFileName @("hashmap")

// The extension for a single file hash
#define kBsyncHashFileExtension @("hash")

// The metadata folder
#define kBsyncMetadataFolder @(".bsync")

// A prefix used to identify easyly a prefixed file.
#define kBsyncPrefixSignature @(".bsync")

// A prefix used to identify easyly hashmapviews.
#define kBsyncHashmapViewPrefixSignature @(".hashMapView")

#define kBsyncMinHashmapViewNameLength 20

#define kTimeOutInterval 30 // Seconds

#import "PdSFileManager.h"
#import "HashMap.h"
#import "DeltaPathMap.h"
#import "PdSCommandInterpreter.h"
#import "PdSLocalAnalyzer.h"
#import "PdSSyncContext.h"
#import "PdSSyncAdmin.h"

// PdSCommons 
#import "NSData+CRC.h"