//
//  LargePhotoCollectionViewCell.m
//  ClassicCamera
//
//  Created by 张文洁 on 2017/12/22.
//  Copyright © 2017年 JamStudio. All rights reserved.
//

#import "LargePhotoCollectionViewCell.h"
#import "UIImage+Rotate.h"

@implementation LargePhotoCollectionViewCell{
    UIImageView *_imageView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_imageView.layer setMasksToBounds:YES];
        [_imageView.layer setCornerRadius:5.0];
        [_imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:_imageView];
    }
    return self;
}

-(void)setImageWithUrl:(NSString *)url{
    UIImage *image = [UIImage imageWithContentsOfFile:url];
    if(image.size.height > image.size.width){
        image = [image imageRotatedByDegrees:270];
    }
    [_imageView setImage:image];
}

@end
