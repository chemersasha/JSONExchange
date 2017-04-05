//
//  HTTPServer.m
//  JSONExchange
//
//  Created by Chemersky on 4/3/17.
//  Copyright © 2017 Chemer. All rights reserved.
//

#import "HTTPServer.h"
#import "HTTPConnection.h"

@interface HTTPServer () <HTTPConnectionDelegate>
@property int portNumber;
@property (weak) id<HTTPServerDelegate> delegate;

@property NSFileHandle *fileHandle;
@property NSMutableArray *connections;

@property NSDictionary *request;
@end


@implementation HTTPServer

- (id)initWithPortNumber:(int)port delegate:(id<HTTPServerDelegate>)delegate{
    if( self = [super init] ) {
        self.portNumber = port;
        self.connections = [[NSMutableArray alloc] init];
        self.delegate = delegate;
        
        self.socketPort = [[NSSocketPort alloc] initWithTCPPort:self.portNumber];
        if (self.socketPort) {
            int fd = [self.socketPort socket];
            self.fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];

            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(newConnection:)
                                                         name:NSFileHandleConnectionAcceptedNotification
                                                       object:nil];

            [self.fileHandle acceptConnectionInBackgroundAndNotify];
        }
    }
    return self;
}

- (void)stop {
    [self.fileHandle closeFile];
}

- (void)newConnection:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *errorNo = [userInfo objectForKey:@"NSFileHandleError"];
    if(errorNo) {
        NSLog(@"NSFileHandle Error: %@", errorNo);
        return;
    }
    
    NSFileHandle *remoteFileHandle = [userInfo objectForKey:NSFileHandleNotificationFileHandleItem];
    [self.fileHandle acceptConnectionInBackgroundAndNotify];

    if(remoteFileHandle) {
        HTTPConnection *connection = [[HTTPConnection alloc] initWithFileHandle:remoteFileHandle delegate:self];
        if(connection) {
            [self.connections addObject:connection];
        }
    }
}

#pragma mark - HTTPConnectionDelegate

- (void)closeConnection:(HTTPConnection *)connection {
    NSLog(@"close connection");
    [self.connections removeObject:connection];
}

-(void)makeResponse:(HTTPConnection *)connection {
    NSDictionary *headers = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    NSDictionary *response = @{@"status":@"OK"};
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:nil];
    
    [self replyConnection:connection statusCode:200 headers:headers body:jsonData];
}

- (void)replyConnection:(HTTPConnection *)connection statusCode:(int)code headers:(NSDictionary*)headers body:(NSData*)body
{
    CFHTTPMessageRef msg;
    msg = CFHTTPMessageCreateResponse(kCFAllocatorDefault, code, NULL, kCFHTTPVersion1_1);
    NSEnumerator *keys = [headers keyEnumerator];
    NSString *key;
    while( key = [keys nextObject] ) {
        id value = [headers objectForKey:key];
        if( ![value isKindOfClass:[NSString class]] ) value = [value description];
        if( ![key isKindOfClass:[NSString class]] ) key = [key description];
        CFHTTPMessageSetHeaderFieldValue(msg, (__bridge CFStringRef)key, (__bridge CFStringRef)value);
    }
    if( body ) {
        NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        CFHTTPMessageSetHeaderFieldValue(msg,
                                         (CFStringRef)@"Content-Length",
                                         (__bridge CFStringRef)length);
        CFHTTPMessageSetBody(msg, (__bridge CFDataRef)body);
    }
   
    CFDataRef msgData = CFHTTPMessageCopySerializedMessage(msg);
    @try {
        NSFileHandle *remoteFileHandle = [connection fileHandle];
        [remoteFileHandle writeData:(__bridge NSData *)msgData];
    }
    @catch (NSException *exception) {
        NSLog(@"Error while sending response (%@): %@\n", [self.request objectForKey:@"url"], [exception  reason]);
    }
   
    CFRelease(msgData);
    CFRelease(msg);
}

- (void)dataDidReceive:(NSData *)data {
    [self.delegate dataDidReceive:data];
}

@end
