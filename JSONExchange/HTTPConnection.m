//
//  HTTPConnection.m
//  JSONExchange
//
//  Created by Chemersky on 4/4/17.
//  Copyright © 2017 Chemer. All rights reserved.
//

#import "HTTPConnection.h"
#import "HTTPServer.h"

@interface HTTPConnection ()
@property (weak) id<HTTPConnectionDelegate> delegate;

@property CFHTTPMessageRef message;
//@property BOOL isMessageComplete;
@property BOOL isHeaderComplete;
@end


@implementation HTTPConnection

- (id)initWithFileHandle:(NSFileHandle *)fileHandle delegate:(id<HTTPConnectionDelegate>)delegate {
    if( self = [super init] ) {
        self.fileHandle = fileHandle;
        self.delegate = delegate;
        self.message = NULL;
        self.isHeaderComplete = NO;


        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dataReceivedNotification:)
                                                     name:NSFileHandleReadCompletionNotification
                                                   object:self.fileHandle];

        
        [self.fileHandle readInBackgroundAndNotify];
   }
   return self;
}

#pragma mark - notifications handler

- (void)dataReceivedNotification:(NSNotification *)notification
{
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if ([data length] == 0) {
        [self.delegate closeConnection:self];
    } else {
        [self.fileHandle readInBackgroundAndNotify];
        self.message = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
        
        Boolean success = CFHTTPMessageAppendBytes(self.message, [data bytes], [data length]);
        if(success) {
            CFHTTPMessageCopyBody(self.message);
            
            if(CFHTTPMessageIsHeaderComplete(self.message)) {
                if (self.isHeaderComplete) {
                    [self.delegate dataDidReceive:(__bridge NSData *)CFHTTPMessageCopySerializedMessage(self.message)];
                }
            
                self.isHeaderComplete = YES;
                [self.delegate makeResponse:self];
                CFRelease(self.message);
                self.message = NULL;
            }
        } else {
            NSLog(@"Incomming message not a HTTP header, ignored.");
            [self.delegate closeConnection:self];
        }
    }
}

@end
