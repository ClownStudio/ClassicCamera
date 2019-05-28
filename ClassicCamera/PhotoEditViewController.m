//
//  PhotoEditViewController.m
//  ClassicCamera
//
//  Created by 张文洁 on 2017/12/26.
//  Copyright © 2017年 JamStudio. All rights reserved.
//

#import "PhotoEditViewController.h"
#import "ThemeManager.h"
#import "UIImage+Rotate.h"
#import "HCPhotoEditCustomSlider.h"
#import "GPUImage.h"
#import <MBProgressHUD+JDragon.h>

@interface PhotoEditViewController ()

@end

@implementation PhotoEditViewController{
    NSString *_resolution;
    NSInteger _screenWidth;
    NSInteger _screenHeight;
    NSInteger _scale;
    NSDictionary *_positions;
    UIView *_contentView;
    UIView *_largeContentView;
    UIImageView *_editImageView;
    CGFloat _factor;
    CGFloat _photoWidth;
    CGFloat _photoHeight;
    UIView *_editGroup;
    NSArray *_images;
    int _selectTag;
    UIImage *_editImage;
    CGFloat lastSliderValue;
    HCPhotoEditCustomSlider *_editSlider;
    GPUImagePicture           *picSource;
    GPUImageSaturationFilter  *SaturationFilter;
    GPUImageContrastFilter    *ContrastFilter;
    GPUImageExposureFilter    *ExposureFilter;
    GPUImageBrightnessFilter  *BrightnessFilter;
    GPUImageSharpenFilter     *SharpenFilter;
    GPUImageVignetteFilter    *VignetteFilter;
    GPUImageWhiteBalanceFilter *BalanceFilter;
    GPUImageHighlightShadowFilter *ShadowFilter;
    GPUImageHighlightShadowFilter *ShadowFilter2;
    
    UIButton *_cancel;
    UIButton *_confirm;
    BOOL _isRotate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _scale = [UIScreen mainScreen].scale;
    _resolution = [NSString stringWithFormat:@"%dX%d",(int)(_screenWidth*_scale),(int)(_screenHeight*_scale)];
    _isRotate = NO;
    
    if ([@"2001X1125" isEqualToString:_resolution]) {
        _factor = 1.5;
    }else{
        _factor = 1;
    }
    
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    UIImage *image = [themeManager themeImageWithName:[NSString stringWithFormat:@"Camera_Album_%@",_resolution]];
    if (image == nil) {
        image = [themeManager themeImageWithName:@"Camera_Album_1334X750"];
    }
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [background setImage:image];
    [self.view addSubview:background];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake((_screenWidth - (_screenHeight - 120)/9*16)/2, 20, (_screenHeight - 120)/9*16, _screenHeight - 120)];
    [self.view addSubview:_contentView];
    
    int gap = 5;
    _photoWidth = _contentView.frame.size.width;
    _photoHeight = _contentView.frame.size.height;
    
    _largeContentView = [[UIView alloc] initWithFrame:CGRectMake(gap, 0, _photoWidth + gap*2, _photoHeight + gap*2)];
    [_contentView addSubview:_largeContentView];
    
    NSString *path_document = NSHomeDirectory();
    NSString *imagePath = [path_document stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@.png",self.selectedImageName]];
    _editImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _photoWidth, _photoHeight)];
    _editImage = [UIImage imageWithContentsOfFile:imagePath];
    if(_editImage.size.height > _editImage.size.width){
        _editImage = [_editImage imageRotatedByDegrees:270];
        _isRotate = YES;
    }
    [_editImageView setImage: _editImage];
    [_editImageView.layer setMasksToBounds:YES];
    [_editImageView.layer setCornerRadius:5.0];
    [_largeContentView addSubview:_editImageView];
    
    lastSliderValue = 0;
    _images = @[@"TPhotoAdjustCategory_Level",@"TPhotoAdjustCategory_sharpness",@"TPhotoAdjustCategory_Temperature",@"TPhotoAdjustCategory_Exposure",@"TPhotoAdjustCategory_Contrast",@"TPhotoAdjustCategory_Saturation",@"TPhotoAdjustCategory_Highlight",@"TPhotoAdjustCategory_Shadow",@"TPhotoAdjustCategory_vignetteStrong"];
    _editSlider = [[HCPhotoEditCustomSlider alloc] initWithFrame:CGRectMake((_screenWidth - _largeContentView.frame.size.width)/2, _contentView.frame.origin.y + _contentView.frame.size.height + 20, _largeContentView.frame.size.width, 25)];
    [self.view addSubview:_editSlider];
    [_editSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:_largeContentView.bounds];
    titleLabel.tag = 1010;
    titleLabel.numberOfLines = 0;
    titleLabel.transform = CGAffineTransformMakeTranslation(0, -30);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:23];
    titleLabel.hidden = YES;
    titleLabel.textColor = [UIColor whiteColor];
    [_largeContentView addSubview:titleLabel];
    
    [_editSlider setTouchEndedBlock:^{
        [UIView animateWithDuration:0.2 animations:^{
            titleLabel.alpha = 0;
        } completion:^(BOOL finished) {
            titleLabel.hidden = YES;
        }];
    }];
    
    _editGroup = [[UIView alloc] initWithFrame:CGRectMake((_screenWidth - _contentView.frame.size.width)/2, _editSlider.frame.origin.y + _editSlider.frame.size.height + 5, _contentView.frame.size.width, 30)];
    CGFloat distance = (_editGroup.frame.size.width - 270)/8;
    for (NSInteger i=0; i<[_images count]; i++) {
        UIButton *button = [self getEditButtonWithIndex:i];
        CGRect temp = button.frame;
        temp.origin.x = (distance+30)*i;
        button.frame = temp;
        [_editGroup addSubview:button];
    }
    [self.view addSubview:_editGroup];
    
    _cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [_cancel setImage:[[ThemeManager sharedThemeManager] themeImageWithName:@"cancel"] forState:UIControlStateNormal];
    [_cancel addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    CGRect cancelTemp = _cancel.frame;
    cancelTemp.origin.x = _contentView.frame.origin.x - 42;
    cancelTemp.origin.y = (_screenHeight - cancelTemp.size.height)/2;
    _cancel.frame = cancelTemp;
    [self.view addSubview:_cancel];
    
    _confirm = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [_confirm setImage:[[ThemeManager sharedThemeManager] themeImageWithName:@"use"] forState:UIControlStateNormal];
    CGRect confirmTemp = _confirm.frame;
    confirmTemp.origin.x = _contentView.frame.origin.x + _contentView.frame.size.width + 20;
    confirmTemp.origin.y = (_screenHeight - confirmTemp.size.height)/2;
    _confirm.frame = confirmTemp;
    [_confirm addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_confirm];
    
    [self onSelectEdit:[_editGroup viewWithTag:1]];
}

