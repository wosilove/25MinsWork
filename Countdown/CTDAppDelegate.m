//
//  CTDAppDelegate.m
//  Countdown
//
//  Created by Chris Cieslak on 6/18/13.
//  Copyright (c) 2013 Stand Alone. All rights reserved.
//

#import "CTDAppDelegate.h"

NSString * const kShowTimerPanelString = @"Show Timer Panel";
NSString * const kHideTimerPanelString = @"Hide Timer Panel";
NSString * const kDoneString = @"Done!";


@implementation CTDAppDelegate

-(void)initUI
{
    self.Today.stringValue = [self.dateFormatter stringFromDate:[NSDate date]];
    [self ShowTheCountdownDays];
}


- (void)Hidefor2Mins:(NSTimer *)timer
{
    [self TapedSetGoal:nil];
    BreaktimeStart = [ NSDate date];
    [pauseTimer invalidate];
}

- (IBAction)TapedHideButton:(NSButton *)sender {
    [self SaveAndHiden:nil];
    
    if (pauseTimer ) [pauseTimer invalidate];
    pauseTimer = [NSTimer timerWithTimeInterval:2*60 target:self selector:@selector(Hidefor2Mins:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:pauseTimer
                              forMode:NSRunLoopCommonModes];

}


- (IBAction)TapedDaysButton:(id)sender
{
    if (days>=10)
        days=1;
    else days++;

    BeginDay = [NSDate dateWithTimeIntervalSinceNow:0];
    //    BeginDay = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:[NSDate date]];

    [self SetDays:days];
}

-(void)SetDays:(int)day
{
    self.Days.title = [NSString stringWithFormat:@"%d天" ,day];
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[self.Days attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:titleRange];
    [self.Days setAttributedTitle:colorTitle];
    
}

- (IBAction)GoalOK:(id)sender
{
    [self.GoalWindow close];
}

- (IBAction)TapedStartAgain:(id)sender
{
    [self TapedStart:nil];
}

-(void)StartTimer
{
//    self.countdownDate = [NSDate dateWithTimeIntervalSinceNow:6];
    self.countdownDate = [NSDate dateWithTimeIntervalSinceNow:PlanTime*60+1];
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    IRQCount = 0;
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.BreakTimeWindow close];
    
    [BlinkTimer invalidate];
    [TipsTimer invalidate];
    [self.TimeLabel setHidden:NO];
}


-(void)PauseTimer
{
    [self.timer invalidate];
//    self.StartButton.title = @"▸";
    Paused = YES;
}

- (IBAction)SaveAndHiden:(id)sender
{
    [self SaveData];
//    [self.WorkingTable close];
    
    
    [self.WorkingTable orderOut:self];
}

- (IBAction)TapedGood:(id)sender
{
    [self.BreakTimeWindow close];
    self.StartButton.enabled = YES;
    self.StartButton2.enabled = YES;
}


//
//<# 书签 #> 切换：⌃/ ⌃? 设置：m回车
//
-(void)ResumeTimer
{
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
//    self.StartButton.title = [NSString stringWithFormat:@"%d",count];
    Paused = NO;
}


-(void)EnableEdit
{
    self.APlanView.editable = YES;
}

-(void)StopTimer
{
    count ++;

    BreaktimeStart = [ NSDate date];
    
    self.APlanView.editable = NO;
    [self TapedSetGoal:nil];
    
    [self performSelector:@selector(EnableEdit)  withObject:nil afterDelay:1];
    
    self.StartButton2.hidden = YES;
    self.SaveButton.hidden = YES;
    self.Pause2MinsButton.hidden = NO;
    
    [self ShowTime:PlanTime seconds:0];

    [self.timer invalidate];
    
    IRQCount = 0;
    
    BlinkTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(BlinkTimerWindow:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:BlinkTimer forMode:NSRunLoopCommonModes];
}

