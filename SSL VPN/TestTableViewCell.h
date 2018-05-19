//
//  TestTableViewCell.h
//  testTableViewCellEdit
//
//  Created by yulingsong on 16/1/8.
//  Copyright © 2016年 yulingsong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestTableViewCell : UITableViewCell

@property (nonatomic,strong) UILabel *m_label;
@property (nonatomic,strong) UIImageView *m_imageView;
@property (nonatomic,strong) UILabel *m_button;
@property (nonatomic,strong) UIView *m_back;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)hiddenMyControls;
@end
