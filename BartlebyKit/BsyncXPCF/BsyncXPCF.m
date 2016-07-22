//
//  BsyncXPCF.m
//  BsyncXPCF
//
//  Created by Benoit Pereira da silva on 22/07/2016.
//
//

#import "BsyncXPCF.h"

@implementation BsyncXPCF

// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
- (void)upperCaseString:(NSString *)aString withReply:(void (^)(NSString *))reply {
    NSString *response = [aString uppercaseString];
    reply(response);
}

@end
