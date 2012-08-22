//
//  TrainData.h
//  Railtime
//
//  Created by David Steele on 8/9/12.
//  Copyright (c) 2012 Steeleforge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrainData : NSObject

@property (nonatomic,strong) NSString *train;
@property (nonatomic,strong) NSDate *scheduled;
@property (nonatomic,strong) NSDate *estimated;

-(id)initWithDictionary:(NSDictionary *)dict;

@end