-(void)PopBreakTimeWindow:(NSString *)info
{
    self.BreakInfo.stringValue = [NSString stringWithFormat:@"休息时间%d/5分钟",MouseSleepSecond/60];
    [self.BreakTimeWindow setLevel: NSFloatingWindowLevel];
    [self.BreakTimeWindow makeKeyAndOrderFront:self];

    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(HideBreakTimeWindow:) userInfo:nil repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}




- (void)BlinkTimerWindow:(NSTimer *)timer
{
    static bool flag = YES;
    [self.TimeLabel setHidden:flag];
    
    flag = !flag;
    
    if (flag)
    {
        [self.statusItem setTitle:[NSMutableString stringWithFormat:@"%@ %@        ",@"25:00",self.CurrentGoal.stringValue]];
    }
    else
    {
        [self.statusItem setTitle:[NSMutableString stringWithFormat:@"%@ %@        ",@"          ",self.CurrentGoal.stringValue]];
    }
    
    
    self.TimeLabel.stringValue = @"25:00";//[NSString stringWithFormat:@"%02d:%02d",MouseSleepSecond/60,MouseSleepSecond%60];
    
    
    
    NSTimeInterval BreakTime = [ [ NSDate date ] timeIntervalSinceDate:BreaktimeStart];
    
    if (BreakTime > 60 * 5) //休息时间超过5分钟，显示马上开始按钮
    {
        self.StartButton2.hidden = NO;
        self.StartButton2.enabled = YES;
        self.SaveButton.hidden = NO;
        self.Pause2MinsButton.hidden = YES;
    }
    
}


- (void)HideBreakTimeWindow:(NSTimer *)timer
{
    [self.BreakTimeWindow close];
}

- (void)applicationWillTerminate:(NSNotification *)notification;
{
    [self SaveData];
}


-(NSString *)GetCurrentTime
{
    NSDate *curDate = [NSDate date];//获取当前日期
    NSDateFormatter *formater =   [[ NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd🕑HH:mm:ss"];
    NSString * curTime = [formater stringFromDate:curDate];
    NSLog(@"%@",curTime);
    return curTime;
}


-(void)CheckMouse:(NSTimer *)timer
{
    NSLog(@"MouseMoved= %d,MouseSleepSecond = %d",MouseMoved,MouseSleepSecond);
    
    if (MouseMoved ==1 && MouseSleepSecond > 300) //鼠标不动超过5分钟，突然动了 = 回到电脑前
    {
        [self TapedPlay:nil];
    }

    if (MouseMoved ==1 && MouseSleepSecond < 300) //回到电脑前
    {
        
    }
    
    if (MouseMoved == 0 && MouseSleepSecond ==300)
    {
        NSSound *sound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"demo_audio_share" ofType:@"mp3"] byReference:NO];
        [sound play];
        [TipsTimer invalidate];
    }
    
    
    if (MouseMoved ==1)
    {
        MouseMoved = 0;
        MouseSleepSecond = 0;
    }
    
    else if (MouseMoved ==0)
    {
        MouseSleepSecond ++;
    }
    
}

#pragma mark 番茄钟自动启动设计
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    days=7;
    [self SetDays:days];

    MouseMoved = 0;
    MouseSleepSecond = 3599;

    Paused = NO;
    PlanTime = 25;
//    PlanTime = 1;
    [self.datePicker setMinDate:[NSDate date]];
    self.countdownDate = [NSDate dateWithTimeIntervalSinceNow:PlanTime*60+1];
    [self.datePicker setDateValue:self.countdownDate];
    [self.datePicker setTarget:self];
    [self.datePicker setAction:@selector(pickerChanged:)];
    
    
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    self.statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setHighlightMode:YES];
    self.statusItem.menu = self.menu;
    
    
    self.timerWindowVisible = YES;
    [self.window setOpaque:NO];

    [self.window setAlphaValue:0.8];
    
    
    ShowOnTop = NO;
    [self TapedWindow:nil];

    
    BlinkTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(BlinkTimerWindow:) userInfo:nil repeats:YES];
    
    
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    

    
    NSString * doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * path = [doc stringByAppendingPathComponent:@"working25min.sqlite"];
    self.dbPath = path;
    NSLog(@"path = %@", path);

    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.dbPath] == NO)
    {
        // create it
        FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
        [db open];
        [db close];
        [self CreateTable];
    }
    else
    {
        [self LoadData];
        self.CurrentGoalButton.title = self.CurrentGoal.stringValue;
    }
    
    [[NSRunLoop mainRunLoop] addTimer:BlinkTimer forMode:NSRunLoopCommonModes];
    [self ShowTime:PlanTime seconds:0];
    count = 0;
}