-(IBAction)onSave:(id)sender{
    NSString *path_document = NSHomeDirectory();
    
    NSString *thumbPath = [path_document stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@.jpg",self.selectedImageName]];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImageJPEGRepresentation(_editImage, 0) writeToFile:thumbPath atomically:YES];
    
    NSString *imagePath = [path_document stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@.png",self.selectedImageName]];
    if(_isRotate){
        _editImage = [_editImage imageRotatedByDegrees:90];
    }
    
    BOOL isSaved = [UIImagePNGRepresentation(_editImage) writeToFile:imagePath atomically:YES];
    
    if (isSaved) {
        [self.navigationController popViewControllerAnimated:YES];
        [MBProgressHUD showSuccessMessage:NSLocalizedString(@"SaveSuccess", nil)];
    }else{
        [MBProgressHUD showErrorMessage:NSLocalizedString(@"SaveError", nil)];
    }
}

-(IBAction)onCancel:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sliderValueChanged:(UISlider*)slider
{
    switch (_selectTag - 1) {
        case 0:
            //层次
        {
            if (!ShadowFilter2) {
                ShadowFilter2 = [[GPUImageHighlightShadowFilter alloc] init];
                [picSource addTarget:ShadowFilter2];
            }
            
            ShadowFilter2.shadows += (_editSlider.value - lastSliderValue);
            ShadowFilter2.highlights -= (_editSlider.value - lastSliderValue);
            [self updateImage:ShadowFilter2];
            lastSliderValue = _editSlider.value;
            
            [self updateTitle:@"层次调节" value:slider.value];
        }
            
            break;
        case 1:
            //清晰度
        {
            if (!SharpenFilter) {
                SharpenFilter = [[GPUImageSharpenFilter alloc] init];
                [picSource addTarget:SharpenFilter];
            }
            SharpenFilter.sharpness = slider.value;
            [self updateImage:SharpenFilter];
            
            [self updateTitle:@"清晰度" value:slider.value];
        }
            
            break;
        case 2:
            //色温
        {
            if (!BalanceFilter) {
                BalanceFilter = [[GPUImageWhiteBalanceFilter alloc] init];
                [picSource addTarget:BalanceFilter];
            }
            BalanceFilter.temperature = slider.value;
            [self updateImage:BalanceFilter];
            
            [self updateTitle:@"色温" value:slider.value];
        }
            
            break;
        case 3:
            //曝光度
        {
            if (!ExposureFilter) {
                ExposureFilter = [[GPUImageExposureFilter alloc] init];
                [picSource addTarget:ExposureFilter];
            }
            
            ExposureFilter.exposure = slider.value;
            [self updateImage:ExposureFilter];
            [self updateTitle:@"曝光度" value:slider.value];
        }
            break;
        case 4:
            //对比度
        {
            if (!ContrastFilter) {
                ContrastFilter = [[GPUImageContrastFilter alloc] init];
                [picSource addTarget:ContrastFilter];
            }
            ContrastFilter.contrast = slider.value;
            [self updateImage:ContrastFilter];
            [self updateTitle:@"对比度" value:slider.value];
        }
            break;
        case 5:
            //饱和度
        {
            if (!SaturationFilter) {
                GPUImageSaturationFilter *filter = [[GPUImageSaturationFilter alloc] init];
                [picSource addTarget:filter];
                SaturationFilter = filter;
            }
            SaturationFilter.saturation = slider.value;
            [self updateImage:SaturationFilter];
            [self updateTitle:@"饱和度" value:slider.value];
        }
            break;
        case 6:
            //高光
        {
            if (!BrightnessFilter) {
                BrightnessFilter = [[GPUImageBrightnessFilter alloc] init];
                [picSource addTarget:BrightnessFilter];
            }
            BrightnessFilter.brightness = slider.value;
            [self updateImage:BrightnessFilter];
            [self updateTitle:@"高光调节" value:slider.value];
        }
            
            break;
        case 7:
            //阴影
        {
            if (!ShadowFilter) {
                ShadowFilter = [[GPUImageHighlightShadowFilter alloc] init];
                [picSource addTarget:ShadowFilter];
            }
            ShadowFilter.shadows = slider.value;
            [self updateImage:ShadowFilter];
            [self updateTitle:@"阴影调节" value:slider.value];
        }
            break;
        case 8:
            //暗角
        {
            if (!VignetteFilter) {
                VignetteFilter = [[GPUImageVignetteFilter alloc] init];
                [picSource addTarget:VignetteFilter];
            }
            
            VignetteFilter.vignetteStart = slider.value;
            VignetteFilter.vignetteEnd = slider.value + 0.25;
            [self updateImage:VignetteFilter];
            [self updateTitle:@"暗角" value:slider.value];
        }
            break;
            
        default:
            break;
    }
}

-(void)updateImage:(GPUImageOutput*)filter
{
    [filter useNextFrameForImageCapture];
    [picSource processImage];
    _editImage = [filter imageFromCurrentFramebufferWithOrientation:0];
    [_editImageView setImage:_editImage];
}

-(void)updateTitle:(NSString*)title  value:(float)value
{
    UILabel *label = [_largeContentView viewWithTag:1010];
    label.alpha = 1;
    label.hidden = NO;
    label.text = [NSString stringWithFormat:@"%@\n%.2f",title,value];
}

-(UIButton *)getEditButtonWithIndex:(NSInteger)index{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button addTarget:self action:@selector(onSelectEdit:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = index + 1;
    NSString * path = [[NSBundle mainBundle] pathForResource:@"CHPhotoEditResource" ofType:@"bundle"];
    path = [path stringByAppendingPathComponent:@"icon"];
    UIImage *normal = [[UIImage alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",[_images objectAtIndex:index]]]];
    UIImage *light = [[UIImage alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Light.png",[_images objectAtIndex:index]]]];
    [button setImage:normal forState:UIControlStateNormal];
    [button setImage:light forState:UIControlStateSelected];
    return button;
}

-(IBAction)onSelectEdit:(UIButton *)sender{
    _selectTag = (int)sender.tag;
    SaturationFilter = nil;
    ContrastFilter = nil;
    ExposureFilter = nil;
    BrightnessFilter = nil;
    SharpenFilter = nil;
    VignetteFilter = nil;
    BalanceFilter = nil;
    ShadowFilter = nil;
    ShadowFilter2 = nil;
    
    for (UIButton *btn in _editGroup.subviews) {
        [btn setSelected:NO];
    }
    UIButton *selectBtn = [_editGroup viewWithTag:_selectTag];
    [selectBtn setSelected:YES];
    
    picSource =  [[GPUImagePicture alloc] initWithImage:_editImage];
    switch (sender.tag - 1) {
        case 0:
            //层次
            _editSlider.maximumValue = 1;
            _editSlider.minimumValue = 0;
            _editSlider.value = 0;
            break;
        case 1:
            //清晰度
            _editSlider.minimumValue = 0.0;
            _editSlider.maximumValue = 1.5;
            _editSlider.value = 0;
            break;
        case 2:
            //色温
            _editSlider.minimumValue = 0;
            _editSlider.maximumValue = 10000.0;
            _editSlider.value = 5000.0;
            break;
        case 3:
            //曝光
            _editSlider.maximumValue = 1;
            _editSlider.minimumValue = -1;
            _editSlider.value = 0;
            break;
        case 4:
            //对比度
            _editSlider.maximumValue = 3;
            _editSlider.minimumValue = 0.3;
            _editSlider.value = 1.0;
            break;
        case 5:
            //饱和度
            _editSlider.maximumValue = 2;
            _editSlider.minimumValue = 0;
            _editSlider.value = 1.0;
            break;
        case 6:
            //高光
            _editSlider.maximumValue = 0.8;
            _editSlider.minimumValue = -0.8;
            _editSlider.value = 0.0;
            break;
        case 7:
            //阴影
            _editSlider.maximumValue = 1;
            _editSlider.minimumValue = 0;
            _editSlider.value = 0.0;
            break;
        case 8:
            //暗角
            _editSlider.maximumValue = 0.6;
            _editSlider.minimumValue = 0.4;
            _editSlider.value = 0.5;
            break;
        default:
            break;
    }
}

- (CGRect)getFrameWithString:(NSString *)string{
    CGRect frame = CGRectFromString([NSString stringWithFormat:@"{%@}",string]);
    CGRect result = CGRectMake(frame.origin.x/_scale*_factor, frame.origin.y/_scale*_factor, frame.size.width/_scale*_factor, frame.size.height/_scale*_factor);
    return result;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
