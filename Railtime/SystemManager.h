//
//  SystemManager.h
//  Railtime
//
//  Created by David Steele on 8/8/12.
//  Copyright (c) 2012 Steeleforge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemManager : NSObject

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, weak) NSURLConnection *conn;

-(void)updateCache;
+(BOOL)shouldRefreshCache;
+(void)updateUserLine:(NSString *)line origin:(NSString *)origin destination:(NSString *)destination;
-(NSArray *)getSystemLines;
-(NSArray *)getSystemStationsByLine:(NSString *)line;
-(NSString *)getUserLine;
-(NSString *)getUserOrigin;
-(NSString *)getUserDestination;
@end
