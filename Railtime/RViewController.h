//
//  RViewController.h
//  Railtime
//
//  Created by David Steele on 8/8/12.
//  Copyright (c) 2012 Steeleforge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduleManager.h"

@interface RViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblMinutes;
@property (weak, nonatomic) IBOutlet UILabel *lblSeconds;
@property (weak, nonatomic) IBOutlet UILabel *lblTrain;
@property (weak, nonatomic) IBOutlet UIView *viewClock;
@property (weak, nonatomic) IBOutlet UIView *viewLine;
@property (weak, nonatomic) IBOutlet UIView *viewStations;
@property (weak, nonatomic) IBOutlet UIButton *btnLine;
@property (weak, nonatomic) IBOutlet UIButton *btnStations;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerLine;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerStations;
@property (strong, nonatomic) UIActionSheet *actionSheet;

-(void)checkTrain;
- (IBAction)updateLine:(id)sender;
- (IBAction)updateStations:(id)sender;

@end
