//
//  Constants.m
//  Railtime
//
//  Created by David Steele on 8/14/12.
//  Copyright (c) 2012 Steeleforge. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString *const URL_LINES_STATIONS = @"http://serene-plains-5631.herokuapp.com/railtime";
NSString *const URL_SCHEDULE = @"http://serene-plains-5631.herokuapp.com/railtime/%@/%@/%@";
NSString *const PREFERENCE_LINE = @"line";
NSString *const PREFERENCE_ORIGIN = @"origin";
NSString *const PREFERENCE_DESTINATION = @"destination";
NSString *const CACHE_SYSTEM = @"system";
NSString *const CACHE_TIMESTAMP = @"timestamp";
NSString *const JSON_TRAIN = @"train";
NSString *const JSON_SCHEDULED = @"scheduled";
NSString *const JSON_ESTIMATED = @"estimated";
NSString *const DEFAULT_LINE = @"UP-N";
NSString *const DEFAULT_ORIGIN = @"OTC";
NSString *const DEFAULT_DESTINATION = @"EVANSTON";

@end
