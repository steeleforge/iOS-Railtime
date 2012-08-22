//
//  DataManager.m
//  Railtime
//
//  Created by David Steele on 8/8/12.
//  Copyright (c) 2012 Steeleforge. All rights reserved.
//

#import "ScheduleManager.h"
#import "Constants.h"


@interface ScheduleManager ()

@end


@implementation ScheduleManager

@synthesize data = _data;
@synthesize conn = _conn;
@synthesize trains = _trains;
@synthesize systemManager = _systemManager;

-(id)init {
    if (self = [super init]) {
        self.systemManager = [[SystemManager alloc] init];
        [self refresh];
    }
    return self;
}

-(void)refresh {
    self.data = [NSMutableData data];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:URL_SCHEDULE,[self.systemManager getUserLine],[self.systemManager getUserOrigin],[self.systemManager getUserDestination]]]];
    self.conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"requesting: %@",[NSString stringWithFormat:URL_SCHEDULE,[self.systemManager getUserLine],[self.systemManager getUserOrigin],[self.systemManager getUserDestination]]);
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // received response
    [self.data setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // received data
    [self.data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // connection failure
    NSLog(@"Connection failed: %@", error.description);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // connection finished
    NSLog(@"Received %d bytes",[self.data length]);
    
    NSError *err = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.data options:NSJSONReadingMutableLeaves error:&err];
    // extract specific value...;
    
    for (NSDictionary *result in res) {
        [self.trains addObject:[[TrainData alloc] initWithDictionary:result]];
    }
    
}
-(NSMutableArray *)trains {
    if (nil == _trains) _trains = [[NSMutableArray alloc] init];
    return _trains;
}

-(TrainData *)popNextTrain {
    TrainData *train = nil;
    if ([self.trains count] > 0) {
        train = [self.trains objectAtIndex:0];
        NSLog(@"?%@ %@ %@",train.train, train.estimated, train.estimated);
        if (train) [self.trains removeObjectAtIndex:0];
    }
    return train;
}
-(TrainData *)peekNextTrain {
    TrainData *train = nil;
    if ([self.trains count] > 0) {
        train = [self.trains objectAtIndex:0];
    }
    return train;
}

@end
