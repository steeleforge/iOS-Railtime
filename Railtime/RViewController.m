//
//  RViewController.m
//  Railtime
//
//  Created by David Steele on 8/8/12.
//  Copyright (c) 2012 Steeleforge. All rights reserved.
//

#import "Constants.h"
#import "RViewController.h"
#import "ScheduleManager.h"
#import "TrainData.h"

@interface RViewController ()

@property (strong, nonatomic) ScheduleManager *scheduleManager;
@property (strong, nonatomic) SystemManager *systemManager;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) TrainData *upcoming;
@property (strong, nonatomic) NSString *selectedLine;
@property (strong, nonatomic) NSString *selectedOrigin;
@property (strong, nonatomic) NSString *selectedDestination;
-(void)initUI;
-(void)updateFromTrain:(TrainData *)train;
-(void)updateFromPrefs;

@end

@implementation RViewController

@synthesize lblMinutes = _lblHours;
@synthesize lblSeconds = _lblSeconds;
@synthesize lblTrain = _lblTrain;
@synthesize viewClock = _viewClock;
@synthesize viewLine = _viewLine;
@synthesize viewStations = _viewStations;
@synthesize btnLine = _btnLine;
@synthesize btnStations = _btnStations;
@synthesize pickerLine = _linePicker;
@synthesize pickerStations = _stationPicker;
@synthesize scheduleManager = _scheduleManager;
@synthesize timer = _timer;
@synthesize upcoming = _upcoming;
@synthesize actionSheet = _actionSheet;
@synthesize selectedLine = _selectedLine;
@synthesize selectedOrigin = _selectedOrigin;
@synthesize selectedDestination = _selectedDestination;

-(void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    self.scheduleManager = [[ScheduleManager alloc] init];
    self.systemManager = self.scheduleManager.systemManager;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkTrain) userInfo:nil repeats:YES];
    [self.timer fire];
    [self updateFromPrefs];
}