-(void)CreateTable
{
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
    NSString * sql = @"CREATE TABLE 'Work1' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'plan' VARCHAR(255), 'type' VARCHAR(1))"; //A,B,C,D - APlan ,BPlan ,CLan,DoingNow
    [db executeUpdate:sql];
    [db close];
}

-(void)CleanData
{
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
    [db executeUpdate:@"delete from Work1"];
    [db close];
}

-(void)SaveData
{
    [self CleanData];
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
    NSString * sql = @"insert into Work1 (plan, type) values(?, ?) ";
 
    
    
    NSMutableArray *APlanList = [NSMutableArray arrayWithArray:[self.APlanView.string componentsSeparatedByString:@"\n"]];
    for (id plan in APlanList)
    {
        [db executeUpdate:sql,plan,@"A"];
    }

    
    
    
    NSMutableArray *A7DaysPlanList = [NSMutableArray arrayWithArray:[self.A7DaysPlanView.string componentsSeparatedByString:@"\n"]];
    for (id plan in A7DaysPlanList)
    {
        [db executeUpdate:sql,plan,@"W"];
    }
    
    
    
    
//    NSMutableArray *BPlanList = [NSMutableArray arrayWithArray:[self.BPlanView.string componentsSeparatedByString:@"\n"]];
//    for (id plan in BPlanList)
//    {
//        [db executeUpdate:sql,plan,@"B"];
//    }
    
    

    NSMutableArray *GoalList = [NSMutableArray arrayWithArray:[self.GoalView.string componentsSeparatedByString:@"\n"]];
    for (id plan in GoalList)
    {
        [db executeUpdate:sql,plan,@"C"];
    }
    
    [db executeUpdate:sql,self.CurrentGoal.stringValue,@"D"];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.notes.string forKey:@"notes"];
    [[NSUserDefaults standardUserDefaults] setObject:self.GoalTextview.stringValue forKey:@"Goal"];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.EndDate.stringValue forKey:@"EndDate"];
    
    [[NSUserDefaults standardUserDefaults] setInteger:days forKey:@"days"];
    [[NSUserDefaults standardUserDefaults] setObject:BeginDay forKey:@"BeginDay"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [db close];
}

-(void)LoadData
{
    
    
    days = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"days"];
    BeginDay = [[NSUserDefaults standardUserDefaults] objectForKey:@"BeginDay"];
    
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
    NSString * sql = @"select * from Work1 WHERE type = 'A'";
    FMResultSet * rs = [db executeQuery:sql];
    self.APlanView.string = @"";
    while ([rs next])
    {
        self.APlanView.string = [self.APlanView.string stringByAppendingString:[rs stringForColumn:@"plan"]];
        self.APlanView.string = [self.APlanView.string stringByAppendingString:@"\n"];
    }

    sql = @"select * from Work1 WHERE type = 'W'";
    rs = [db executeQuery:sql];
    self.BPlanView.string = @"";
    while ([rs next])
    {
        self.A7DaysPlanView.string = [self.A7DaysPlanView.string stringByAppendingString:[rs stringForColumn:@"plan"]];
        self.A7DaysPlanView.string = [self.A7DaysPlanView.string stringByAppendingString:@"\n"];
    }
    
    
    
