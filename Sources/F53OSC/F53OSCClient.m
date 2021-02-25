//
//  F53OSCClient.m
//
//  Created by Siobhán Dougall on 1/20/11.
//
//  Copyright (c) 2011-2020 Figure 53 LLC, https://figure53.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "F53OSCClient.h"

#import "F53OSCParser.h"

//#define  F53_OSC_CLIENT_DEBUG 1


NS_ASSUME_NONNULL_BEGIN

@interface F53OSCClient ()

@property (strong, nullable)    F53OSCSocket *socket;
@property (strong, nullable)    NSMutableData *readData;
@property (strong, nullable)    NSMutableDictionary *readState;

- (void) destroySocket;
- (void) createSocket;

@end

@implementation F53OSCClient

+ (BOOL) supportsSecureCoding
{
    return YES;
}

- (instancetype) init
{
    self = [super init];
    if ( self )
    {
        _socketDelegateQueue = dispatch_get_main_queue();
        self.delegate = nil;
        self.interface = nil;
        self.host = @"localhost";
        self.port = 53000;         // QLab is 53000, Stagetracker is 57115.
        self.IPv6Enabled = NO;
        self.useTcp = NO;
	    self.useSLP = YES;
        self.userData = nil;
        self.socket = nil;
        self.readData = [NSMutableData data];
        self.readState = [NSMutableDictionary dictionary];
	  	self.queue = dispatch_get_main_queue();
    }
    return self;
}

- (void) dealloc
{
    _delegate = nil;
    _interface = nil;
    _host = nil;
    _userData = nil;
    
    [self destroySocket];
    _readData = nil;
    _readState = nil;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.interface forKey:@"interface"];
    [coder encodeObject:self.host forKey:@"host"];
    [coder encodeObject:[NSNumber numberWithUnsignedShort:self.port] forKey:@"port"];
    [coder encodeObject:[NSNumber numberWithBool:self.isIPv6Enabled] forKey:@"IPv6Enabled"];
    [coder encodeObject:[NSNumber numberWithBool:self.useTcp] forKey:@"useTcp"];
    [coder encodeObject:[NSNumber numberWithBool:self.useSLP] forKey:@"useSLP"];
    [coder encodeObject:self.userData forKey:@"userData"];
}

- (nullable instancetype) initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if ( self )
    {
        _socketDelegateQueue = dispatch_get_main_queue();
        self.delegate = nil;
<<<<<<< HEAD:F53OSCClient.m
        self.interface = [coder decodeObjectForKey:@"interface"];
        self.host = [coder decodeObjectForKey:@"host"];
        self.port = [[coder decodeObjectForKey:@"port"] unsignedShortValue];
        self.useTcp = [[coder decodeObjectForKey:@"useTcp"] boolValue];
	    self.useSLP = [[coder decodeObjectForKey:@"useSLP"] boolValue];
        self.userData = [coder decodeObjectForKey:@"userData"];
=======
        self.interface = [coder decodeObjectOfClass:[NSString class] forKey:@"interface"];
        self.host = [coder decodeObjectOfClass:[NSString class] forKey:@"host"];
        self.port = [[coder decodeObjectOfClass:[NSNumber class] forKey:@"port"] unsignedShortValue];
        self.IPv6Enabled = [[coder decodeObjectOfClass:[NSNumber class] forKey:@"IPv6Enabled"] boolValue];
        self.useTcp = [[coder decodeObjectOfClass:[NSNumber class] forKey:@"useTcp"] boolValue];
        self.userData = [coder decodeObjectOfClass:[NSObject class] forKey:@"userData"];
>>>>>>> 96ced2fde624a1e637dc74ba34ef19e7a40d0b75:Sources/F53OSC/F53OSCClient.m
        self.socket = nil;
        self.readData = [NSMutableData data];
        self.readState = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"<F53OSCClient %@:%u>", self.host, self.port ];
}

- (void) setSocketDelegateQueue:(nullable dispatch_queue_t)queue
{
    BOOL recreateSocket = ( self.socket != nil );
    if ( recreateSocket )
        [self destroySocket];
    
    if ( !queue )
        queue = dispatch_get_main_queue();
    
    @synchronized( self )
    {
        _socketDelegateQueue = queue;
    }
    
    if ( recreateSocket )
        [self createSocket];
}

