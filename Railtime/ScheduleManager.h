//
//  DataManager.h
//  Railtime
//
//  Created by David Steele on 8/8/12.
//  Copyright (c) 2012 Steeleforge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrainData.h"
#import "SystemManager.h"

@interface ScheduleManager : NSObject

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, weak) NSURLConnection *conn;
@property (nonatomic, strong) NSMutableArray *trains;
@property (nonatomic, strong) SystemManager *systemManager;

-(id)init;
-(void)refresh;
-(TrainData *)popNextTrain;
-(TrainData *)peekNextTrain;

@end
