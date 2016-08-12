
//
//  ViewController.m
//  StopWatch
//
//  Created by nd on 16/8/9.
//  Copyright © 2016年 com.nd. All rights reserved.
//

#import <Masonry/Masonry.h>
#import "ViewController.h"
#import "MyTableViewCell.h"

@interface ViewController () {
    
    //记录是否按下开始按钮的flag
    BOOL isStartButtonPressed;
}
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger secondsForMainLabel;   //for mainLabel
@property (nonatomic, assign) NSInteger secondsForCornerLabel;   //for cornerLabel
@property (nonatomic, strong) UILabel *mainLabel;
@property (nonatomic, strong) UILabel *cornerLabel;
@property (nonatomic, strong) UIButton *countAndResetButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *timeArray;

- (void)showTime;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadViews];
}

//初始化timeArray
- (NSMutableArray *)timeArray {
    
    if (_timeArray == nil) {
        
        _timeArray = [NSMutableArray array];
    }
    return _timeArray;
}

- (void)loadViews {
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    //添加导航栏
    CGFloat navigationBarHeight = 44;
    UINavigationBar *navigationBar = [UINavigationBar new];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"秒表"];
    navigationBar.items = [NSArray arrayWithObjects:navigationItem, nil];
    [self.view addSubview:navigationBar];
    
    //设置导航栏位置
    [navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(screen.size.width, navigationBarHeight));
        make.top.equalTo(self.view.mas_top).with.offset(10);
    }];
    
    //添加右上角的label
    _cornerLabel = [UILabel new];
    _cornerLabel.backgroundColor = [UIColor whiteColor];
    _cornerLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_cornerLabel];
    //添加约束，设置cornerLabel的位置
    [_cornerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(80, 35));
        make.top.equalTo(navigationBar.mas_bottom).with.offset(2);
        make.right.equalTo(self.view.mas_right).with.offset(-20);
    }];
    
    //添加mainLabel
    CGFloat mainLabelHeight = 80;
    _mainLabel = [UILabel new];
    _mainLabel.backgroundColor = [UIColor whiteColor];
    _mainLabel.font = [UIFont fontWithName:@"ArialMT" size:60];
    _mainLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_mainLabel];
    
    //添加约束，设置mainLabel的位置
    [_mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(screen.size.width, mainLabelHeight));
        make.top.equalTo(_cornerLabel.mas_bottom);
    }];
    
    //初始化mianLabel 和 cornerLabel 的显示时间
    [self showTime];
    
    //添加按钮的backgroundView
    CGFloat backgroundViewHeight = 100;
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    [self.view addSubview:backgroundView];
    //添加约束，设置backgroundView 的位置
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(screen.size.width, backgroundViewHeight));
        make.top.equalTo(_mainLabel.mas_bottom);
    }];
    
    //添加按钮
    UIButton *startAndPauseButton = [UIButton new];
    startAndPauseButton.backgroundColor = [UIColor whiteColor];
    startAndPauseButton.layer.cornerRadius = 40;
    [startAndPauseButton setTitle:@"开始" forState:UIControlStateNormal];
    [startAndPauseButton setTitle:@"停止" forState:UIControlStateSelected];
    [startAndPauseButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [startAndPauseButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [startAndPauseButton addTarget:self action:@selector(startAndPause:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:startAndPauseButton];
    //添加约束，设置按钮位置
    [startAndPauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(80, 80));
        make.top.equalTo(backgroundView.mas_top).with.offset(10);
        make.left.equalTo(backgroundView.mas_left).with.offset((screen.size.width - 230) / 2);
    }];
    
    UIButton *countAndResetButton = [UIButton new];
    countAndResetButton.backgroundColor = [UIColor whiteColor];
    countAndResetButton.layer.cornerRadius = 40;
    [countAndResetButton setTitle:@"计次" forState:UIControlStateNormal];
    [countAndResetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [countAndResetButton addTarget:self action:@selector(countAndReset) forControlEvents:UIControlEventTouchUpInside];
    _countAndResetButton = countAndResetButton;
    [backgroundView addSubview:countAndResetButton];
    //添加约束，设置按钮位置
    [countAndResetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(80, 80));
        make.top.equalTo(backgroundView.mas_top).with.offset(10);
        make.left.equalTo(startAndPauseButton.mas_right).with.offset(60);
    }];
    
    //添加显示计次时间的tableView
    _tableView = [UITableView new];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 36;
    [self.view addSubview:_tableView];
    //添加约束，设定tableView的位置
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(screen.size.width, screen.size.height - 260));
        make.top.equalTo(backgroundView.mas_bottom);
    }];
    
    
}

- (void)startAndPause:(id)sender {
    
    UIButton *startButton = (UIButton *)sender;
    startButton.selected = !startButton.selected;
    if (!isStartButtonPressed) {
        
         NSLog(@"开始计时...");
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateTime) userInfo:nil repeats:TRUE];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        [_countAndResetButton setTitle:@"计次" forState:UIControlStateNormal];
    } else {
        
        NSLog(@"暂停...");
        [_timer invalidate];
        [_countAndResetButton setTitle:@"复位" forState:UIControlStateNormal];
    }
    isStartButtonPressed = !isStartButtonPressed;
}

- (void)countAndReset {
    
    if (!_timer) {
        
        return ;
    }
    //计次
    if (isStartButtonPressed) {
        
        [self.timeArray addObject:_cornerLabel.text];
        _secondsForCornerLabel = 0;
        NSLog(@"第%lu次:%@", (unsigned long)_timeArray.count, _cornerLabel.text);
        [self.tableView reloadData];
    } else {
        
         NSLog(@"复位.....");
        _timer = nil;
        _secondsForMainLabel = 0 ;
        _secondsForCornerLabel = 0;
        [self showTime];
        [self.countAndResetButton setTitle:@"计次" forState:UIControlStateNormal];
        _timeArray = nil;
        [self.tableView reloadData];
       
    }
    
}

- (void)updateTime {
    
    _secondsForMainLabel++;
    _secondsForCornerLabel++;
    //动态显示改变的时间
    [self showTime];
}

- (void)showTime {
    
    NSString * mainLabelTime = [NSString stringWithFormat:@"%02li:%02li.%02li", (long)_secondsForMainLabel / 60 / 100 % 60, (long)_secondsForMainLabel / 100 % 60, (long)_secondsForMainLabel % 100];
    _mainLabel.text = mainLabelTime;
    NSString *cornerLabelTime =[NSString stringWithFormat:@"%02li:%02li.%02li", (long)_secondsForCornerLabel / 60 / 100 % 60, (long)_secondsForCornerLabel / 100 % 60, (long)_secondsForCornerLabel % 100];
    _cornerLabel.text = cornerLabelTime;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _timeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identity = @"JRTableCell";
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if(cell == nil) {
        cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        cell.label.textAlignment = NSTextAlignmentCenter;
        
    }
    NSInteger originRow = indexPath.row;
    NSInteger reverseRow = _timeArray.count - 1 - originRow;
    NSString *stringText = [[NSString alloc] initWithFormat:@"第%ld次\t\t%@", reverseRow + 1, [self.timeArray objectAtIndex:reverseRow]];
    cell.label.text = stringText;
    return cell;
}


@end