-(void)viewDidUnload {
    [self setLblSeconds:nil];
    [self setLblMinutes:nil];
    [self setLblTrain:nil];
    [self setScheduleManager:nil];
    [self setTimer:nil];
    [self setUpcoming:nil];
    [self setViewClock:nil];
    [self setBtnLine:nil];
    [self setBtnStations:nil];
    [self setActionSheet:nil];
    [self setPickerLine:nil];
    [self setPickerStations:nil];
    [self setViewLine:nil];
    [self setViewStations:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)initUI {
    self.viewClock.alpha = 0.6;
    self.viewLine.alpha = 0.6;
    self.viewStations.alpha = 0.6;
}

-(void)checkTrain {
    //NSLog(@"checking train");
    NSDate *now = [[NSDate alloc] init];
    if (nil == self.upcoming) {
        self.upcoming = [self.scheduleManager popNextTrain];
       //NSLog(@"upcoming train %@",self.upcoming.train);
    }
    if (nil != self.upcoming) {
        switch([now compare:self.upcoming.estimated]) {
            case NSOrderedAscending:
                [self updateFromTrain:self.upcoming];
                break;
            case NSOrderedDescending:
                self.upcoming = [self.scheduleManager popNextTrain];
                break;
            case NSOrderedSame:
                self.upcoming = [self.scheduleManager popNextTrain];
                break;
            default:
                break;
        }
    }
}

-(void)updateFromTrain:(TrainData *)train {
    NSDate *now = [[NSDate alloc] init];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *diff = [cal components:(NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:now toDate:train.estimated options:0];
    //NSLog(@"diff [%@] > [%@] | [%@]",diff, now, train.estimated);
    NSString *diffMin = (diff.minute > 9)?[NSString stringWithFormat:@"%i", diff.minute]:[NSString stringWithFormat:@"0%i", diff.minute];
    NSString *diffSec = (diff.second > 9)?[NSString stringWithFormat:@"%i", diff.second]:[NSString stringWithFormat:@"0%i", diff.second];
    //NSLog(@"diffmin %@",diffMin);
    //NSLog(@"diffsec %@", diffSec);
    self.lblMinutes.text = diffMin;
    self.lblSeconds.text = diffSec;
    self.lblTrain.text = [NSString stringWithFormat:@"Train: %@", train.train];
}

-(void)updateFromPrefs {
    [self.btnLine setTitle:[self.systemManager getUserLine] forState:UIControlStateNormal];
    NSString *stations = [NSString stringWithFormat:@"%@ to %@",
                          [self.systemManager getUserOrigin],
                          [self.systemManager getUserDestination]];
    [self.btnStations setTitle:stations forState:UIControlStateNormal];
    
    self.selectedLine = [self.systemManager getUserLine];
    self.selectedOrigin = [self.systemManager getUserOrigin];
    self.selectedDestination = [self.systemManager getUserDestination];
}

- (IBAction)updateLine:(id)sender {
    // pop action sheet
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [self.actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    // generate picker
    self.pickerLine = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
    self.pickerLine.showsSelectionIndicator = YES;
    self.pickerLine.dataSource = self;
    self.pickerLine.delegate = self;
    
    NSInteger lineIndex = [[self.systemManager getSystemLines] indexOfObject:[self.systemManager getUserLine]];
    [self.pickerLine selectRow:lineIndex inComponent:0 animated:NO];
    
    // cancel & OK buttons
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    [toolbar sizeToFit];
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelUpdate:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(lineUpdated:)];
    [toolbar setItems:[NSArray arrayWithObjects:btnCancel,spacer,btnDone,nil] animated:YES];
    
    // add toolbar to actionsheet
    [self.actionSheet addSubview:toolbar];
    
    // add picker to action sheet
    [self.actionSheet addSubview:self.pickerLine];
    [self.actionSheet showInView:self.view];
    [self.actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
}

- (IBAction)updateStations:(id)sender {
    // pop action sheet
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [self.actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    // generate picker
    self.pickerStations = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
    self.pickerStations.showsSelectionIndicator = YES;
    self.pickerStations.dataSource = self;
    self.pickerStations.delegate = self;
    
    NSInteger originIndex = [[self.systemManager getSystemStationsByLine:self.selectedLine] indexOfObject:[self.systemManager getUserOrigin]];
    NSInteger destinationIndex = [[self.systemManager getSystemStationsByLine:self.selectedLine] indexOfObject:[self.systemManager getUserDestination]];
    [self.pickerStations selectRow:originIndex inComponent:0 animated:NO];
    [self.pickerStations selectRow:destinationIndex inComponent:1 animated:NO];
    
    // cancel & OK buttons
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    [toolbar sizeToFit];
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelUpdate:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(stationsUpdated:)];
    [toolbar setItems:[NSArray arrayWithObjects:btnCancel,spacer,btnDone,nil] animated:YES];
    
    // add toolbar to actionsheet
    [self.actionSheet addSubview:toolbar];
    
    // add picker to action sheet
    [self.actionSheet addSubview:self.pickerStations];
    [self.actionSheet showInView:self.view];
    [self.actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
}


- (void)dismissActionSheet:(id)sender {
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

-(void) cancelUpdate:(id)sender {
    [self dismissActionSheet:nil];
    [self updateFromPrefs];
}

- (void)lineUpdated:(id)sender {
    [self dismissActionSheet:nil];
    [self updateStations:nil];
}

- (void)stationsUpdated:(id)sender {
    if ([self.selectedOrigin isEqualToString:self.selectedDestination]) {
        [self cancelUpdate:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Please choose different origin and destination stations." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        [self dismissActionSheet:nil];
        self.upcoming = nil;
        [SystemManager updateUserLine:self.selectedLine origin:self.selectedOrigin destination:self.selectedDestination];
        [self updateFromPrefs];
        [self.scheduleManager refresh];
    }
}

#pragma mark -
#pragma mark UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if ([pickerView isEqual: self.pickerLine])  {
        return 1;
    }
       
    if ([pickerView isEqual: self.pickerStations]) {
        return 2;
    }
          
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView isEqual: self.pickerLine])  {
        return [self.scheduleManager.systemManager.getSystemLines count];
    }
    
    if ([pickerView isEqual: self.pickerStations]) {
        return [[self.scheduleManager.systemManager getSystemStationsByLine:[self.scheduleManager.systemManager getUserLine]] count];
    }
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([pickerView isEqual: self.pickerLine])  {
        return [self.scheduleManager.systemManager.getSystemLines objectAtIndex:row];
    }
    
    if ([pickerView isEqual: self.pickerStations]) {
        return [[self.scheduleManager.systemManager getSystemStationsByLine:self.selectedLine] objectAtIndex:row];
    }
    return nil;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([pickerView isEqual: self.pickerLine])  {
        self.selectedLine = [self.scheduleManager.systemManager.getSystemLines objectAtIndex:row];
    }
    
    if ([pickerView isEqual: self.pickerStations]) {
        switch(component) {
            case 0:
                self.selectedOrigin = [[self.scheduleManager.systemManager getSystemStationsByLine:self.selectedLine] objectAtIndex:row];
                break;
            case 1:
                self.selectedDestination = [[self.scheduleManager.systemManager getSystemStationsByLine:self.selectedLine] objectAtIndex:row];
                break;
        }
        
    }
 }
 

@end
