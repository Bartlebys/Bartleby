//
//  DeltaPathMap.h
//  PdSSync
//
//  Created by Benoit Pereira da Silva on 15/02/2014.
//
//

#import <Foundation/Foundation.h>

extern NSString* const createdPathsKey; // Each element is a relative path string
extern NSString* const deletedPathsKey; // Each element is a relative path string
extern NSString* const updatedPathsKey; // Each element is a relative path string
extern NSString* const copiedPathsKey;  // Each element is an array [0] destination [1] source.
extern NSString* const movedPathsKey;   // Each element is an array [0] destination [1] source.

@interface DeltaPathMap : NSObject

@property (strong,nonatomic)NSMutableArray*createdPaths; // New files or folders
@property (strong,nonatomic)NSMutableArray*deletedPaths; // Deleted files or folders
@property (strong,nonatomic)NSMutableArray*updatedPaths; // Files with binary changes
@property (strong,nonatomic)NSMutableArray*copiedPaths;  // Files that exists at another path should be copied ( Hash based )
@property (strong,nonatomic)NSMutableArray*movedPaths;   // Files that existed at another path ( Hash based )

/**
 *  Returns a new instance of a deltaHashMap;
 *
 *  @return a DeltaPathMap instance
 */
+(DeltaPathMap*)instance;

/**
 *  Returns a dictionary representation of the DeltaPathMap
 *
 *  @return the dictionary
 */
- (NSDictionary*)dictionaryRepresentation;

@end