- (void) destroySocket
{
    [self.readState removeObjectForKey:@"socket"];
    
    [self.socket disconnect];
    if ( self.useTcp )
        [self.socket.tcpSocket synchronouslySetDelegate:nil delegateQueue:nil];
    else
        [self.socket.udpSocket synchronouslySetDelegate:nil delegateQueue:nil];
    _socket = nil;
}

- (void) createSocket
{
    if ( self.useTcp )
    {
<<<<<<< HEAD:F53OSCClient.m
        GCDAsyncSocket *tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.queue];
        self.socket = [F53OSCSocket socketWithTcpSocket:tcpSocket withSLP:self.useSLP];
=======
        GCDAsyncSocket *tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.socketDelegateQueue];
        self.socket = [F53OSCSocket socketWithTcpSocket:tcpSocket];
        self.socket.IPv6Enabled = self.isIPv6Enabled;
>>>>>>> 96ced2fde624a1e637dc74ba34ef19e7a40d0b75:Sources/F53OSC/F53OSCClient.m
        if ( self.socket )
            [self.readState setObject:self.socket forKey:@"socket"];
		
    }
    else // use UDP
    {
<<<<<<< HEAD:F53OSCClient.m
        GCDAsyncUdpSocket *udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:self.queue];
=======
        GCDAsyncUdpSocket *udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:self.socketDelegateQueue];
>>>>>>> 96ced2fde624a1e637dc74ba34ef19e7a40d0b75:Sources/F53OSC/F53OSCClient.m
        self.socket = [F53OSCSocket socketWithUdpSocket:udpSocket];
        self.socket.IPv6Enabled = self.isIPv6Enabled;
    }
    self.socket.interface = self.interface;
    self.socket.host = self.host;
    self.socket.port = self.port;
}

@synthesize interface = _interface;

- (nullable NSString *) interface
{
    // GCDAsyncSocket interprets "nil" as "allow the OS to decide what interface to use".
    // We additionally interpret "" as nil before passing the interface along.
    if ( [_interface isEqualToString:@""] )
        return nil;
    
    return _interface;
}

- (void) setInterface:(nullable NSString *)interface
{
    if ( [interface isEqualToString:@""] )
        interface = nil;
    
    _interface = [interface copy];
    self.socket.interface = _interface;
}

- (void) setHost:(nullable NSString *)host
{
    if ( [host isEqualToString:@""] )
        host = nil;
    
    _host = [host copy];
    self.socket.host = self.host;
}

- (void) setPort:(UInt16)port
{
    _port = port;
    self.socket.port = _port;
}

- (void) setIPv6Enabled:(BOOL)IPv6Enabled
{
    _IPv6Enabled = IPv6Enabled;
    self.socket.IPv6Enabled = _IPv6Enabled;
}

- (void) setUseTcp:(BOOL)flag
{
    if ( _useTcp == flag )
        return;
    
    _useTcp = flag;
    
    [self destroySocket];
}

<<<<<<< HEAD:F53OSCClient.m
@synthesize useSLP;

- (void) setUseSLP:(BOOL)flag
{
  if ( useSLP == flag )
	return;
  
  useSLP = flag;
  
  [self destroySocket];
}
@synthesize userData;

- (void) setUserData:(id)newUserData
=======
- (void) setUserData:(nullable id)userData
>>>>>>> 96ced2fde624a1e637dc74ba34ef19e7a40d0b75:Sources/F53OSC/F53OSCClient.m
{
    if ( userData == [NSNull null] )
        userData = nil;
    
    _userData = userData;
}

- (NSDictionary *) state
{
    return @{
             @"interface": self.interface ? self.interface : @"",
             @"host": self.host ? self.host : @"",
             @"port": @( self.port ),
             @"useTcp": @( self.useTcp ),
			 @"useSLP": @( self.useSLP ),
             @"userData": ( self.userData ? self.userData : [NSNull null] )
             };
}

- (void) setState:(NSDictionary *)state
{
    self.interface = state[@"interface"];
    self.host = state[@"host"];
    self.port = [state[@"port"] unsignedIntValue];
    self.useTcp = [state[@"useTcp"] boolValue];
    self.useSLP = [state[@"useSLP"] boolValue];
    self.userData = state[@"userData"];
}

