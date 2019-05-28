//
//  PhotoListCollectionViewCell.h
//  ClassicCamera
//
//  Created by 张文洁 on 2018/5/8.
//  Copyright © 2018年 JamStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoListCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *imageView;

- (void)setImageWithImagePath:(NSString *)path;

@end
