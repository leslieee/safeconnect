//
//  UICollectionReusableView+Extension.m
//  myFamily
//
//  Created by he dev on 16/1/14.
//  Copyright © 2016年 he dev. All rights reserved.
//

#import "UICollectionReusableView+Extension.h"

@implementation UICollectionReusableView (Extension)

+ (UINib *)nibWithIdentifier:(NSString *)identifier
{
    return [UINib nibWithNibName:identifier bundle:nil];
}

#pragma mark - Public
+ (void)registerCollect:(UICollectionView *)collect withKind:(NSString *)kind
          nibIdentifier:(NSString *)identifier
{
    [collect registerNib:[self nibWithIdentifier:identifier] forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
}

#pragma mark --
#pragma mark - Rewrite these func in SubClass !
- (void)configure:(UICollectionReusableView *)cell
        customObj:(id)obj
        indexPath:(NSIndexPath *)indexPath
{
    // Rewrite this func in SubClass !
    
}

+ (CGFloat)getCellHeightWithCustomObj:(id)obj
                            indexPath:(NSIndexPath *)indexPath
{
    // Rewrite this func in SubClass if necessary
    if (!obj) {
        return 0.0f ; // if obj is null .
    }
    return 44.0f ; // default cell height
}

@end
