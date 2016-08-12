//
//  MyTableViewCell.m
//  StopWatch
//
//  Created by nd on 16/8/10.
//  Copyright © 2016年 com.nd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Masonry/Masonry.h>
#import "MyTableViewCell.h"

@interface MyTableViewCell() {
    
    BOOL buttonPressed;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end

@implementation MyTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    
    self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        
        _buttonForCell = [UIButton new];
        [_buttonForCell setBackgroundImage:[UIImage imageNamed:@"2.png"] forState:UIControlStateNormal];
        [_buttonForCell setBackgroundImage:[UIImage imageNamed:@"1.png"] forState:UIControlStateSelected];
        [_buttonForCell addTarget:self action:@selector(mark:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_buttonForCell];
        [_buttonForCell mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(36, 36));
            make.top.equalTo(self.contentView.mas_top);
            make.left.equalTo(self.contentView.mas_left);
        }];
        
        _label = [UILabel new];
        [self.contentView addSubview:_label];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(self.contentView.frame.size.width - 36, 36));
            make.left.equalTo(_buttonForCell.mas_right).with.offset(2);
            make.top.equalTo(self.contentView.mas_top);
        }];
    }
    
        return self;
}

- (void)mark:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    button.selected = !button.selected;
}

@end