- (NSString *) title
{
    if ( self.isValid )
        return [NSString stringWithFormat:@"%@ : %u", self.host, self.port ];
    else
        return [NSString stringWithFormat:@"<invalid>" ];
}

- (BOOL) isValid
{
    if ( self.host && self.port )
        return YES;
    else
        return NO;
}

- (BOOL) isConnected
{
    return [self.socket isConnected];
}

- (BOOL) connect
{
    if ( !self.socket )
        [self createSocket];
    if ( self.socket )
        return [self.socket connect];
    return NO;
}

- (void) disconnect
{
    [self.socket disconnect];
    [self.readData setData:[NSData data]];
    [self.readState setObject:@NO forKey:@"dangling_ESC"];
}

- (void) sendPacket:(F53OSCPacket *)packet
{
    if ( !self.socket )
        [self connect];
    
#if F53_OSC_CLIENT_DEBUG
    NSLog( @"%@ sending packet: %@", self, packet );
#endif
    
    if ( self.socket )
    {
        if ( self.socket.isTcpSocket )
            [self.socket.tcpSocket readDataWithTimeout:-1 tag:0]; // Listen for a potential response.
        [self.socket sendPacket:packet];
    }
    else
    {
        NSLog( @"Error: F53OSCClient could not send data; no socket available." );
    }
}

#pragma mark - GCDAsyncSocketDelegate

- (nullable dispatch_queue_t) newSocketQueueForConnectionFromAddress:(NSData *)address onSocket:(GCDAsyncSocket *)sock
{
    return self.socketDelegateQueue;
}

- (void) socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    // Client objects do not accept new incoming connections.
}

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
#if F53_OSC_CLIENT_DEBUG
    NSLog( @"client socket %p didConnectToHost %@:%u", sock, host, port );
#endif
    
    if ( [self.delegate respondsToSelector:@selector(clientDidConnect:)] )
    {
        dispatch_block_t block = ^{
            [self.delegate clientDidConnect:self];
        };
        
        if ( [NSThread isMainThread] )
            block();
        else
            dispatch_async( dispatch_get_main_queue(), block );
    }
}

//store the remnants of data which we are as yet unable to process (message split across packets
NSData *existingData = nil;

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
#if F53_OSC_CLIENT_DEBUG
    NSLog( @"client socket %p didReadData of length %lu. tag : %lu", sock, [data length], tag );
  NSLog(@" data is %@", data);
  
#endif

  if (self.useSLP) //OSC 1.1
	  [F53OSCParser translateSlipData:data toData:self.readData withState:self.readState destination:self.delegate];
	else //OSC 1.0 packet length headers
	{
	  
	  //if we have existing data start with that, otherwise start with a blank set of data
	  NSMutableData *mData;
	  if (existingData != nil)
	  {
		//NSLog(@"using existing data");
		mData = [NSMutableData dataWithData:existingData];
		[mData appendData:data];
	  } else
	  {
		//NSLog(@"no existing data");
	  	mData = [NSMutableData dataWithData:data];
	  }
	 
	  //check we have enough data to start (there has to be an Int32 at the start(
	  //we loop here so that if the packet has more than one message we catch them all
	  while ( [mData length] > sizeof( UInt32 ) )
	  {
		  NSUInteger length = [mData length];
		
		  const char *buffer = [mData bytes];
		//get a buffer of just the length from the start of the packer
		  NSData *lengthData = [mData subdataWithRange: NSMakeRange(0, sizeof( UInt32))];
		
		//and convert the length buffer into the actual length
		  const char *lengthBuffer = [lengthData bytes];
		  UInt32 dataSize = *((UInt32*)lengthBuffer);

		  dataSize = OSSwapBigToHostInt32( dataSize );
		
		
		//check we have at least as much data as we should have
		  if ( length - sizeof( UInt32 ) >= dataSize )
		  {
			//drop the length off the start of the buffer
		      buffer += sizeof( UInt32 );
			  length -= sizeof( UInt32 );
			
			  //and take this chunk of the data and put it in the new oscData buffer
			  NSData *oscData = [NSData dataWithBytes:buffer length:dataSize];
			
			  #if F53_OSC_CLIENT_DEBUG
				   NSLog( @"client socket %p dispatching oscData of length %lu, leaving buffer of length %lu.", sock, [oscData length], [data length] );
			  #endif
			
			  if (![F53OSCParser processOscDataWithSuccess:oscData forDestination:self.delegate replyToSocket:self.socket])
			  {
				//that failed, which suggests out initial size was incorrect
				
				//let's just remove the first byte and go around again until we get valid OSC - this is in case there was a rouge byte at the start giving a valid Int32 which shouldn't have been there!
				buffer += 1;
				length -= 1;
				
			  } else
			  {
				//otherwise, as that was good, remove the old data from the buffer
				buffer += dataSize;
				length -= dataSize;
			  }
			
			  //now update the mutableData object with our remaning data
			  if ( length )
			  {
				//NSLog(@"Have some remaining data!");
				mData = [NSMutableData dataWithBytes:buffer length:length];
			  }
			  else
			  {
				mData = [NSMutableData dataWithLength:0];
			  }
			
			
		  } else
		  {
			//NSLog(@"had some overrun data %lu %u", (unsigned long)length, (unsigned int)dataSize);
			// TODO: protect against them filling up the buffer with a huge amount of incoming data.
			break;
		  }
	  }
	  //if we have data left in our buffer then save it for next time!
	  if (mData.length > 0)
	  {
		//NSLog(@"existing data stored for next time");
		existingData = [NSData dataWithData:mData];
	  } else
	  {
		existingData = nil;
	  }
	}
    [sock readDataWithTimeout:-1 tag:tag];
}

