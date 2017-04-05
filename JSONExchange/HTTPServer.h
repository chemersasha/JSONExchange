//
//  HTTPServer.h
//  JSONExchange
//
//  Created by Chemersky on 4/3/17.
//  Copyright © 2017 Chemer. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HTTPServerDelegate <NSObject>
- (void)dataDidReceive:(NSData *)data;
@end

@interface HTTPServer : NSObject
@property NSSocketPort *socketPort;

- (id)initWithPortNumber:(int)port delegate:(id<HTTPServerDelegate>)delegate;
- (void)stop;

@end
