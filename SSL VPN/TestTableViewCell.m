//
//  TestTableViewCell.m
//  testTableViewCellEdit
//
//  Created by yulingsong on 16/1/8.
//  Copyright © 2016年 yulingsong. All rights reserved.
//

#import "TestTableViewCell.h"

@implementation TestTableViewCell
@synthesize m_button,m_imageView,m_label,m_back;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.userInteractionEnabled = YES;
        
        if (!m_back)
        {
            self.m_back = [[UIView alloc]init];
            [self addSubview:m_back];
        }
        [m_back setBackgroundColor:[UIColor clearColor]];
        
        if (!m_label)
        {
            self.m_label = [[UILabel alloc]init];
            [m_back addSubview:m_label];
        }
        [m_label setBackgroundColor:[UIColor clearColor]];
        
        if (!m_imageView)
        {
            self.m_imageView = [[UIImageView alloc]init];
            [m_back addSubview:m_imageView];
        }
        [m_imageView setBackgroundColor:[UIColor clearColor]];
        
        if (!m_button)
        {
            self.m_button =  [[UILabel alloc]init];
            [m_back addSubview:m_button];
        }
        [m_button setBackgroundColor:[UIColor clearColor]];
        
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    
    if (selected) {
        m_label.textColor = [UIColor whiteColor];
        m_button.textColor = [UIColor whiteColor];

    }
    else {
        m_label.textColor = [UIColor blackColor];
        m_button.textColor = [UIColor blackColor];

    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        m_label.textColor = [UIColor whiteColor];
        m_button.textColor = [UIColor whiteColor];

    }
    else {
        m_label.textColor = [UIColor blackColor];
        m_button.textColor = [UIColor blackColor];

    }
}

- (void)awakeFromNib {
    // Initialization code
}



-(void)hiddenMyControls
{
    [m_button setHidden:YES];
    [m_imageView setHidden:YES];
    [m_label setHidden:YES];
}



@end
