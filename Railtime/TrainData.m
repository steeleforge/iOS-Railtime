//
//  TrainData.m
//  Railtime
//
//  Created by David Steele on 8/9/12.
//  Copyright (c) 2012 Steeleforge. All rights reserved.
//

#import "TrainData.h"
#import "Constants.h"


@interface TrainData ()

@end

@implementation TrainData

@synthesize train = _train;
@synthesize scheduled = _scheduled;
@synthesize estimated = _estimated;

-(id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.train = [dict objectForKey:JSON_TRAIN];
        NSNumber *sch = [dict objectForKey:JSON_SCHEDULED];
        NSNumber *est = [dict objectForKey:JSON_ESTIMATED];
        self.scheduled = [NSDate dateWithTimeIntervalSince1970:[sch doubleValue]/1000];
        self.estimated = [NSDate dateWithTimeIntervalSince1970:[est doubleValue]/1000];
        sch = nil;
        est = nil;
    }
    return self;
}

@end
