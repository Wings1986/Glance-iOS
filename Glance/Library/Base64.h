//
//  Base64.h
//  Glance
//
//  Created by Avramov on 4/4/15.
//  Copyright (c) 2015 Conqueror. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Base64 : NSObject

+(NSString *)encode:(NSData *)plainText;

@end