//    sql = @"select * from Work1 WHERE type = 'B'";
//    rs = [db executeQuery:sql];
//    self.BPlanView.string = @"";
//    while ([rs next])
//    {
//        self.BPlanView.string = [self.BPlanView.string stringByAppendingString:[rs stringForColumn:@"plan"]];
//        self.BPlanView.string = [self.BPlanView.string stringByAppendingString:@"\n"];
//    }
    
    sql = @"select * from Work1 WHERE type = 'C'";
    rs = [db executeQuery:sql];
    self.GoalView.string = @"";
    while ([rs next])
    {
        self.GoalView.string = [self.GoalView.string stringByAppendingString:[rs stringForColumn:@"plan"]];
        self.GoalView.string = [self.GoalView.string stringByAppendingString:@"\n"];
    }
    
    
    sql = @"select * from Work1 WHERE type = 'D'";
    rs = [db executeQuery:sql];
    self.CurrentGoal.stringValue = @"";
    while ([rs next])
    {
        self.CurrentGoal.stringValue = [rs stringForColumn:@"plan"];
    }

    
    self.APlanView.string =  [self.APlanView.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.A7DaysPlanView.string =  [self.A7DaysPlanView.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.BPlanView.string =  [self.BPlanView.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.GoalView.string =  [self.GoalView.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
//    self.APlanView.textColor = [NSColor whiteColor];
//    self.BPlanView.textColor = [NSColor whiteColor];
    

    
    self.GoalBox.wantsLayer = YES;
    self.GoalBox.layer.borderWidth = 1;
    
    
    self.notes.string = [[NSUserDefaults standardUserDefaults] objectForKey:@"notes"];
    self.GoalTextview.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"Goal"];
    
    self.EndDate.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"EndDate"];
    
    
    
    
    [db close];
}


-(void)ShowTheCountdownDays
{
    NSUInteger flags = (NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [calendar components:flags fromDate:[NSDate date] toDate:[self.dateFormatter dateFromString:self.EndDate.stringValue] options:0];
    
    
    self.WorkingTable.title = [NSString stringWithFormat:@"距离本期目标，还有%ld天%ld小时",[components day]+1,[components hour]];
}

- (IBAction)TapedShowCalendar:(id)sender
{
    [self createCalendarPopover];

    self.calendarView.date = [NSDate date];
    self.calendarView.selectedDate = [self.dateFormatter dateFromString:self.EndDate.stringValue];
    NSButton* btn = sender;
    NSRect cellRect = [btn bounds];
    [self.calendarPopover showRelativeToRect:cellRect ofView:btn preferredEdge:NSMaxYEdge];
}


- (void) createCalendarPopover {
    NSPopover* myPopover = self.calendarPopover;
    if(!myPopover) {
        myPopover = [[NSPopover alloc] init];
        self.calendarView = [[MLCalendarView alloc] init];
        self.calendarView.delegate = self;
        myPopover.contentViewController = self.calendarView;
        myPopover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
        myPopover.animates = YES;
        myPopover.behavior = NSPopoverBehaviorTransient;
    }
    self.calendarPopover = myPopover;
}


- (void) didSelectDate:(NSDate *)selectedDate {
    [self.calendarPopover close];
    self.EndDate.stringValue = [self.dateFormatter stringFromDate:selectedDate];
}

- (IBAction)TapedSetGoal2:(id)sender {
    [self TapedSetGoal:nil];
}

- (IBAction)TapedSetGoal:(NSButton *)sender
{
    [self initUI];
    
    if (![self.TimeLabel.stringValue isEqualToString:[NSString stringWithFormat:@"%d:00",PlanTime ]])
        IRQCount ++;
    
    
    [self.WorkingTable makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
    
    [self.WorkingTable setLevel: NSFloatingWindowLevel];
    
    
}


- (void)controlTextDidChange:(NSNotification *)aNotification
{
    self.CurrentGoalButton.title =self.CurrentGoal.stringValue;
}

- (IBAction)TapedWindow:(NSButton *)sender
{
    CGRect frame = self.window.frame;
    ShowOnTop = !ShowOnTop;
    if (ShowOnTop)
        frame.origin.y = [NSScreen mainScreen].frame.size.height-frame.size.height-24;
    else
        frame.origin.y = 0;
    
    
    [self.window setFrame:frame display:YES];
}


- (IBAction)TapedStart2:(id)sender
{
    [self.WorkingTable orderOut:self];
    [self TapedStart:nil];
}


- (IBAction)TapedStart:(NSButton *)sender
{
    self.StartButton.enabled = NO;
    self.StartButton2.enabled = NO;
    [self SaveData];
    [BlinkTimer invalidate];
    [TipsTimer invalidate];
    
    NSTimeInterval BreakTime = [ [ NSDate date ] timeIntervalSinceDate:BreaktimeStart];
    
    int breakMins = (int)BreakTime/60;
    if (breakMins>60*8)
    {
        count = 0;
    }
    
    if (breakMins <0)
    {
        count = 0;
        breakMins = 0;
    }
    
    
    [self.statusItem setVisible:YES];

//    if (count==0)
//        self.StartButton.title = @"0";
    
    
    NSAlert *alert = [NSAlert alertWithMessageText: [NSString stringWithFormat:@"准备聚焦目标：《%@》",self.CurrentGoal.stringValue]
                                     defaultButton: @"开始"
                                   alternateButton: nil
                                       otherButton: nil
                         informativeTextWithFormat: [NSString stringWithFormat:@"刚才已休息了%d分钟",breakMins]];

    [alert runModal];

    [self StartTimer];
}

- (IBAction)TapedPlay:(id)sender
{
//    if ([self.TimeLabel.stringValue isEqualToString:[NSString stringWithFormat:@"%d:00",PlanTime ]])
    [self TapedStart:nil];
    
//    [self.WorkingTable close];
    [self.WorkingTable orderOut:self];
}


- (IBAction)TapedVim:(id)sender
{
//    NSString *cmdLine = @"bash vim ";
//    [self performSelector:@selector(runCommand:)  withObject:cmdLine afterDelay:0];
    
    [[NSWorkspace sharedWorkspace] openFile:@"/iWork/pushgit.sh"
                            withApplication:@"TextEdit"];
}


- (IBAction)TapGoalDone:(NSButton *)sender
{
    if ([self.CurrentGoal.stringValue length]!=0) //记录完成目标
    {
        self.GoalInfo.stringValue = [NSString stringWithFormat:@"\n🎉🎊😄 搞定 😄🎊🎉\n\%@\n\n",self.CurrentGoal.stringValue];
        
        NSString *GitMessage = [NSString stringWithFormat:@"%@〰〰〰📥%@",self.CurrentGoal.stringValue,[self GetCurrentTime]];
        
        NSString *cmdLine = [self.CommandLine.stringValue stringByReplacingOccurrencesOfString:@"%1" withString:GitMessage];
//        NSLog(@"command = %@", [self runCommand:cmdLine]);
        
//        [self performSelector:@selector(runCommand:)  withObject:cmdLine afterDelay:0];
        
        [self performSelectorInBackground:@selector(runCommand:) withObject:cmdLine];
        
        self.GoalView.string = [NSString stringWithFormat:@"✅%@\n%@",self.CurrentGoal.stringValue,self.GoalView.string];
    
        self.CurrentGoal.stringValue = @"";
        
        NSMutableArray *APlanList = [NSMutableArray arrayWithArray:[self.APlanView.string componentsSeparatedByString:@"\n"]];
        [APlanList removeObjectAtIndex:0];
        self.APlanView.string = [APlanList componentsJoinedByString:@"\n"];
        
        self.CurrentGoalButton.title = self.CurrentGoal.stringValue;
    }
    
    self.APlanView.string = [self.APlanView.string stringByTrimmingCharactersInSet:
                                                                    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([self.APlanView.string length]==0)
        return;
    NSMutableArray *APlanList = [NSMutableArray arrayWithArray:[self.APlanView.string componentsSeparatedByString:@"\n"]];
    self.CurrentGoal.stringValue = [APlanList objectAtIndex:0]; // 放大第一条
    
    self.CurrentGoalButton.title = self.CurrentGoal.stringValue;
    
    [self SaveData];
}

//- (BOOL)textView:(NSTextView *)aTextView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString

- (void)textDidChange:(NSNotification *)notification
{
    NSMutableArray *APlanList = [NSMutableArray arrayWithArray:[self.APlanView.string componentsSeparatedByString:@"\n"]];
    self.CurrentGoal.stringValue = [APlanList objectAtIndex:0]; // 放大第一条
    
    self.CurrentGoalButton.title = self.CurrentGoal.stringValue;
    
//    [self SaveData];
//    return YES;
}


-(NSDateComponents *)GetLeftTime
{
    NSUInteger flags = (NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
    NSDateComponents *components = [self.calendar components:flags fromDate:[NSDate date] toDate:self.countdownDate options:0];
    return components;
}

//一秒执行一次
- (void)timerFired:(NSTimer *)timer
{
    
    NSInteger days, hours, minutes, seconds;
    
    NSDateComponents *components = [self GetLeftTime];
    
    days = [components day];
    hours = [components hour];
    minutes = [components minute];
    seconds = [components second];
    
    if (seconds <0)
    {
        [self StopTimer];
        return;
    }
    
    [self ShowTime:minutes seconds:seconds];
}

-(void)ShowTime:(long)minutes seconds:(long)seconds
{
    NSString *labelString = [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];
    
    self.ProgressBar.maxValue = PlanTime;
    self.ProgressBar.doubleValue = PlanTime-minutes;
    
    [self.TimeLabel setStringValue:labelString];
    
    [self.statusItem setTitle:[NSString stringWithFormat:@"%@ %@        ",labelString,self.CurrentGoal.stringValue]];
}

- (void)windowWillClose:(NSNotification *)notification
{
    NSWindow *window = [notification object];
    if (window == self.window) {
        self.timerWindowVisible = NO;
        NSMenuItem *item = [self.statusItem.menu itemAtIndex:0];
        [item setTitle:kShowTimerPanelString];
    }

}

- (IBAction)quit:(id)sender
{
    [[NSApplication sharedApplication] terminate:self];
}

- (IBAction)showHidePanel:(id)sender {
    NSMenuItem *item = (NSMenuItem *)sender;
    if (self.timerWindowVisible) {
        [item setTitle:kShowTimerPanelString];
//        [self.window setLevel:NSStatusWindowLevel];
//        [self.window orderOut:nil];
        [[self window] setLevel: NSFloatingWindowLevel];
    } else {
        [item setTitle:kHideTimerPanelString];
//        [self.window makeKeyAndOrderFront:nil];
//        [self.window setLevel:NSStatusWindowLevel];
        [[self window] setLevel: NSFloatingWindowLevel];
    }
    self.timerWindowVisible = !self.timerWindowVisible;
}

- (IBAction)showDatePanel:(id)sender {
    [self.datePickerPanel makeKeyAndOrderFront:nil];
}

- (void)pickerChanged:(id)sender {
    self.countdownDate = [self.datePicker dateValue];
    [self timerFired:self.timer];
}



-(NSString *)runCommand:(NSString *)commandToRun
{
    self.GitStatus.stringValue = @"🔴";
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
//    NSLog(@"run command: %@",commandToRun);
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *output;
    output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    NSLog(@"command line = %@ \n%@", commandToRun,output);
    
    if ([output containsString:@"Your branch is up-to-date with 'origin"])
        self.GitStatus.stringValue = @"🔵";
    else
        self.GitStatus.stringValue = @"🔴";
    
    return output;
}


@end

