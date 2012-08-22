//
//  SystemManager.m
//  Railtime
//
//  Created by David Steele on 8/8/12.
//  Copyright (c) 2012 Steeleforge. All rights reserved.
//

#import "SystemManager.h"
#import "Constants.h"

@interface SystemManager ()

@property (strong,nonatomic) NSDictionary *system;

-(void)processRefresh:(NSDictionary *)payload;

@end


@implementation SystemManager

@synthesize data = _data;
@synthesize conn = _conn;

+(BOOL)shouldRefreshCache {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *system = [prefs objectForKey:CACHE_SYSTEM];
    // no system cache
    if (nil == system) return YES;
    NSDate *lastUpdate = [prefs objectForKey:CACHE_TIMESTAMP];
    // no previous update timestamp
    if (nil == lastUpdate) return YES;
    // check for staleness
    // defined arbitrarily as 5 days, lines/stations don't change frequently
    NSDate *now = [[NSDate alloc] init];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *diff = [cal components:(NSDayCalendarUnit) fromDate:lastUpdate toDate:now options:0];
    NSLog(@"last update: %@ -- diff: %d",lastUpdate,diff.day);
    if (diff.day >= 5) return YES;
    return NO;
}

+(void)updateUserLine:(NSString *)line origin:(NSString *)origin destination:(NSString *)destination {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:line forKey:PREFERENCE_LINE];
    [prefs setObject:origin forKey:PREFERENCE_ORIGIN];
    [prefs setObject:destination forKey:PREFERENCE_DESTINATION];
    [prefs synchronize];    
}

-(NSString *)getUserLine {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *line = [prefs stringForKey:PREFERENCE_LINE];
    if (nil == line) return DEFAULT_LINE;
    return line;
}

-(NSString *)getUserOrigin {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *origin = [prefs stringForKey:PREFERENCE_ORIGIN];
    if (nil == origin) return DEFAULT_ORIGIN;
    return origin;
    
}

-(NSString *)getUserDestination {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *dest = [prefs stringForKey:PREFERENCE_DESTINATION];
    if (nil == dest) return DEFAULT_DESTINATION;
    return dest;
}

-(void)updateCache {
    self.data = [NSMutableData data];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL_LINES_STATIONS]];
    self.conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(id)init {
    if (self = [super init]) {
        if ([SystemManager shouldRefreshCache]) [self updateCache];
    }
    return self;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // received response
    [self.data setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // received data
    [self.data appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // connection failure
    NSLog(@"Connection failed: %@", error.description);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // connection finished
    NSLog(@"Received %d bytes",[self.data length]);
    
    NSError *err = nil;
    NSDictionary *linesStations = [NSJSONSerialization JSONObjectWithData:self.data options:NSJSONReadingMutableLeaves error:&err];
    [self processRefresh:linesStations];
}

-(void)processRefresh:(NSDictionary *)payload {
    if (nil != payload) {
        NSLog(@"processing refresh payload %@",payload);
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:payload forKey:CACHE_SYSTEM];
        [prefs setObject:[[NSDate alloc]init] forKey:CACHE_TIMESTAMP];
        [prefs synchronize];
    }
}



-(NSArray *)getSystemLines {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *system = [prefs objectForKey:CACHE_SYSTEM];
    if (nil == system) return [NSArray array];
    return [system keysSortedByValueUsingComparator:^(id o1, id o2) {
        if (o1 > o2)
            return (NSComparisonResult)NSOrderedDescending;
        if (o1 > o2)
            return (NSComparisonResult)NSOrderedAscending;
        return (NSComparisonResult)NSOrderedSame;
    }];
}

-(NSArray *)getSystemStationsByLine:(NSString *)line {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *system = [prefs objectForKey:CACHE_SYSTEM];
    if (nil == system) return [NSArray array];
    return [system objectForKey:line];
}


@end
