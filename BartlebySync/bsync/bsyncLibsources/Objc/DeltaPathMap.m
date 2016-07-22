//
//  DeltaPathMap.m
//  PdSSync
//
//  Created by Benoit Pereira da Silva on 15/02/2014.
//
//

#import "DeltaPathMap.h"

NSString* const createdPathsKey=@"createdPaths";
NSString* const deletedPathsKey=@"deletedPaths";
NSString* const updatedPathsKey=@"updatedPaths";
NSString* const copiedPathsKey=@"copiedPaths";
NSString* const movedPathsKey=@"movedPaths";

@implementation DeltaPathMap

/**
 *  Returns a new instance of a deltaHashMap;
 *
 *  @return a deltaHashMap instance
 */
+(DeltaPathMap*)instance{
    DeltaPathMap*instance=[[DeltaPathMap alloc]init];
    instance.createdPaths=[NSMutableArray array];
    instance.updatedPaths=[NSMutableArray array];
    instance.deletedPaths=[NSMutableArray array];
    instance.copiedPaths=[NSMutableArray array];
    instance.movedPaths=[NSMutableArray array];
    return instance;
}


/**
 *  Returns a dictionary representation of the DeltaPathMap
 *
 *  @return the dictionary
 */
- (NSDictionary*)dictionaryRepresentation{
    return @{
             createdPathsKey:_createdPaths,
             deletedPathsKey:_deletedPaths,
             updatedPathsKey:_updatedPaths,
             copiedPathsKey:_copiedPaths,
             movedPathsKey:_movedPaths
            };
}

@end