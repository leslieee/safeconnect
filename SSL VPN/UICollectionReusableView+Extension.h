//
//  UICollectionReusableView+Extension.h
//  myFamily
//
//  Created by he dev on 16/1/14.
//  Copyright © 2016年 he dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionReusableView (Extension)

/**
 *  从nib文件中根据重用标识符注册UICollectionViewcell
 */
+ (void)registerCollect:(UICollectionView *)collect
               withKind:(NSString *)kind
          nibIdentifier:(NSString *)identifier;
/**
 *  配置UICollectionViewcell，设置UICollectionViewcell内容
 */
- (void)configure:(UICollectionReusableView *)cell
        customObj:(id)obj
        indexPath:(NSIndexPath *)indexPath ;
/**
 *  获取自定义对象的cell高度
 */
+ (CGFloat)getCellHeightWithCustomObj:(id)obj
                            indexPath:(NSIndexPath *)indexPath ;

@end
