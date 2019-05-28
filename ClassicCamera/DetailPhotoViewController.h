//
//  DetailPhotoViewController.h
//  ClassicCamera
//
//  Created by 张文洁 on 2017/12/22.
//  Copyright © 2017年 JamStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LargePhotoCollectionViewCell.h"

@interface DetailPhotoViewController : UIViewController

@property (nonatomic,strong) NSMutableArray *photoList;
@property (nonatomic) int selectedIndex;

@end
