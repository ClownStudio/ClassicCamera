//
//  PhotoListCollectionViewCell.m
//  ClassicCamera
//
//  Created by 张文洁 on 2018/5/8.
//  Copyright © 2018年 JamStudio. All rights reserved.
//

#import "PhotoListCollectionViewCell.h"
#import "UIImage+Rotate.h"

@implementation PhotoListCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:5];
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)setImageWithImagePath:(NSString *)path{
    NSString *path_document = NSHomeDirectory();
    NSString *imagePath = [path_document stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@.jpg",path]];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    [self.imageView setImage:image];
}
    
@end
