//
//  HTTPConnection.h
//  JSONExchange
//
//  Created by Chemersky on 4/4/17.
//  Copyright © 2017 Chemer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTTPConnection;

@protocol HTTPConnectionDelegate <NSObject>
-(void)makeResponse:(HTTPConnection *)connection;
- (void)closeConnection:(HTTPConnection *)connection;
- (void)dataDidReceive:(NSData *)data;
@end


@interface HTTPConnection : NSObject

@property NSFileHandle *fileHandle;

- (id)initWithFileHandle:(NSFileHandle *)fileHandle delegate:(id<HTTPConnectionDelegate>)delegate;

@end
