//
//  F53OSCTimeTag.m
//
//  Created by Sean Dougall on 1/17/11.
//
//  Copyright (c) 2011-2013 Figure 53 LLC, http://figure53.com
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

#import "F53OSCTimeTag.h"
#import "NSDate+F53OSCTimeTag.h"

@implementation F53OSCTimeTag

@synthesize seconds = _seconds;

@synthesize fraction = _fraction;

+ (F53OSCTimeTag *) timeTagWithDate:(NSDate *)date
{
    double fractionsPerSecond = (double)0xffffffff;
    F53OSCTimeTag *result = [F53OSCTimeTag new];
    double secondsSince1900 = [date timeIntervalSince1970] + 2208988800;
    result.seconds = ((UInt64)secondsSince1900) & 0xffffffff;
    result.fraction = (UInt32)( fmod( secondsSince1900, 1.0 ) * fractionsPerSecond );
    return [result autorelease];
}

+ (F53OSCTimeTag *) immediateTimeTag
{
    F53OSCTimeTag *result = [F53OSCTimeTag new];
    result.seconds = 0;
    result.fraction = 1;
    return [result autorelease];
}

- (NSData *) oscTimeTagData
{
    UInt32 seconds = OSSwapHostToBigInt32( _seconds );
    UInt32 fraction = OSSwapHostToBigInt32( _fraction );
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&seconds length:sizeof( UInt32 )];
    [data appendBytes:&fraction length:sizeof( UInt32 )];
    return [[data copy] autorelease];
}

+ (F53OSCTimeTag *) timeTagWithOSCTimeBytes:(char *)buf
{
    UInt32 seconds = *((UInt32 *)buf);
    buf += sizeof( UInt32 );
    UInt32 fraction = *((UInt32 *)buf);
    F53OSCTimeTag *result = [[[F53OSCTimeTag alloc] init] autorelease];
    result.seconds = OSSwapBigToHostInt32( seconds );
    result.fraction = OSSwapBigToHostInt32( fraction );
    return result;
}

@end