- (void) socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
#if F53_OSC_CLIENT_DEBUG
    NSLog( @"client socket %p didReadPartialDataOfLength %lu. tag: %li", sock, partialLength, tag );
#endif
}

- (void) socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
#if F53_OSC_CLIENT_DEBUG
    NSLog( @"client socket %p didWriteDataWithTag %li", sock, tag );
#endif
}

- (void) socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
#if F53_OSC_CLIENT_DEBUG
    NSLog( @"server socket %p didWritePartialDataOfLength %lu. tag: %li", sock, partialLength, tag );
#endif
}

- (NSTimeInterval) socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    NSLog( @"Warning: F53OSCClient timed out when reading data." );
    return 0;
}

- (NSTimeInterval) socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    NSLog( @"Warning: F53OSCClient timed out when sending data." );
    return 0;
}

- (void) socketDidCloseReadStream:(GCDAsyncSocket *)sock
{
#if F53_OSC_CLIENT_DEBUG
    NSLog( @"client socket %p didCloseReadStream", sock );
#endif
    
    dispatch_block_t block = ^{
        [self.readData setData:[NSData data]];
        [self.readState setObject:@NO forKey:@"dangling_ESC"];
    };
    
    if ( [NSThread isMainThread] )
        block();
    else
        dispatch_async( dispatch_get_main_queue(), block );
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err
{
#if F53_OSC_CLIENT_DEBUG
    NSLog( @"client socket %p didDisconnect", sock );
#endif
    
    dispatch_block_t block = ^{
        [self.readData setData:[NSData data]];
        [self.readState setObject:@NO forKey:@"dangling_ESC"];
        
        if ( [self.delegate respondsToSelector:@selector(clientDidDisconnect:)] )
            [self.delegate clientDidDisconnect:self];
    };
    
    if ( [NSThread isMainThread] )
        block();
    else
        dispatch_async( dispatch_get_main_queue(), block );
}

- (void) socketDidSecure:(GCDAsyncSocket *)sock
{
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void) udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
}

- (void) udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(nullable NSError *)error
{
}

- (void) udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
#if F53_OSC_CLIENT_DEBUG
    NSLog( @"client socket %p didSendDataWithTag: %ld", sock, tag );
#endif
}

- (void) udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(nullable NSError *)error
{
#if F53_OSC_CLIENT_DEBUG
    NSLog( @"client socket %p didSendDataWithTag: %ld dueToError: %@", sock, tag, [error localizedDescription] );
#endif
}

- (void) udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(nullable id)filterContext
{
}

- (void) udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(nullable NSError *)error
{
}

@end

NS_ASSUME_NONNULL_END
