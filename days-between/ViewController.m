//
//  ViewController.m
//  days-between
//
//  Created by Jonathan Chan on 2015-05-19.
//  Copyright (c) 2015 Jonathan Chan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) UILabel *beforeLabel;
@property (strong, nonatomic) UIButton *beforeButton;
@property (strong, nonatomic) NSDate *beforeDate;
@property (strong, nonatomic) UILabel *afterLabel;
@property (strong, nonatomic) UIButton *afterButton;
@property (strong, nonatomic) NSDate *afterDate;

@property (strong, nonatomic) UIButton *todayButton;

@property (strong, nonatomic) UIImageView *indicatorTriangle;
@property (strong, nonatomic) UILabel *daysBetweenLabel;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (nonatomic) BOOL editingBeforeDate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIFont *labelFont = [UIFont fontWithName:@"Avenir-Book" size:20];

    self.beforeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.beforeButton setTitle:@"BEFORE" forState:UIControlStateNormal];
    self.beforeButton.titleLabel.font = labelFont;
    [self.beforeButton sizeToFit];
    [self recenterBeforeButton];
    [self.view addSubview:self.beforeButton];
    [self.beforeButton addTarget:self action:@selector(beginEditingBeforeDate) forControlEvents:UIControlEventTouchUpInside];

    self.afterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.afterButton setTitle:@"AFTER" forState:UIControlStateNormal];
    self.afterButton.titleLabel.font = labelFont;
    [self.afterButton sizeToFit];
    [self recenterAfterButton];
    [self.view addSubview:self.afterButton];
    [self.afterButton addTarget:self action:@selector(beginEditingAfterDate) forControlEvents:UIControlEventTouchUpInside];

    self.beforeLabel = [UILabel new];
    [self.view addSubview:self.beforeLabel];
    self.beforeDate = [self dateToday];

    self.afterLabel = [UILabel new];
    [self.view addSubview:self.afterLabel];
    self.afterDate = [self dateToday];

    self.todayButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.todayButton.titleLabel.font = labelFont;
    [self.todayButton setTitle:@"TODAY" forState:UIControlStateNormal];
    [self.todayButton sizeToFit];
    [self recenterTodayButton];
    [self.todayButton addTarget:self action:@selector(resetADate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.todayButton];

    self.indicatorTriangle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DownTriangle"]];
    self.indicatorTriangle.tintColor = [UIColor blackColor];
    [self.view addSubview:self.indicatorTriangle];

    self.daysBetweenLabel = [UILabel new];
    self.daysBetweenLabel.font = [UIFont systemFontOfSize:40];
    self.daysBetweenLabel.text = @"0 days";
    [self recenterDaysBetweenLabel];
    [self.view addSubview:self.daysBetweenLabel];

    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.date = [self dateToday];
    [self recenterDatePicker];
    [self.datePicker addTarget:self action:@selector(datePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.datePicker];

    self.editingBeforeDate = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDate *)dateToday {
    // We must normalise the date to midnight for it to work perfectly.
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *timeNow = [NSDate date];
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:timeNow];
    NSDate *dateToday = [calendar dateFromComponents:dateComponents];
    return dateToday;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self recenterBeforeButton];
    [self recenterBeforeLabel];
    [self recenterAfterButton];
    [self recenterAfterLabel];
    [self recenterTodayButton];
    [self recenterDaysBetweenLabel];
    [self recenterIndicatorTriangle];
    [self recenterDatePicker];
}

- (void)setBeforeDate:(NSDate *)beforeDate {
    _beforeDate = beforeDate;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    self.beforeLabel.text = [dateFormatter stringFromDate:beforeDate];
    [self.beforeLabel sizeToFit];
    [self recenterBeforeLabel];
}

- (void)setAfterDate:(NSDate *)afterDate {
    _afterDate = afterDate;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    self.afterLabel.text = [dateFormatter stringFromDate:afterDate];
    [self.afterLabel sizeToFit];
    [self recenterAfterLabel];
}

- (void)setEditingBeforeDate:(BOOL)editingBeforeDate {
    _editingBeforeDate = editingBeforeDate;
    if (editingBeforeDate) {
        self.datePicker.date = self.beforeDate;
    } else {
        self.datePicker.date = self.afterDate;
    }
    [UIView animateWithDuration:0.5 animations:^{
        [self recenterIndicatorTriangle];
    }];
}

- (void)beginEditingBeforeDate {
    self.editingBeforeDate = YES;
}

- (void)beginEditingAfterDate {
    self.editingBeforeDate = NO;
}

- (void)datePickerValueChanged {
    if (self.editingBeforeDate) {
        self.beforeDate = self.datePicker.date;
    } else {
        self.afterDate = self.datePicker.date;
    }
    [self recalculateAndDisplayDaysBetween];
}

- (void)resetADate {
    NSDate *dateToday = [self dateToday];
    if (self.editingBeforeDate) {
        self.beforeDate = dateToday;
    } else {
        self.afterDate = dateToday;
    }
    self.datePicker.date = dateToday;
    [self recalculateAndDisplayDaysBetween];
}

- (void)recalculateAndDisplayDaysBetween {
    NSInteger daysBetween = [self.afterDate timeIntervalSinceDate:self.beforeDate] / 60 / 60 / 24;
    NSString *format;
    if (daysBetween == 1 || daysBetween == -1) {
        format = @"%ld day";
    } else {
        format = @"%ld days";
    }
    NSString *formattedString = [NSString stringWithFormat:format, (long)daysBetween];
    self.daysBetweenLabel.text = formattedString;
    [self recenterDaysBetweenLabel];
}

- (void)recenterDaysBetweenLabel {
    [self.daysBetweenLabel sizeToFit];
    self.daysBetweenLabel.center = CGPointMake(self.view.center.x, self.view.center.y - self.daysBetweenLabel.frame.size.height / 2);
}

- (void)recenterBeforeButton {
    self.beforeButton.center = CGPointMake(self.view.frame.size.width * 1 / 4, 50);
}

- (void)recenterBeforeLabel {
    self.beforeLabel.center = CGPointMake(self.beforeButton.center.x, self.beforeButton.frame.origin.y + self.beforeButton.frame.size.height + self.beforeLabel.frame.size.height / 2);
}

- (void)recenterAfterButton {
    self.afterButton.center = CGPointMake(self.view.frame.size.width * 3 / 4, 50);
}

- (void)recenterAfterLabel {
    self.afterLabel.center = CGPointMake(self.afterButton.center.x, self.afterButton.frame.origin.y + self.afterButton.frame.size.height + self.afterLabel.frame.size.height / 2);
}

- (void)recenterTodayButton {
    self.todayButton.center = CGPointMake(self.view.center.x, 50);
}

- (void)recenterIndicatorTriangle {
    if (self.editingBeforeDate) {
        self.indicatorTriangle.center = CGPointMake(self.beforeButton.center.x, self.beforeButton.frame.origin.y);
    } else {
        self.indicatorTriangle.center = CGPointMake(self.afterButton.center.x, self.afterButton.frame.origin.y);
    }
}

- (void)recenterDatePicker {
    [self.datePicker sizeToFit];
    self.datePicker.frame = CGRectMake(0, self.view.frame.size.height - self.datePicker.frame.size.height, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
}

@end
