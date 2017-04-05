//
//  HTTPRequest.h
//  JSONExchange
//
//  Created by Chemersky on 4/4/17.
//  Copyright © 2017 Chemer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPRequest : NSObject
- (id)initWithIP:(NSString *)ip port:(int)port body:(NSString *)body;
- (void)run;
@end
