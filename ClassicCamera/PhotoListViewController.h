//
//  PhotoListViewController.h
//  ClassicCamera
//
//  Created by 张文洁 on 2018/5/7.
//  Copyright © 2018年 JamStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoListViewController : UIViewController

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *imageList;

@end
