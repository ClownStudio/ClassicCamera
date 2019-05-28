//
//  CameraViewController.m
//  ClassicCamera
//
//  Created by 张文洁 on 2017/10/30.
//  Copyright © 2017年 JamStudio. All rights reserved.
//

#import "CameraViewController.h"
#import "ThemeManager.h"
#import <QuartzCore/QuartzCore.h>
#import <Photos/Photos.h>
#import "HCTestFilter.h"
#import "UIImage+Rotate.h"
#import "YJJsonKit.h"
#import "PhotoListViewController.h"
#import <MBProgressHUD+JDragon.h>
#import "FBGlowLabel.h"
#import "NotificationMacro.h"
#import "YJJsonKit.h"
#import "PhotoXAcvFilter.h"
#import <BLImagePickerViewController.h>
#import <BLImageClipingViewController.h>
#import "DeviceOrientation.h"

@interface CameraViewController () <BLImageClipingViewControllerDelegate,DeviceOrientationDelegate>

@end

@implementation CameraViewController{
    NSString *_status;
    int _screenWidth;
    int _screenHeight;
    int _scale;
    NSString *_resolution;
    UIImageView *_cameraSkin;
    UIButton *_settingBtn;
    UIButton *_flashBtn;
    UIButton *_dateBtn;
    UIButton *_pressBtn;
    UIButton *_changeBtn;
    UIButton *_albumBtn;
    BOOL _isAutoFlash;
    BOOL _isDateOn;
    BOOL _isBonderOn;
    BOOL _isAlbumOn;
    BOOL _isAutoSave;
    UIImageView *_alertSettingView;
    UIView *_alertContentView;
    UIScrollView *_cameraSkinScrollView;
    UIScrollView *_cameraSelectScrollView;
    UIScrollView *_filterScrollView;
    UIScrollView *_filterSelectScrollView;
    UIImageView *_selectCamera;
    UIImageView *_selectFilm;
    NSArray *_filters;
    NSString *_selectFilter;
    NSString *_selectTexture;
    UIButton *_closeBtn;
    NSInteger _selectCameraIndex;
    NSInteger _selectFilterIndex;
    NSMutableArray *_imageLists;
    BOOL _canAlert;
    CGFloat _factor;
    CGFloat _bottomHeight;
    UIButton *_dateSelectBtn;
    UIButton *_restoreBtn;
    UIButton *_rateBtn;
    UIButton *_supportBtn;
    UIButton *_followBtn;
    UIButton *_moreBtn;
    CGFloat _btnPosition;
    NSMutableArray *_productContents;
    NSArray *_dateContents;
    UIView *_buyAlert;
    
    NSUInteger _willSelectTypeIndex;
    NSInteger _selectTypeIndex;
    NSInteger _selectBonderIndex;
    NSArray *_bonderList;
    UIView *_alertBonderView;
    UIImageView *_bonderCard;
    UIButton *_bonderClose;
    UIScrollView *_bonderTypeScroll;
    UIScrollView *_bonderTypeSelectScroll;
    UIScrollView *_bonderScroll;
    UIScrollView *_bonderSelectScroll;
    UIImageView *_selectType;
    UIImageView *_selectBonder;
    NSMutableArray *_bonderProductContent;
    
    UIView *_alertSectionView;
    UIButton *_datePickerButton;
    UIButton *_dateFormatButton;
    UIButton *_shotChangeButton;
    UIView *_clearView;
    BOOL _isViewPort;
    NSInteger _selectDateFromat;
    NSDate *_selectDate;
    UIView *_datePickerContentView;
    UIView *_dateFormatContentView;
    BOOL _isBigModel;
    UIDatePicker *_datePicker;
    DeviceOrientation *_deviceMotion;
    UIDeviceOrientation _deviceOrientation;
    
    BOOL _isAlbumDateOn;
    BOOL _isAlbumBonderOn;
    UIView *_albumSectionView;
    UISwitch *_bonderSwitch;
    UISwitch *_dateSwitch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isAutoSave = YES;
    _isAlbumDateOn = YES;
    _isAlbumBonderOn = NO;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:kDateType] == nil) {
        [userDefaults setObject:@"0" forKey:kDateType];
        [userDefaults synchronize];
    }
    
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _scale = [UIScreen mainScreen].scale;
    
    _status = @"Back";
    _isAutoFlash = YES;
    _isDateOn = YES;
    _isBonderOn = NO;
    _isAlbumOn = NO;
    _isViewPort = YES;
    
    _deviceMotion = [[DeviceOrientation alloc]initWithDelegate:self];
    
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kThemeIndexKey] != nil) {
        _selectCameraIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:kThemeIndexKey] integerValue];
    }else{
        _selectCameraIndex = 0;
    }
    
    _selectFilterIndex = 0;
    _willSelectTypeIndex = 0;
    _selectTypeIndex = 0;
    _selectBonderIndex = 0;
    _isBigModel = NO;
    
    NSString *dateType = [userDefaults objectForKey:kDateType];
    if (dateType) {
        _selectDateFromat = [dateType integerValue];
    }else{
        _selectDateFromat = 0;
    }
    
    if (_selectDate == nil) {
        _selectDate = [NSDate date];
    }
    
    _bonderList = [themeManager getThemeBonders];
    
    _bottomHeight = 65*_screenHeight/640;
    _dateContents = @[NSLocalizedString(@"Year", nil),NSLocalizedString(@"Month", nil),NSLocalizedString(@"Day", nil)];
    if ([@"1" isEqualToString:[userDefaults objectForKey:kStoreProductKey]]) {
        _canAlert = NO;
    }else{
        _canAlert = YES;
    }
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    _selectFilter = [[[themeManager getThemeFilters] objectAtIndex:_selectFilterIndex] objectForKey:@"filter"];
    _selectTexture = [[[themeManager getThemeFilters] objectAtIndex:_selectFilterIndex] objectForKey:@"texture"];
    
    [self initAVCaptureSession];
    
    _cameraSkin = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [_cameraSkin setUserInteractionEnabled:YES];
    _resolution = [NSString stringWithFormat:@"%dX%d",_screenWidth*_scale,_screenHeight*_scale];
    if ([@"2001X1125" isEqualToString:_resolution]) {
        _factor = 1.5;
    }else{
        _factor = 1;
    }
    [self.view addSubview:_cameraSkin];
    
    _settingBtn = [[UIButton alloc] init];
    [_settingBtn addTarget:self action:@selector(onSetting:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraSkin addSubview:_settingBtn];
    
    _flashBtn = [[UIButton alloc] init];
    [_flashBtn addTarget:self action:@selector(onFlash:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraSkin addSubview:_flashBtn];
    
    _dateBtn = [[UIButton alloc] init];
    [_dateBtn addTarget:self action:@selector(onDate:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraSkin addSubview:_dateBtn];
    
    _pressBtn = [[UIButton alloc] init];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPress:)];
    [_pressBtn addGestureRecognizer:tap];
    [_cameraSkin addSubview:_pressBtn];
    [_pressBtn setUserInteractionEnabled:YES];
    
    _changeBtn = [[UIButton alloc] init];
    [_changeBtn addTarget:self action:@selector(onChange:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraSkin addSubview:_changeBtn];
    
    _albumBtn = [[UIButton alloc] init];
    [_albumBtn addTarget:self action:@selector(onAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraSkin addSubview:_albumBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAlertStoreProduct) name:kAlertAppStoreProduct object:nil];
    _clearView = [[UIView alloc] init];
    UITapGestureRecognizer *clearTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapClear)];
    [_clearView setUserInteractionEnabled:YES];
    [_clearView addGestureRecognizer:clearTap];
    [self.view addSubview:_clearView];
    
    [self refreshCameraLayout];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_deviceMotion startMonitor];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *productDetails = [userDefaults objectForKey:kProductPurchaseKey];
    _productContents = [NSMutableArray new];
    if (productDetails != nil) {
        _productContents = [productDetails objectFromJSONString];
    }
    
    NSString *bonderDetails = [userDefaults objectForKey:kBonderProductPurchaseKey];
    _bonderProductContent = [NSMutableArray new];
    if (bonderDetails != nil) {
        _bonderProductContent = [bonderDetails objectFromJSONString];
    }
    
    NSString *themePath = [[NSBundle mainBundle] pathForResource:@"theme" ofType:@"plist"];
    NSArray *themePlistArray = [NSArray arrayWithContentsOfFile:themePath];
    
    for (int i=0; i<[themePlistArray count]; i++) {
        //超出部分补入缓存
        if (i > (int)([_productContents count] - 1)) {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:[[themePlistArray objectAtIndex:i] objectForKey:@"ProductCode"] forKey:@"ProductCode"];
            int isPurchase = [[[themePlistArray objectAtIndex:i] objectForKey:@"isPurchase"] intValue];
            NSString *result = @"";
            if (isPurchase == 1) {
                result = @"1";
            }else{
                result = @"0";
            }
            [dict setObject:result forKey:@"isPurchase"];
            [_productContents addObject:dict];
            continue;
        }
        //或者不存在的code部分补入
        if([[[themePlistArray objectAtIndex:i] objectForKey:@"ProductCode"] isEqualToString:[[_productContents objectAtIndex:i] objectForKey:@"ProductCode"]] == NO){
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:[[themePlistArray objectAtIndex:i] objectForKey:@"ProductCode"] forKey:@"ProductCode"];
            int isPurchase = [[[themePlistArray objectAtIndex:i] objectForKey:@"isPurchase"] intValue];
            NSString *result = @"";
            if (isPurchase == 1) {
                result = @"1";
            }else{
                result = @"0";
            }
            [dict setObject:result forKey:@"isPurchase"];
            [_productContents addObject:dict];
        }
    }
    [userDefaults setObject:[_productContents objectToJSONString] forKey:kProductPurchaseKey];
    [userDefaults synchronize];
    
    for (int i=0; i<[_bonderList count]; i++) {
        //超出部分补入缓存
        if (i > (int)([_bonderProductContent count] - 1)) {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:[[_bonderList objectAtIndex:i] objectForKey:@"ProductCode"] forKey:@"ProductCode"];
            int isPurchase = [[[_bonderList objectAtIndex:i] objectForKey:@"isPurchase"] intValue];
            NSString *result = @"";
            if (isPurchase == 1) {
                result = @"1";
            }else{
                result = @"0";
            }
            [dict setObject:result forKey:@"isPurchase"];
            [_bonderProductContent addObject:dict];
            continue;
        }
        //或者不存在的code部分补入
        if([[[_bonderList objectAtIndex:i] objectForKey:@"ProductCode"] isEqualToString:[[_bonderProductContent objectAtIndex:i] objectForKey:@"ProductCode"]] == NO){
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:[[_bonderList objectAtIndex:i] objectForKey:@"ProductCode"] forKey:@"ProductCode"];
            int isPurchase = [[[_bonderList objectAtIndex:i] objectForKey:@"isPurchase"] intValue];
            NSString *result = @"";
            if (isPurchase == 1) {
                result = @"1";
            }else{
                result = @"0";
            }
            [dict setObject:result forKey:@"isPurchase"];
            [_bonderProductContent addObject:dict];
        }
    }
    [userDefaults setObject:[_bonderProductContent objectToJSONString] forKey:kBonderProductPurchaseKey];
    [userDefaults synchronize];
    
    //照片名数组
    NSString *imageDetails = [userDefaults objectForKey:@"ClassicImage_FileName"];
    _imageLists = [imageDetails objectFromJSONString];
    if (_imageLists == nil) {
        _imageLists = [NSMutableArray new];
    }
    
    if (self.session) {
        [self.session startRunning];
    }
}

- (void)onAlertStoreProduct{
    if (_canAlert == NO) {
        return;
    }
    [self loadAppStoreController];
}

- (void)loadAppStoreController{
    if (@available(iOS 10.3, *)) {
        if([SKStoreReviewController respondsToSelector:@selector(requestReview)]) {
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
            [SKStoreReviewController requestReview];
        }else{
            [self layoutAlertOrder];
        }
    } else {
        [self layoutAlertOrder];
    }
    _canAlert = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"1" forKey:kStoreProductKey];
    [defaults synchronize];
}

- (void)layoutAlertOrder{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Tip", nil) message:NSLocalizedString(@"Evaluate", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0) {
            [self goToAppStore];
        }else{
            NSString *urlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@&pageNumber=0&sortOrdering=2&mt=8", APP_ID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)goToAppStore{
    NSString *itunesurl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@?mt=8&action=write-review",APP_ID];;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:itunesurl]];
}

//初始化多媒体
- (void)initAVCaptureSession{
    self.session = [[AVCaptureSession alloc] init];
    NSError *error;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    if ([device isFlashModeSupported:AVCaptureFlashModeAuto]) {
        [device setFlashMode:AVCaptureFlashModeAuto];
    }
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.view.layer.masksToBounds = YES;
    [self.view.layer addSublayer:self.previewLayer];
}

- (void)onTapClear{
    if (_isViewPort) {
        if (_isBigModel) {
            //缩小
            _isBigModel = NO;
            [self refreshCameraLayout];
        }else{
            //放大
            _isBigModel = YES;
            [self refreshBigModeLayout];
        }
    }
}

- (void)refreshBigModeLayout{
    NSString *imageName = [NSString stringWithFormat:@"big_Camera_%@_%@",_status,_resolution];
    UIImage *image = [UIImage imageNamed:imageName];
    if (image == nil) {
        image = [UIImage imageNamed:[NSString stringWithFormat:@"big_Camera_%@_1334X750",_status]];
    }
    [_cameraSkin setImage:image];
    
    NSString *shotPath = [[NSBundle mainBundle] pathForResource:@"Shot" ofType:@"plist"];
    NSDictionary *shotDict = [NSDictionary dictionaryWithContentsOfFile:shotPath];
    NSDictionary *positions = [[shotDict objectForKey:_status] objectForKey:_resolution];
    
    [_settingBtn setFrame: [self getFrameWithString:[positions objectForKey:@"Setting"]]];
    [_settingBtn setImage:[UIImage imageNamed:@"big_set"] forState:UIControlStateNormal];
    
    [_flashBtn setFrame: [self getFrameWithString:[positions objectForKey:@"Flashlight"]]];
    if (_isAutoFlash) {
        [_flashBtn setImage:[UIImage imageNamed:@"big_Flash_automatic"] forState:UIControlStateNormal];
    }else{
        [_flashBtn setImage:[UIImage imageNamed:@"big_Flash_off"] forState:UIControlStateNormal];
    }
    
    [_dateBtn setFrame: [self getFrameWithString:[positions objectForKey:@"Date"]]];
    if (_isDateOn) {
        [_dateBtn setImage:[UIImage imageNamed:@"big_Date_watermark_on"] forState:UIControlStateNormal];
    }else if(_isBonderOn){
        [_dateBtn setImage:[UIImage imageNamed:@"big_Date_frame"] forState:UIControlStateNormal];
    }else if(_isAlbumOn){
        [_dateBtn setImage:[UIImage imageNamed:@"big_Date_album"] forState:UIControlStateNormal];
    }else{
        [_dateBtn setImage:[UIImage imageNamed:@"big_Date_watermark_off"] forState:UIControlStateNormal];
    }
    
    [_pressBtn setFrame: [self getFrameWithString:[positions objectForKey:@"Press"]]];
    [_pressBtn setImage:[UIImage imageNamed:@"big_cam_button"] forState:UIControlStateNormal];
    [_pressBtn setImage:[UIImage imageNamed:@"big_cam_button_press"] forState:UIControlStateHighlighted];
    
    [self.previewLayer setFrame: [self getFrameWithString:[positions objectForKey:@"Shot"]]];
    [_clearView setFrame: [self getFrameWithString:[positions objectForKey:@"Shot"]]];
    
    [_changeBtn setFrame: [self getFrameWithString:[positions objectForKey:@"Change"]]];
    [_changeBtn setImage:[UIImage imageNamed:@"big_Camera_changes"] forState:UIControlStateNormal];
    
    [_albumBtn setFrame: [self getFrameWithString:[positions objectForKey:@"Album"]]];
    [_albumBtn setImage:[UIImage imageNamed:@"big_album_button"] forState:UIControlStateNormal];
}

- (IBAction)onAlbum:(id)sender{
    [self gotoAlbum];
}

- (void)gotoAlbum{
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (PHAuthorizationStatusAuthorized == authStatus) {
        PhotoListViewController *photoBrowser = [[PhotoListViewController alloc] init];
        photoBrowser.imageList = [[NSMutableArray alloc] initWithArray:_imageLists];
        [self.navigationController pushViewController:photoBrowser animated:YES];
    }else{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
        }];
    }
}

- (IBAction)onSetting:(id)sender{
    [self showAlertSetting];
    if ([self checkIsBuyAll] == NO) {
        [self showListBuy];
    }
}

- (BOOL)checkIsBuyAll{
    for (int i = 0; i < [_productContents count]; i++) {
        if ([@"0" isEqualToString:[[_productContents objectAtIndex:i] objectForKey:@"isPurchase"]]) {
            return NO;
        }
    }
    for (int i = 0; i < [_bonderProductContent count]; i++) {
        if ([@"0" isEqualToString:[[_bonderProductContent objectAtIndex:i] objectForKey:@"isPurchase"]]) {
            return NO;
        }
    }
    return YES;
}

- (void)showListBuy{
    _buyAlert = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    [_buyAlert setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHideBuyList)];
    [_buyAlert addGestureRecognizer:tap];
    [_alertSettingView addSubview:_buyAlert];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth * 0.7 , _screenWidth * 0.7 /556 *327)];
    [imageView setImage:[UIImage imageNamed:@"ListBuy"]];
    [imageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapBuy = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBuyAllList)];
    [imageView addGestureRecognizer:tapBuy];
    [_buyAlert addSubview:imageView];
    imageView.center = _buyAlert.center;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(imageView.frame.origin.x - 10, imageView.frame.origin.y - 10, 30, 30)];
    [button setImage:[UIImage imageNamed:@"CloseList"] forState:UIControlStateNormal];
    [_buyAlert addSubview:button];
    [button addTarget:self action:@selector(onHideBuyList) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onBuyAllList{
    if ([SKPaymentQueue canMakePayments]) {
        [self requestProductData:ALL_PRODUCT_ID];
        NSLog(@"允许程序内付费购买");
    }
    else
    {
        NSLog(@"不允许程序内付费购买");
        [MBProgressHUD showErrorMessage:NSLocalizedString(@"NoPermission", nil)];
    }
}

- (void)onHideBuyList{
    if (_buyAlert) {
        [_buyAlert removeFromSuperview];
        _buyAlert = nil;
    }
}

- (void)showAlertSetting{
    _alertSettingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    [_alertSettingView setUserInteractionEnabled:YES];
    [self.view addSubview:_alertSettingView];
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    NSString *imageName = [NSString stringWithFormat:@"Camera_Setting_%@",_resolution];
    UIImage *settingImage = [themeManager themeImageWithName:imageName];
    if (settingImage == nil) {
        settingImage = [themeManager themeImageWithName:@"Camera_Setting_1334X750"];
    }
    [_alertSettingView setImage:settingImage];
    
    NSDictionary *positions = [themeManager themePositionsWithStatus:_status andResolution:_resolution];
    CGRect contentFrame = [self getFrameWithString:[positions objectForKey:@"Alert"]];
    _alertContentView = [[UIView alloc] initWithFrame:contentFrame];
    [_alertSettingView addSubview:_alertContentView];
    [self initAlertContentView];
}

- (void)initAlertContentView{
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    
    _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    [_closeBtn setImage:[themeManager themeImageWithName:@"off_set"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [_alertContentView addSubview:_closeBtn];
    
    CGFloat imageWidth = (_alertContentView.frame.size.width - 160)/4.6;
    CGFloat imageHeight = imageWidth/107*94;
    
    _cameraSkinScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(50, (_alertContentView.frame.size.height - _bottomHeight)/2 - imageHeight, _alertContentView.frame.size.width - 100, imageHeight)];
    [_alertContentView addSubview:_cameraSkinScrollView];
    
    CGFloat filterWidth = (_alertContentView.frame.size.width - 140)/8;
    CGFloat filterHeight = filterWidth/64*97;
    
    _filterScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(50, (_alertContentView.frame.size.height - _bottomHeight)/2 + 10, _alertContentView.frame.size.width - 100, filterHeight)];
    [_alertContentView addSubview:_filterScrollView];
    
    _cameraSelectScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _cameraSkinScrollView.bounds.size.width, 20)];
    CGRect cameraSelectTemp = _cameraSelectScrollView.frame;
    cameraSelectTemp.origin.x = _cameraSkinScrollView.frame.origin.x;
    cameraSelectTemp.origin.y = _cameraSkinScrollView.frame.origin.y - 15;
    _cameraSelectScrollView.frame = cameraSelectTemp;
    [_alertContentView addSubview:_cameraSelectScrollView];
    
    _filterSelectScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _filterScrollView.bounds.size.width, 20)];
    CGRect filterSelectTemp = _filterSelectScrollView.frame;
    filterSelectTemp.origin.x = _filterScrollView.frame.origin.x;
    filterSelectTemp.origin.y = _filterScrollView.frame.origin.y + _filterScrollView.bounds.size.height + 3;
    _filterSelectScrollView.frame = filterSelectTemp;
    [_alertContentView addSubview:_filterSelectScrollView];
    
    _selectCamera = [[UIImageView alloc] initWithImage:[themeManager themeImageWithName:@"selectSkin"]];
    [_cameraSelectScrollView addSubview:_selectCamera];
    
    _selectFilm = [[UIImageView alloc] initWithImage:[themeManager themeImageWithName:@"selectFilm"]];
    [_filterSelectScrollView addSubview:_selectFilm];
    
    [self refreshScrollSkin];
    [_cameraSelectScrollView setContentSize:CGSizeMake(_cameraSkinScrollView.contentSize.width, 0)];
    
    [_cameraSkinScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [_filterScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    [self selectCameraAtIndex:_selectCameraIndex];
    [self refreshFilterGroup];
    [self initButtons];
}

- (void)refreshScrollSkin{
    for (UIView *view in [_cameraSkinScrollView subviews]) {
        if (view) {
            [view removeFromSuperview];
        }
    }
    
    CGFloat position = 0;
    CGFloat gap = 15;
    int i = 0;
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    
    NSMutableArray <UIImage *> *skins = [themeManager getAllThumbSkin];
    for (UIImage *image in skins) {
        if (image) {
            CGFloat imageWidth = (_alertContentView.frame.size.width - 160)/4.6;
            CGFloat imageHeight = imageWidth/107*94;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(position, 0, imageWidth, imageHeight)];
            [imageView setImage:image];
            imageView.tag = i + 1;
            [_cameraSkinScrollView addSubview:imageView];
            BOOL isPurchase = [[[_productContents objectAtIndex:i] objectForKey:@"isPurchase"] boolValue];
            if (isPurchase == NO) {
                UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(imageWidth/4*3, 0, imageWidth/4, imageWidth/4/36*22)];
                logo.tag = 999;
                [logo setImage:[themeManager themeImageWithName:@"PRO"]];
                [imageView addSubview:logo];
            }
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapCamera:)];
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:tap];
            position += (imageView.frame.size.width + gap);
            i++;
        }
    }
    [_cameraSkinScrollView setContentSize:CGSizeMake(position, 0)];
}

-(void)initButtons{
    _btnPosition = 50 * _screenWidth/960;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *dateType = [userDefaults objectForKey:kDateType];
    NSString *dateContent = [_dateContents objectAtIndex:[dateType integerValue]];
    if ([dateType integerValue] > [_dateContents count] - 1 && [_dateContents objectAtIndex:[dateType integerValue]] != nil) {
        dateContent = [_dateContents objectAtIndex:0];
    }else{
        dateContent = [_dateContents objectAtIndex:[dateContent integerValue]];
    }
    
    _dateSelectBtn = [self getButtonWithTitle:[NSString stringWithFormat:@"●  %@  %@",NSLocalizedString(@"Date", nil),dateContent]];
    [_dateSelectBtn addTarget:self action:@selector(onSelectDate:) forControlEvents:UIControlEventTouchUpInside];
    [_alertContentView addSubview:_dateSelectBtn];
    
    _restoreBtn = [self getButtonWithTitle:[NSString stringWithFormat:@"●  %@",NSLocalizedString(@"Restore", nil)]];
    [_restoreBtn addTarget:self action:@selector(onRestore:) forControlEvents:UIControlEventTouchUpInside];
    [_alertContentView addSubview:_restoreBtn];
    
    _rateBtn = [self getButtonWithTitle:[NSString stringWithFormat:@"●  %@",NSLocalizedString(@"Rate", nil)]];
    [_rateBtn addTarget:self action:@selector(onRate:) forControlEvents:UIControlEventTouchUpInside];
    [_alertContentView addSubview:_rateBtn];
    
    _supportBtn = [self getButtonWithTitle:[NSString stringWithFormat:@"●  %@",NSLocalizedString(@"Support", nil)]];
    [_supportBtn addTarget:self action:@selector(onSupport:) forControlEvents:UIControlEventTouchUpInside];
    [_alertContentView addSubview:_supportBtn];
    
    _followBtn = [self getButtonWithTitle:[NSString stringWithFormat:@"●  %@",NSLocalizedString(@"Follow", nil)]];
    [_followBtn addTarget:self action:@selector(onFollow:) forControlEvents:UIControlEventTouchUpInside];
    [_alertContentView addSubview:_followBtn];
    
    _moreBtn = [self getButtonWithTitle:[NSString stringWithFormat:@"●  %@",NSLocalizedString(@"More", nil)]];
    [_moreBtn addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
    [_alertContentView addSubview:_moreBtn];
}

-(IBAction)onAlbumAlert{
    _albumSectionView = [[UIView alloc] initWithFrame:self.view.bounds];
    [_albumSectionView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHideAlbumSetting)];
    [_albumSectionView addGestureRecognizer:tap];
    [_albumSectionView setUserInteractionEnabled:YES];
    [self.view addSubview:_albumSectionView];
    
    [self initAlbumSections];
}

-(void)initAlbumSections{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenHeight*0.7/3*4, _screenHeight*0.7)];
    [contentView setBackgroundColor:[UIColor blackColor]];
    [contentView.layer setMasksToBounds: YES];
    [contentView.layer setCornerRadius:10.0];
    [contentView.layer setBorderColor:[UIColor colorWithRed:0.369 green:0.369 blue:0.365 alpha:1.000].CGColor];
    [contentView.layer setBorderWidth:1.0];
    contentView.center = _albumSectionView.center;
    [_albumSectionView setClipsToBounds:YES];
    [_albumSectionView addSubview:contentView];
    
    CGFloat rowWidth = contentView.frame.size.width;
    CGFloat rowHeight = contentView.frame.size.height / 6;
    
    CGFloat position = 0;
    CGFloat distance = 15;
    
    UIView *autoSaveRow = [[UIView alloc] initWithFrame:CGRectMake(0, position, rowWidth, rowHeight)];
    [autoSaveRow setBackgroundColor:[UIColor colorWithRed:0.059 green:0.063 blue:0.071 alpha:1.000]];
    UILabel *autoSaveLabel = [[UILabel alloc] initWithFrame:CGRectMake(distance, 0, rowWidth * 0.5, rowHeight)];
    [autoSaveLabel setTextColor:[UIColor colorWithRed:0.349 green:0.349 blue:0.349 alpha:1.000]];
    [autoSaveLabel setText:NSLocalizedString(@"AutoSaveMode", nil)];
    [autoSaveRow addSubview:autoSaveLabel];
    [contentView addSubview:autoSaveRow];
    
    UISwitch *autoSaveSwitch = [[UISwitch alloc] init];
    [autoSaveSwitch setOnTintColor:[UIColor colorWithRed:0.322 green:0.647 blue:0.886 alpha:1.000]];
    [autoSaveSwitch setOn:_isAutoSave];
    CGRect autoSaveTemp = autoSaveSwitch.frame;
    autoSaveTemp.origin.x = rowWidth - autoSaveTemp.size.width - 10;
    autoSaveTemp.origin.y = (rowHeight - autoSaveTemp.size.height)/2;
    autoSaveSwitch.frame = autoSaveTemp;
    [autoSaveSwitch addTarget:self action:@selector(onAutoSaveSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [autoSaveRow addSubview:autoSaveSwitch];
    position += rowHeight;
    
    UIView *bonderRow = [[UIView alloc] initWithFrame:CGRectMake(0, position, rowWidth, rowHeight)];
    [bonderRow setBackgroundColor:[UIColor colorWithRed:0.059 green:0.063 blue:0.071 alpha:1.000]];
    UILabel *bonderLabel = [[UILabel alloc] initWithFrame:CGRectMake(distance, 0, rowWidth * 0.5, rowHeight)];
    [bonderLabel setTextColor:[UIColor colorWithRed:0.349 green:0.349 blue:0.349 alpha:1.000]];
    [bonderLabel setText:NSLocalizedString(@"AlbumBonderMode", nil)];
    [bonderRow addSubview:bonderLabel];
    [contentView addSubview:bonderRow];
    
    _bonderSwitch = [[UISwitch alloc] init];
    [_bonderSwitch setOnTintColor:[UIColor colorWithRed:0.322 green:0.647 blue:0.886 alpha:1.000]];
    [_bonderSwitch setOn:_isAlbumBonderOn];
    CGRect bonderTemp = _bonderSwitch.frame;
    bonderTemp.origin.x = rowWidth - bonderTemp.size.width - 10;
    bonderTemp.origin.y = (rowHeight - bonderTemp.size.height)/2;
    _bonderSwitch.frame = bonderTemp;
    [_bonderSwitch addTarget:self action:@selector(onBonderSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [bonderRow addSubview:_bonderSwitch];
    position += rowHeight;
    
    UIView *albumDateRow = [[UIView alloc] initWithFrame:CGRectMake(0, position, rowWidth, rowHeight)];
    [albumDateRow setBackgroundColor:[UIColor colorWithRed:0.059 green:0.063 blue:0.071 alpha:1.000]];
    UILabel *albumDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(distance, 0, rowWidth * 0.5, rowHeight)];
    [albumDateLabel setTextColor:[UIColor colorWithRed:0.349 green:0.349 blue:0.349 alpha:1.000]];
    [albumDateLabel setText:NSLocalizedString(@"AlbumDateMode", nil)];
    [albumDateRow addSubview:albumDateLabel];
    [contentView addSubview:albumDateRow];
    
    _dateSwitch = [[UISwitch alloc] init];
    [_dateSwitch setOnTintColor:[UIColor colorWithRed:0.322 green:0.647 blue:0.886 alpha:1.000]];
    [_dateSwitch setOn:_isAlbumDateOn];
    CGRect dateSwitchTemp = _dateSwitch.frame;
    dateSwitchTemp.origin.x = rowWidth - dateSwitchTemp.size.width - 10;
    dateSwitchTemp.origin.y = (rowHeight - dateSwitchTemp.size.height)/2;
    _dateSwitch.frame = dateSwitchTemp;
    [_dateSwitch addTarget:self action:@selector(onDateSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [albumDateRow addSubview:_dateSwitch];
    position += rowHeight;
    
    UIView *dateRow = [[UIView alloc] initWithFrame:CGRectMake(0, position, rowWidth, rowHeight)];
    [dateRow setBackgroundColor:[UIColor colorWithRed:0.059 green:0.063 blue:0.071 alpha:1.000]];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(distance, 0, rowWidth * 0.5, rowHeight)];
    [dateLabel setTextColor:[UIColor colorWithRed:0.349 green:0.349 blue:0.349 alpha:1.000]];
    [dateLabel setText:NSLocalizedString(@"Date", nil)];
    [dateRow addSubview:dateLabel];
    [contentView addSubview:dateRow];
    
    _datePickerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, rowWidth * 0.5, rowHeight)];
    
    [_datePickerButton setTitle:[self getDateTimeWithDate:_selectDate] forState:UIControlStateNormal];
    
    [_datePickerButton setTitleColor:[UIColor colorWithRed:0.310 green:0.647 blue:0.878 alpha:1.000] forState:UIControlStateNormal];
    [_datePickerButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    [dateRow addSubview:_datePickerButton];
    [_datePickerButton addTarget:self action:@selector(onSelectSignDate:) forControlEvents:UIControlEventTouchUpInside];
    [_datePickerButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_datePickerButton sizeToFit];
    [_datePickerButton setImageEdgeInsets:UIEdgeInsetsMake(0, _datePickerButton.frame.size.width, 0, -_datePickerButton.frame.size.width - 5)];
    CGRect dateTemp = _datePickerButton.frame;
    dateTemp.origin.x = rowWidth - dateTemp.size.width - 20;
    dateTemp.origin.y = (rowHeight - dateTemp.size.height)/2;
    _datePickerButton.frame = dateTemp;
    position += rowHeight;
    
    UIView *dateFormatRow = [[UIView alloc] initWithFrame:CGRectMake(0, position, rowWidth, rowHeight)];
    [dateFormatRow setBackgroundColor:[UIColor colorWithRed:0.059 green:0.063 blue:0.071 alpha:1.000]];
    UILabel *dateFormatLabel = [[UILabel alloc] initWithFrame:CGRectMake(distance, 0, rowWidth * 0.5, rowHeight)];
    [dateFormatLabel setTextColor:[UIColor colorWithRed:0.349 green:0.349 blue:0.349 alpha:1.000]];
    [dateFormatLabel setText:NSLocalizedString(@"DateFormat", nil)];
    [dateFormatRow addSubview:dateFormatLabel];
    [contentView addSubview:dateFormatRow];
    
    _dateFormatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, rowWidth * 0.5, rowHeight)];
    [_dateFormatButton setTitle:[_dateContents objectAtIndex:_selectDateFromat] forState:UIControlStateNormal];
    [_dateFormatButton setTitleColor:[UIColor colorWithRed:0.310 green:0.647 blue:0.878 alpha:1.000] forState:UIControlStateNormal];
    [_dateFormatButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    [_dateFormatButton addTarget:self action:@selector(onSelectDateFormat:) forControlEvents:UIControlEventTouchUpInside];
    [_dateFormatButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_dateFormatButton sizeToFit];
    [_dateFormatButton setImageEdgeInsets:UIEdgeInsetsMake(0, _dateFormatButton.frame.size.width, 0, - _dateFormatButton.frame.size.width - 5)];
    CGRect dateFromatTemp = _dateFormatButton.frame;
    dateFromatTemp.origin.x = rowWidth - dateFromatTemp.size.width - 20;
    dateFromatTemp.origin.y = (rowHeight - dateFromatTemp.size.height)/2;
    _dateFormatButton.frame = dateFromatTemp;
    [dateFormatRow addSubview:_dateFormatButton];
    position += rowHeight;
    
    UIView *restoreRow = [[UIView alloc] initWithFrame:CGRectMake(0, position, rowWidth, rowHeight)];
    [restoreRow setBackgroundColor:[UIColor colorWithRed:0.059 green:0.063 blue:0.071 alpha:1.000]];
    UIButton *restoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(distance, 0, rowWidth*0.5, rowHeight)];
    [restoreBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [restoreBtn setTitleColor:[UIColor colorWithRed:0.349 green:0.349 blue:0.349 alpha:1.000] forState:UIControlStateNormal];
    [restoreBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [restoreBtn setTitle:NSLocalizedString(@"Restore", nil) forState:UIControlStateNormal];
    [restoreBtn addTarget:self action:@selector(onRestore:) forControlEvents:UIControlEventTouchUpInside];
    [restoreRow addSubview:restoreBtn];
    [contentView addSubview:restoreRow];
}

-(IBAction)onBonderSwitch:(UISwitch *)sender{
    _isAlbumBonderOn = sender.isOn;
    if(_isAlbumBonderOn){
        _isAlbumDateOn = NO;
        [_dateSwitch setOn:NO];
    }
}

-(IBAction)onDateSwitch:(UISwitch *)sender{
    _isAlbumDateOn = sender.isOn;
    if (_isAlbumDateOn) {
        _isAlbumBonderOn = NO;
        [_bonderSwitch setOn:NO];
    }
}

-(void)onHideAlbumSetting{
    [_albumSectionView removeFromSuperview];
    _albumSectionView = nil;
}

-(IBAction)onSelectDate:(id)sender{
    _alertSectionView = [[UIView alloc] initWithFrame:self.view.bounds];
    [_alertSectionView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHideDetailSetting)];
    [_alertSectionView addGestureRecognizer:tap];
    [_alertSectionView setUserInteractionEnabled:YES];
    [self.view addSubview:_alertSectionView];
    
    [self initAlertSections];
}

-(void)initAlertSections{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenHeight*0.7/3*4, _screenHeight*0.7)];
    [contentView setBackgroundColor:[UIColor blackColor]];
    [contentView.layer setMasksToBounds: YES];
    [contentView.layer setCornerRadius:10.0];
    [contentView.layer setBorderColor:[UIColor colorWithRed:0.369 green:0.369 blue:0.365 alpha:1.000].CGColor];
    [contentView.layer setBorderWidth:1.0];
    contentView.center = _alertSectionView.center;
    [_alertSectionView setClipsToBounds:YES];
    [_alertSectionView addSubview:contentView];
    
    CGFloat rowWidth = contentView.frame.size.width;
    CGFloat rowHeight = contentView.frame.size.height / 5;
    
    CGFloat position = 0;
    CGFloat distance = 15;
    
    UIView *autoSaveRow = [[UIView alloc] initWithFrame:CGRectMake(0, position, rowWidth, rowHeight)];
    [autoSaveRow setBackgroundColor:[UIColor colorWithRed:0.059 green:0.063 blue:0.071 alpha:1.000]];
    UILabel *autoSaveLabel = [[UILabel alloc] initWithFrame:CGRectMake(distance, 0, rowWidth * 0.5, rowHeight)];
    [autoSaveLabel setTextColor:[UIColor colorWithRed:0.349 green:0.349 blue:0.349 alpha:1.000]];
    [autoSaveLabel setText:NSLocalizedString(@"AutoSaveMode", nil)];
    [autoSaveRow addSubview:autoSaveLabel];
    [contentView addSubview:autoSaveRow];
    
    UISwitch *autoSaveSwitch = [[UISwitch alloc] init];
    [autoSaveSwitch setOnTintColor:[UIColor colorWithRed:0.322 green:0.647 blue:0.886 alpha:1.000]];
    [autoSaveSwitch setOn:_isAutoSave];
    CGRect autoSaveTemp = autoSaveSwitch.frame;
    autoSaveTemp.origin.x = rowWidth - autoSaveTemp.size.width - 10;
    autoSaveTemp.origin.y = (rowHeight - autoSaveTemp.size.height)/2;
    autoSaveSwitch.frame = autoSaveTemp;
    [autoSaveSwitch addTarget:self action:@selector(onAutoSaveSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [autoSaveRow addSubview:autoSaveSwitch];
    position += rowHeight;
    
    UIView *dateRow = [[UIView alloc] initWithFrame:CGRectMake(0, position, rowWidth, rowHeight)];
    [dateRow setBackgroundColor:[UIColor colorWithRed:0.059 green:0.063 blue:0.071 alpha:1.000]];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(distance, 0, rowWidth * 0.5, rowHeight)];
    [dateLabel setTextColor:[UIColor colorWithRed:0.349 green:0.349 blue:0.349 alpha:1.000]];
    [dateLabel setText:NSLocalizedString(@"Date", nil)];
    [dateRow addSubview:dateLabel];
    [contentView addSubview:dateRow];
    
    _datePickerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, rowWidth * 0.5, rowHeight)];
    
    [_datePickerButton setTitle:[self getDateTimeWithDate:_selectDate] forState:UIControlStateNormal];
    
    [_datePickerButton setTitleColor:[UIColor colorWithRed:0.310 green:0.647 blue:0.878 alpha:1.000] forState:UIControlStateNormal];
    [_datePickerButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    [dateRow addSubview:_datePickerButton];
    [_datePickerButton addTarget:self action:@selector(onSelectSignDate:) forControlEvents:UIControlEventTouchUpInside];
    [_datePickerButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_datePickerButton sizeToFit];
    [_datePickerButton setImageEdgeInsets:UIEdgeInsetsMake(0, _datePickerButton.frame.size.width, 0, -_datePickerButton.frame.size.width - 5)];
    CGRect dateTemp = _datePickerButton.frame;
    dateTemp.origin.x = rowWidth - dateTemp.size.width - 20;
    dateTemp.origin.y = (rowHeight - dateTemp.size.height)/2;
    _datePickerButton.frame = dateTemp;
    position += rowHeight;
    
    UIView *dateFormatRow = [[UIView alloc] initWithFrame:CGRectMake(0, position, rowWidth, rowHeight)];
    [dateFormatRow setBackgroundColor:[UIColor colorWithRed:0.059 green:0.063 blue:0.071 alpha:1.000]];
    UILabel *dateFormatLabel = [[UILabel alloc] initWithFrame:CGRectMake(distance, 0, rowWidth * 0.5, rowHeight)];
    [dateFormatLabel setTextColor:[UIColor colorWithRed:0.349 green:0.349 blue:0.349 alpha:1.000]];
    [dateFormatLabel setText:NSLocalizedString(@"DateFormat", nil)];
    [dateFormatRow addSubview:dateFormatLabel];
    [contentView addSubview:dateFormatRow];
    
    _dateFormatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, rowWidth * 0.5, rowHeight)];
    [_dateFormatButton setTitle:[_dateContents objectAtIndex:_selectDateFromat] forState:UIControlStateNormal];
    [_dateFormatButton setTitleColor:[UIColor colorWithRed:0.310 green:0.647 blue:0.878 alpha:1.000] forState:UIControlStateNormal];
    [_dateFormatButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    [_dateFormatButton addTarget:self action:@selector(onSelectDateFormat:) forControlEvents:UIControlEventTouchUpInside];
    [_dateFormatButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_dateFormatButton sizeToFit];
    [_dateFormatButton setImageEdgeInsets:UIEdgeInsetsMake(0, _dateFormatButton.frame.size.width, 0, - _dateFormatButton.frame.size.width - 5)];
    CGRect dateFromatTemp = _dateFormatButton.frame;
    dateFromatTemp.origin.x = rowWidth - dateFromatTemp.size.width - 20;
    dateFromatTemp.origin.y = (rowHeight - dateFromatTemp.size.height)/2;
    _dateFormatButton.frame = dateFromatTemp;
    [dateFormatRow addSubview:_dateFormatButton];
    position += rowHeight;
    
    UIView *viewPortRow = [[UIView alloc] initWithFrame:CGRectMake(0, position, rowWidth, rowHeight)];
    [viewPortRow setBackgroundColor:[UIColor colorWithRed:0.059 green:0.063 blue:0.071 alpha:1.000]];
    UILabel *viewPortLabel = [[UILabel alloc] initWithFrame:CGRectMake(distance, 0, rowWidth * 0.5, rowHeight)];
    [viewPortLabel setTextColor:[UIColor colorWithRed:0.349 green:0.349 blue:0.349 alpha:1.000]];
    [viewPortLabel setText:NSLocalizedString(@"ViewPortHitEnable", nil)];
    [viewPortRow addSubview:viewPortLabel];
    [contentView addSubview:viewPortRow];
    
    UISwitch *viewPortSwitch = [[UISwitch alloc] init];
    [viewPortSwitch setOnTintColor:[UIColor colorWithRed:0.322 green:0.647 blue:0.886 alpha:1.000]];
    [viewPortSwitch setOn:_isViewPort];
    CGRect viewPortTemp = viewPortSwitch.frame;
    viewPortTemp.origin.x = rowWidth - viewPortTemp.size.width - 10;
    viewPortTemp.origin.y = (rowHeight - viewPortTemp.size.height)/2;
    viewPortSwitch.frame = viewPortTemp;
    [viewPortSwitch addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [viewPortRow addSubview:viewPortSwitch];
    position += rowHeight;
    
    UIView *restoreRow = [[UIView alloc] initWithFrame:CGRectMake(0, position, rowWidth, rowHeight)];
    [restoreRow setBackgroundColor:[UIColor colorWithRed:0.059 green:0.063 blue:0.071 alpha:1.000]];
    UIButton *restoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(distance, 0, rowWidth*0.5, rowHeight)];
    [restoreBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [restoreBtn setTitleColor:[UIColor colorWithRed:0.349 green:0.349 blue:0.349 alpha:1.000] forState:UIControlStateNormal];
    [restoreBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [restoreBtn setTitle:NSLocalizedString(@"Restore", nil) forState:UIControlStateNormal];
    [restoreBtn addTarget:self action:@selector(onRestore:) forControlEvents:UIControlEventTouchUpInside];
    [restoreRow addSubview:restoreBtn];
    [contentView addSubview:restoreRow];
}

-(IBAction)onAutoSaveSwitch:(UISwitch *)sender{
    if (sender.isOn) {
        _isAutoSave = YES;
    }else{
        _isAutoSave = NO;
    }
}

-(IBAction)onSwitch:(UISwitch *)sender{
    NSLog(@"点击：%d",(int)sender.isOn);
    if (sender.isOn) {
        _isViewPort = YES;
    }else{
        _isViewPort = NO;
    }
}

-(IBAction)onSelectSignDate:(id)sender{
    _datePickerContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHideDatePicker)];
    [_datePickerContentView addGestureRecognizer:tap];
    [_datePickerContentView setUserInteractionEnabled:YES];
    [_datePickerContentView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
    [self.view addSubview:_datePickerContentView];
    
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, _screenHeight - 210, _screenWidth, 40)];
    [toolbar setBackgroundColor:[UIColor whiteColor]];
    [_datePickerContentView addSubview:toolbar];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 40 - 1/[UIScreen mainScreen].scale, _screenWidth, 1/[UIScreen mainScreen].scale)];
    [line setBackgroundColor:[UIColor lightGrayColor]];
    [toolbar addSubview:line];
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:NSLocalizedString(@"ResetDate", nil) forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [button setTitleColor:[UIColor colorWithRed:0.255 green:0.608 blue:0.976 alpha:1.000] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(onResetDate) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:button];
    
    CGRect temp = button.frame;
    temp.origin.x = toolbar.frame.size.width - temp.size.width - 15;
    temp.origin.y = (toolbar.frame.size.height - temp.size.height)/2;
    button.frame = temp;
    
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, _screenHeight - 170, _screenWidth, 170)];
    [_datePicker setBackgroundColor:[UIColor whiteColor]];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    if (_selectDate == nil) {
        [_datePicker setDate:[NSDate date]];
    }else{
        [_datePicker setDate:_selectDate];
    }
    
    [_datePicker addTarget:self action:@selector(dateChange:)forControlEvents:UIControlEventValueChanged];
    [_datePickerContentView addSubview:_datePicker];
}

- (void)onResetDate{
    _selectDate = [NSDate date];
    [_datePicker setDate:_selectDate];
    [_datePickerButton setTitle:[self getDateTimeWithDate:_selectDate] forState:UIControlStateNormal];
    [_datePickerButton sizeToFit];
}

- (void)onHideDatePicker{
    [_datePickerContentView removeFromSuperview];
    _datePickerContentView = nil;
}

- (void)dateChange:(UIDatePicker *)datePicker{
    _selectDate = datePicker.date;
    [_datePickerButton setTitle:[self getDateTimeWithDate:_selectDate] forState:UIControlStateNormal];
    [_datePickerButton sizeToFit];
}

-(IBAction)onSelectDateFormat:(id)sender{
    _dateFormatContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHideFormatPicker)];
    [_dateFormatContentView addGestureRecognizer:tap];
    [_dateFormatContentView setUserInteractionEnabled:YES];
    [_dateFormatContentView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
    [self.view addSubview:_dateFormatContentView];
    UIPickerView *formatPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, _screenHeight - 150, _screenWidth, 150)];
    [formatPicker setBackgroundColor:[UIColor whiteColor]];
    [formatPicker setDelegate:self];
    [formatPicker setDataSource:self];
    [formatPicker selectRow:_selectDateFromat inComponent:0 animated:NO];
    [_dateFormatContentView addSubview:formatPicker];
}

-(void)onHideFormatPicker{
    [_dateFormatContentView removeFromSuperview];
    _dateFormatContentView = nil;
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_dateContents count];
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [_dateContents objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)row] forKey:kDateType];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_dateSelectBtn setTitle:[NSString stringWithFormat:@"●  %@  %@",NSLocalizedString(@"Date", nil),[_dateContents objectAtIndex:row]] forState:UIControlStateNormal];
    _selectDateFromat = row;
    [_dateFormatButton setTitle:[_dateContents objectAtIndex:row] forState:UIControlStateNormal];
    [_dateFormatButton sizeToFit];
    [_datePickerButton setTitle:[self getDateTimeWithDate:_selectDate] forState:UIControlStateNormal];
    [_datePickerButton sizeToFit];
}

-(void)onHideDetailSetting{
    [_alertSectionView removeFromSuperview];
    _alertSectionView = nil;
}

-(IBAction)onRestore:(id)sender{
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"允许程序内付费购买");
        [MBProgressHUD showInfoMessage:NSLocalizedString(@"Restoring", nil)];
        SKPaymentQueue *paymentQueue = [SKPaymentQueue defaultQueue];
        // 恢复所有非消耗品
        [paymentQueue restoreCompletedTransactions];
    }
    else
    {
        NSLog(@"不允许程序内付费购买");
        [MBProgressHUD showErrorMessage:NSLocalizedString(@"NoPermission", nil)];
    }
}

// 对已购商品，处理恢复购买的逻辑
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    // 恢复成功，对于非消耗品才能恢复,如果恢复成功则transaction中记录的恢复的产品交易
    // 把商品ID存起来
    NSLog(@"%@",transaction.payment.productIdentifier);
    if ([ALL_PRODUCT_ID isEqualToString:transaction.payment.productIdentifier]) {
        [self refreshAllProduct];
    }else{
        BOOL isChecked = NO;
        for (NSDictionary *dict in _productContents) {
            if ([[dict objectForKey:@"ProductCode"] isEqualToString:transaction.payment.productIdentifier]) {
                [self restoreProductsWithId:transaction.payment.productIdentifier];
                isChecked = YES;
                break;
            }
        }
        
        if (!isChecked) {
            for (NSDictionary *dict in _bonderProductContent) {
                if ([[dict objectForKey:@"ProductCode"] isEqualToString:transaction.payment.productIdentifier]) {
                    [self restoreBonderProductsWithId:transaction.payment.productIdentifier];
                    break;
                }
            }
        }
    }
    
    // 结束支付交易
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)refreshAllProduct{
    for (int i = 0; i < [_productContents count]; i++) {
        NSMutableDictionary *dict = [_productContents objectAtIndex:i];
        [dict setObject:@"1" forKey:@"isPurchase"];
        [_productContents replaceObjectAtIndex:i withObject:dict];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[_productContents objectToJSONString] forKey:kProductPurchaseKey];
    [userDefaults synchronize];
    
    for (int i = 0; i < [_bonderProductContent count]; i++) {
        NSMutableDictionary *dict = [_bonderProductContent objectAtIndex:i];
        [dict setObject:@"1" forKey:@"isPurchase"];
        [_bonderProductContent replaceObjectAtIndex:i withObject:dict];
    }
    [userDefaults setObject:[_bonderProductContent objectToJSONString] forKey:kBonderProductPurchaseKey];
    [userDefaults synchronize];
}

// 去苹果服务器请求产品信息
- (void)requestProductData:(NSString *)productId {
    [MBProgressHUD showActivityMessageInView:NSLocalizedString(@"Loading", nil)];
    NSArray *productArr = [[NSArray alloc]initWithObjects:productId, nil];
    
    NSSet *productSet = [NSSet setWithArray:productArr];
    
    SKProductsRequest *request = [[SKProductsRequest alloc]initWithProductIdentifiers:productSet];
    request.delegate = self;
    [request start];
}

// 收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *productArr = response.products;
    
    if ([productArr count] == 0) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showErrorMessage:NSLocalizedString(@"NoCheckout", nil)];
        return;
    }
    
    NSLog(@"productId = %@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量 = %lu",(unsigned long)productArr.count);
    
    SKProduct *p = nil;
    
    for (SKProduct *pro in productArr) {
        NSLog(@"description:%@",[pro description]);
        NSLog(@"localizedTitle:%@",[pro localizedTitle]);
        NSLog(@"localizedDescription:%@",[pro localizedDescription]);
        NSLog(@"price:%@",[pro price]);
        NSLog(@"productIdentifier:%@",[pro productIdentifier]);
        if ([pro.productIdentifier isEqualToString:[[_productContents objectAtIndex:_selectCameraIndex] objectForKey:@"ProductCode"]] || [pro.productIdentifier isEqualToString:[[_bonderProductContent objectAtIndex:_willSelectTypeIndex] objectForKey:@"ProductCode"]]) {
            p = pro;
        }
    }
    if (p == nil && [productArr count] == 1) {
        p = [productArr firstObject];
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    
    //发送内购请求
    @try {
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.reason);
    } @finally {
        
    }
}

- (void)requestDidFinish:(SKRequest *)request {
    [MBProgressHUD hideHUD];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [MBProgressHUD showErrorMessage:NSLocalizedString(@"PayError", nil)];
}

// 监听购买结果

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    
    for (SKPaymentTransaction *tran in transactions) {
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased: //交易完成
            // 发送到苹果服务器验证凭证
            [[SKPaymentQueue defaultQueue]finishTransaction:tran];
            if ([ALL_PRODUCT_ID isEqualToString:tran.payment.productIdentifier]) {
                [self refreshAllProduct];
            }else{
                BOOL isChecked = NO;
                for (NSDictionary *dict in _productContents) {
                    if ([[dict objectForKey:@"ProductCode"] isEqualToString:tran.payment.productIdentifier]) {
                        [self refreshLogo];
                        isChecked = YES;
                        break;
                    }
                }
                _selectTypeIndex = _willSelectTypeIndex;
                _willSelectTypeIndex = 0;
                if (!isChecked) {
                    for (NSDictionary *dict in _bonderProductContent) {
                        if ([[dict objectForKey:@"ProductCode"] isEqualToString:tran.payment.productIdentifier]) {
                            [self refreshBonderLogo];
                            break;
                        }
                    }
                }
            }
            if (_alertBonderView) {
                [self refreshScrollBonderType];
                [self selectTypeAtIndex:_selectTypeIndex];
            }
            [self onHideBuyList];
            
            break;
            case SKPaymentTransactionStatePurchasing: //商品添加进列表
            break;
            case SKPaymentTransactionStateRestored: //购买过
            // 发送到苹果服务器验证凭证
            [self restoreTransaction:tran];
            if (_alertSettingView) {
                [self refreshScrollSkin];
                [self selectCameraAtIndex:_selectCameraIndex];
            }
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccessMessage:NSLocalizedString(@"RestoreComplete", nil)];
            break;
            case SKPaymentTransactionStateFailed: //交易失败
            _willSelectTypeIndex = 0;
            [[SKPaymentQueue defaultQueue]finishTransaction:tran];
            [MBProgressHUD hideHUD];
            [MBProgressHUD showErrorMessage:NSLocalizedString(@"PayError", nil)];
            break;
            
            default:
            break;
        }
    }
}

- (void)refreshBonderLogo{
    NSMutableDictionary *dict = [_bonderProductContent objectAtIndex:_selectTypeIndex];
    [dict setObject:@"1" forKey:@"isPurchase"];
    [_bonderProductContent replaceObjectAtIndex:_selectTypeIndex withObject:dict];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[_bonderProductContent objectToJSONString] forKey:kBonderProductPurchaseKey];
    [userDefaults synchronize];
    
    if (_alertBonderView != nil) {
        UIView *view = [_bonderTypeScroll viewWithTag:_selectTypeIndex + 1];
        UIImageView *logo = [view viewWithTag: 999];
        [logo removeFromSuperview];
        logo = nil;
    }
}

- (void)restoreProductsWithId:(NSString *)productId{
    for (int i = 0; i < [_productContents count]; i++) {
        if ([productId isEqualToString:[[_productContents objectAtIndex:i] objectForKey:@"ProductCode"]]) {
            NSMutableDictionary *dict = [_productContents objectAtIndex:i];
            [dict setObject:@"1" forKey:@"isPurchase"];
            [_productContents replaceObjectAtIndex:i withObject:dict];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[_productContents objectToJSONString] forKey:kProductPurchaseKey];
            [userDefaults synchronize];
            break;
        }
    }
}

- (void)restoreBonderProductsWithId:(NSString *)productId{
    for (int i = 0; i < [_bonderProductContent count]; i++) {
        if ([productId isEqualToString:[[_bonderProductContent objectAtIndex:i] objectForKey:@"ProductCode"]]) {
            NSMutableDictionary *dict = [_bonderProductContent objectAtIndex:i];
            [dict setObject:@"1" forKey:@"isPurchase"];
            [_bonderProductContent replaceObjectAtIndex:i withObject:dict];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[_bonderProductContent objectToJSONString] forKey:kBonderProductPurchaseKey];
            [userDefaults synchronize];
            break;
        }
    }
}

-(void)refreshLogo{
    NSMutableDictionary *dict = [_productContents objectAtIndex:_selectCameraIndex];
    [dict setObject:@"1" forKey:@"isPurchase"];
    [_productContents replaceObjectAtIndex:_selectCameraIndex withObject:dict];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[_productContents objectToJSONString] forKey:kProductPurchaseKey];
    [userDefaults synchronize];
    
    if (_alertSettingView != nil) {
        UIImageView *logo = [[_cameraSkinScrollView viewWithTag:_selectCameraIndex + 1] viewWithTag: 999];
        [logo removeFromSuperview];
        logo = nil;
    }
}

-(IBAction)onRate:(id)sender{
    [self layoutAlertOrder];
}

-(IBAction)onSupport:(id)sender{
    if ([MFMailComposeViewController canSendMail]) { // 用户已设置邮件账户
        
    }else{
        [MBProgressHUD showErrorMessage:NSLocalizedString(@"NoMailAccount", nil)];
        return;
    }
    if ([MFMessageComposeViewController canSendText] == YES) {
        MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc]init];
        mailCompose.mailComposeDelegate = self;
        [mailCompose setSubject:@""];
        NSArray *arr = @[@"samline228@yahoo.com"];
        //收件人
        [mailCompose setToRecipients:arr];
        [self presentViewController:mailCompose animated:YES completion:nil];
    }else{
        [MBProgressHUD showErrorMessage:NSLocalizedString(@"NoSupportMail", nil)];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error{
    if (result) {
        NSLog(@"Result : %ld",(long)result);
    }
    if (error) {
        NSLog(@"Error : %@",error);
    }
    switch (result)
    {
        case MFMailComposeResultCancelled: // 用户取消编辑
        NSLog(@"Mail send canceled...");
        break;
        case MFMailComposeResultSaved: // 用户保存邮件
        NSLog(@"Mail saved...");
        break;
        case MFMailComposeResultSent: // 用户点击发送
        NSLog(@"Mail sent...");
        break;
        case MFMailComposeResultFailed: // 用户尝试保存或发送邮件失败
        NSLog(@"Mail send errored: %@...", [error localizedDescription]);
        break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)onFollow:(id)sender{
    NSString *urlText = [NSString stringWithFormat:@"https://www.instagram.com"];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlText]];
}

-(IBAction)onMore:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/id1304078556"]];
}

-(UIButton *)getButtonWithTitle:(NSString *)title{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    if ([@"960X640" isEqualToString:_resolution] || [@"1136X640" isEqualToString:_resolution]) {
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:8]];
    }else{
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    }
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    CGSize restoreTitleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:button.titleLabel.font.fontName size:button.titleLabel.font.pointSize]}];
    CGRect restoreTemp = [button frame];
    restoreTemp.origin.x = _btnPosition;
    if ([@"960X640" isEqualToString:_resolution] || [@"1136X640" isEqualToString:_resolution]) {
        restoreTemp.origin.y = _alertContentView.frame.size.height - _bottomHeight + 10;
    }else{
        restoreTemp.origin.y = _alertContentView.frame.size.height - _bottomHeight + 13;
    }
    
    restoreTemp.size.width = restoreTitleSize.width + 5;
    restoreTemp.size.height = restoreTitleSize.height;
    button.frame = restoreTemp;
    _btnPosition += restoreTitleSize.width + 10;
    
    if ([@"960X640" isEqualToString:_resolution] || [@"1136X640" isEqualToString:_resolution]) {
        [button.titleLabel setAdjustsFontSizeToFitWidth:YES];
    }
    return button;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([object isEqual:_cameraSkinScrollView]){
        [_cameraSelectScrollView setContentOffset:_cameraSkinScrollView.contentOffset];
    }else if ([object isEqual:_filterScrollView]){
        [_filterSelectScrollView setContentOffset:_filterScrollView.contentOffset];
    }else if([object isEqual:_bonderTypeScroll]){
        [_bonderTypeSelectScroll setContentOffset:_bonderTypeScroll.contentOffset];
    }else if([object isEqual:_bonderScroll]){
        [_bonderSelectScroll setContentOffset:_bonderScroll.contentOffset];
    }
}

- (void)refreshFilterGroup{
    for (UIView *view in _filterScrollView.subviews) {
        if (view) {
            [view removeFromSuperview];
        }
    }
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    _filters = [themeManager getThemeFilters];
    
    CGFloat position = 0;
    CGFloat gap = 5;
    int i = 1;
    
    for (NSDictionary *dict in _filters) {
        CGFloat filterWidth = (_alertContentView.frame.size.width - 140)/8;;
        CGFloat filterHeight = filterWidth/64*97;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(position, 0, filterWidth, filterHeight)];
        [imageView setImage:[themeManager themeImageWithName:[dict objectForKey:@"icon"]]];
        imageView.tag = i;
        [_filterScrollView addSubview:imageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapFilter:)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tap];
        position += (imageView.frame.size.width + gap);
        i++;
    }
    [_filterScrollView setContentSize:CGSizeMake(position, 0)];
    [_filterScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [_filterSelectScrollView setContentSize:CGSizeMake(position, 0)];
    [self selectFilterAtIndex:_selectFilterIndex];
}

- (void)selectFilterAtIndex:(NSInteger)index{
    _selectFilterIndex = index;
    UIImageView *imageView = [_filterScrollView viewWithTag:index + 1];
    CGRect temp = _selectFilm.frame;
    temp.origin.x = imageView.frame.origin.x + (imageView.frame.size.width * 0.8 - _selectFilm.frame.size.width)/2;
    _selectFilm.frame = temp;
    
    _selectFilter = [[[[ThemeManager sharedThemeManager] getThemeFilters] objectAtIndex:index] objectForKey:@"filter"];
    
    _selectTexture = [[[[ThemeManager sharedThemeManager] getThemeFilters] objectAtIndex:index] objectForKey:@"texture"];
    
    NSLog(@"SelectFilter: %@ Texture :%@",_selectFilter,_selectTexture);
}

- (void)onTapFilter:(UIGestureRecognizer *)gestureRecognizer{
    if (_selectFilterIndex == gestureRecognizer.view.tag - 1) {
        return;
    }
    [self selectFilterAtIndex:gestureRecognizer.view.tag - 1];
}

- (void)onTapCamera:(UIGestureRecognizer *)gestureRecognizer{
    if (_selectCameraIndex == gestureRecognizer.view.tag - 1) {
        return;
    }
    _selectFilterIndex = 0;
    [self selectCameraAtIndex:gestureRecognizer.view.tag - 1];
}

- (void)selectCameraAtIndex:(NSInteger)index{
    _selectCameraIndex = index;
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    [themeManager setThemeIndex:index];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)index] forKey:kThemeIndexKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIImageView *imageView = [_cameraSkinScrollView viewWithTag:index + 1];
    CGRect temp = _selectCamera.frame;
    temp.origin.x = imageView.center.x - _selectCamera.frame.size.width/2;
    _selectCamera.frame = temp;
    [self refreshCameraSkin];
}

- (void)refreshCameraSkin{
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    [_closeBtn setImage:[themeManager themeImageWithName:@"off_set"] forState:UIControlStateNormal];
    NSString *imageName = [NSString stringWithFormat:@"Camera_Setting_%@",_resolution];
    UIImage *settingImage = [themeManager themeImageWithName:imageName];
    if (settingImage == nil) {
        settingImage = [themeManager themeImageWithName:@"Camera_Setting_1334X750"];
    }
    [_alertSettingView setImage:settingImage];
    [self refreshFilterGroup];
    
    if (_isBigModel) {
        [self refreshBigModeLayout];
    }else{
        [self refreshCameraLayout];
    }
}

- (IBAction)onClose:(id)sender{
    [_cameraSkinScrollView removeObserver:self forKeyPath:@"contentOffset"];
    [_filterScrollView removeObserver:self forKeyPath:@"contentOffset"];
    [_alertSettingView removeFromSuperview];
    _alertSettingView = nil;
}

- (IBAction)onFlash:(id)sender{
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    if (_isAutoFlash) {
        if ([device isFlashModeSupported:AVCaptureFlashModeOff]) {
            [device setFlashMode:AVCaptureFlashModeOff];
            _isAutoFlash = NO;
            if (_isBigModel) {
                [_flashBtn setImage:[UIImage imageNamed:@"big_Flash_off"] forState:UIControlStateNormal];
            }else{
                [_flashBtn setImage:[themeManager themeImageWithName:@"Flash_off"] forState:UIControlStateNormal];
            }
        }else{
            [MBProgressHUD showErrorMessage:NSLocalizedString(@"NoSupportLight", nil)];
        }
    }else{
        if ([device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            _isAutoFlash = YES;
            if (_isBigModel) {
                [_flashBtn setImage:[UIImage imageNamed:@"big_Flash_automatic"] forState:UIControlStateNormal];
            }else{
                [_flashBtn setImage:[themeManager themeImageWithName:@"Flash_automatic"] forState:UIControlStateNormal];
            }
            [device setFlashMode:AVCaptureFlashModeAuto];
        }else{
            [MBProgressHUD showErrorMessage:NSLocalizedString(@"NoSupportLight", nil)];
        }
    }
    [device unlockForConfiguration];
}

- (IBAction)onDate:(id)sender{
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    if(_isDateOn){
        _isDateOn = NO;
        _isBonderOn = YES;
        _isAlbumOn = NO;
        [self onAlertBonderSelection];
        if (_isBigModel) {
            [_dateBtn setImage:[UIImage imageNamed:@"big_Date_frame"] forState:UIControlStateNormal];
        }else{
            [_dateBtn setImage:[themeManager themeImageWithName:@"Date_frame"] forState:UIControlStateNormal];
        }
    }else if(_isBonderOn){
        _isDateOn = NO;
        _isBonderOn = NO;
        _isAlbumOn = YES;
        [self onAlbumAlert];
        if (_isBigModel) {
            [_dateBtn setImage:[UIImage imageNamed:@"big_Date_album"] forState:UIControlStateNormal];
        }else{
            [_dateBtn setImage:[themeManager themeImageWithName:@"Date_album"] forState:UIControlStateNormal];
        }
    }else if (_isAlbumOn){
        _isDateOn = NO;
        _isBonderOn = NO;
        _isAlbumOn = NO;
        if (_isBigModel) {
            [_dateBtn setImage:[UIImage imageNamed:@"big_Date_watermark_off"] forState:UIControlStateNormal];
        }else{
            [_dateBtn setImage:[themeManager themeImageWithName:@"Date_watermark_off"] forState:UIControlStateNormal];
        }
    }else{
        _isDateOn = YES;
        _isBonderOn = NO;
        _isAlbumOn = NO;
        if (_isBigModel) {
            [_dateBtn setImage:[UIImage imageNamed:@"big_Date_watermark_on"] forState:UIControlStateNormal];
        }else{
            [_dateBtn setImage:[themeManager themeImageWithName:@"Date_watermark_on"] forState:UIControlStateNormal];
        }
    }
}

- (void)onAlertBonderSelection{
    _alertBonderView = [[UIView alloc] initWithFrame:self.view.bounds];
    [_alertBonderView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCloseBonder)];
    [_alertBonderView setUserInteractionEnabled:YES];
    [_alertBonderView addGestureRecognizer:tap];
    [self.view addSubview:_alertBonderView];
    
    _bonderCard = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenHeight *0.8/890*1506, _screenHeight *0.8)];
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    [_bonderCard setImage:[themeManager themeImageWithName:@"frame_ui"]];
    [_bonderCard setUserInteractionEnabled:YES];
    _bonderCard.center = _alertBonderView.center;
    [_alertBonderView addSubview:_bonderCard];
    
    UIButton *restoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(_bonderCard.bounds.size.width * 0.45, _bonderCard.bounds.size.height * 0.045, 150, 30)];
    [restoreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [restoreBtn setTitle:[NSString stringWithFormat:@"●  %@",NSLocalizedString(@"Restore", nil)] forState:UIControlStateNormal];
    [restoreBtn addTarget:self action:@selector(onRestore:) forControlEvents:UIControlEventTouchUpInside];
    [_bonderCard addSubview:restoreBtn];
    
    _bonderClose = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 11, 11)];
    [_bonderClose setImage:[UIImage imageNamed:@"frame_off_set"] forState:UIControlStateNormal];
    [_bonderClose addTarget:self action:@selector(onCloseBonder) forControlEvents:UIControlEventTouchUpInside];
    [_bonderCard addSubview:_bonderClose];
    
    CGFloat bonderGap = 10;
    CGFloat typeWidth = (_bonderCard.frame.size.width - 30)/6;
    CGFloat typeHeight = typeWidth/75 * 90;
    
    _bonderTypeScroll = [[UIScrollView alloc] initWithFrame:CGRectMake((_bonderCard.frame.size.width - (typeWidth + bonderGap) * 5)/2, _bonderCard.frame.size.height * 0.6 - 30 - typeHeight - 5, (typeWidth + bonderGap) * 5, typeHeight + 5)];
    [_bonderTypeScroll setBackgroundColor:[UIColor clearColor]];
    [_bonderCard addSubview:_bonderTypeScroll];
    
    _bonderTypeSelectScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(_bonderTypeScroll.frame.origin.x, _bonderTypeScroll.frame.origin.y + _bonderTypeScroll.frame.size.height + 5, _bonderTypeScroll.frame.size.width, 5)];
    [_bonderTypeSelectScroll setBackgroundColor:[UIColor clearColor]];
    [_bonderCard addSubview:_bonderTypeSelectScroll];
    
    CGFloat bonderCardWidth = (_bonderTypeScroll.frame.size.width - bonderGap * 7)/7;
    CGFloat bonderCardHeight = bonderCardWidth/49 * 89;
    _bonderScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(_bonderTypeScroll.frame.origin.x, _bonderCard.frame.size.height * 0.6 - 5, _bonderTypeScroll.frame.size.width, bonderCardHeight)];
    [_bonderScroll setBackgroundColor:[UIColor clearColor]];
    [_bonderCard addSubview:_bonderScroll];
    
    _bonderSelectScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(_bonderScroll.frame.origin.x, _bonderScroll.frame.origin.y + _bonderScroll.frame.size.height + 5, _bonderScroll.frame.size.width, 5)];
    [_bonderSelectScroll setBackgroundColor:[UIColor clearColor]];
    [_bonderCard addSubview:_bonderSelectScroll];
    
    _selectType = [[UIImageView alloc] initWithImage:[themeManager themeImageWithName:@"frame_select"]];
    [_bonderTypeSelectScroll addSubview:_selectType];
    
    _selectBonder = [[UIImageView alloc] initWithImage:[themeManager themeImageWithName:@"frame_select_skin"]];
    [_bonderSelectScroll addSubview:_selectBonder];
    
    [self refreshScrollBonderType];
    [_bonderTypeSelectScroll setContentSize:CGSizeMake(_bonderTypeSelectScroll.contentSize.width, 0)];
    
    [_bonderTypeScroll addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [_bonderScroll addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    [self selectTypeAtIndex:_selectTypeIndex];
}

- (void)refreshBonderGroup{
    for (UIView *view in _bonderScroll.subviews) {
        if (view) {
            [view removeFromSuperview];
        }
    }
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    NSArray *bonders = [[_bonderList objectAtIndex:_selectTypeIndex] objectForKey:@"Bonders"];
    
    CGFloat position = 0;
    CGFloat gap = 10;
    int i = 1;
    
    for (NSDictionary *dict in bonders) {
        CGFloat bonderCardWidth = (_bonderScroll.frame.size.width - gap * 7)/7;
        CGFloat bonderCardHeight = bonderCardWidth/49 * 89;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(position, 0, bonderCardWidth, bonderCardHeight)];
        [imageView setImage:[themeManager themeImageWithName:[dict objectForKey:@"icon"]]];
        imageView.tag = i;
        [_bonderScroll addSubview:imageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBonder:)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tap];
        position += (imageView.frame.size.width + gap);
        i++;
    }
    [_bonderScroll setContentSize:CGSizeMake(position, 0)];
    [_bonderScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    [_bonderSelectScroll setContentSize:CGSizeMake(position, 0)];
    [self selectBonderAtIndex:_selectBonderIndex];
}

- (void)onTapBonder:(UIGestureRecognizer *)gestureRecognizer{
    if (_selectBonderIndex == gestureRecognizer.view.tag - 1) {
        return;
    }
    [self selectBonderAtIndex:gestureRecognizer.view.tag - 1];
}

- (void)selectBonderAtIndex:(NSInteger)index{
    _selectBonderIndex = index;
    UIImageView *imageView = [_bonderScroll viewWithTag:index + 1];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect temp = _selectBonder.frame;
        temp.origin.x = imageView.frame.origin.x;
        _selectBonder.frame = temp;
    }];
}

- (void)selectTypeAtIndex:(NSInteger)index{
    _selectTypeIndex = index;
    UIImageView *imageView = [_bonderTypeScroll viewWithTag:index + 1];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect temp = _selectType.frame;
        temp.origin.x = imageView.frame.origin.x;
        _selectType.frame = temp;
    }];
    [self refreshBonderGroup];
}

- (void)refreshScrollBonderType{
    for (UIView *view in [_bonderTypeScroll subviews]) {
        if (view) {
            [view removeFromSuperview];
        }
    }
    
    CGFloat position = 0;
    CGFloat gap = 10;
    int i = 0;
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    
    NSMutableArray <UIImage *> *types = [self getAllScrollType];
    for (UIImage *image in types) {
        if (image) {
            CGFloat imageWidth = (_bonderCard.frame.size.width - 30)/6;
            CGFloat imageHeight = imageWidth/75 * 90;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(position, 5, imageWidth, imageHeight)];
            [imageView setImage:image];
            imageView.tag = i + 1;
            [_bonderTypeScroll addSubview:imageView];
            BOOL isPurchase = [[[_bonderProductContent objectAtIndex:i] objectForKey:@"isPurchase"] boolValue];
            if (isPurchase == NO) {
                UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(imageWidth - 5, -3, 7, 7)];
                logo.tag = 999;
                [logo setImage:[themeManager themeImageWithName:@"PRO_frame"]];
                [imageView addSubview:logo];
            }
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBonderType:)];
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:tap];
            position += (imageView.frame.size.width + gap);
            i++;
        }
    }
    [_bonderTypeScroll setContentSize:CGSizeMake(position, 0)];
}

- (void)onTapBonderType:(UIGestureRecognizer *)gestureRecognizer{
    if ([@"0" isEqualToString:[[_bonderProductContent objectAtIndex:gestureRecognizer.view.tag - 1] objectForKey:@"isPurchase"]]) {
        _willSelectTypeIndex = gestureRecognizer.view.tag - 1;
        [self requestProductData:[[_bonderProductContent objectAtIndex:gestureRecognizer.view.tag - 1] objectForKey:@"ProductCode"]];
        return;
    }
    if (_selectTypeIndex == gestureRecognizer.view.tag - 1) {
        return;
    }
    _selectBonderIndex = 0;
    [self selectTypeAtIndex:gestureRecognizer.view.tag - 1];
}

- (NSMutableArray *)getAllScrollType{
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    NSMutableArray *result = [NSMutableArray new];
    for (NSDictionary *dict in _bonderList) {
        UIImage *image = [themeManager themeImageWithName:[dict objectForKey:@"Icon"]];
        [result addObject:image];
    }
    return result;
}

- (void)onCloseBonder{
    if (_alertBonderView) {
        [_bonderTypeScroll removeObserver:self forKeyPath:@"contentOffset"];
        [_bonderScroll removeObserver:self forKeyPath:@"contentOffset"];
        [_alertBonderView removeFromSuperview];
        _alertBonderView = nil;
    }
}

- (void)saveAlbumPhotoWithImage:(UIImage *)image{
    image = [image fixOrientation];
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    _selectFilter = [[[themeManager getThemeFilters] objectAtIndex:_selectFilterIndex] objectForKey:@"filter"];
    _selectTexture = [[[themeManager getThemeFilters] objectAtIndex:_selectFilterIndex] objectForKey:@"texture"];
    
    if ([@"" isEqualToString:_selectFilter] == NO) {
        image = [self createFilterWithImage:image andFilterName:_selectFilter];
    }
    
    image = [image fixOrientation];
    if ([@"" isEqualToString:_selectTexture] == NO) {
        image = [self createTextureWithImage:image andTextureName:_selectTexture];
    }
    
    if (_isAlbumDateOn) {
        NSDictionary *fontProperty = [themeManager getThemeFontProperty];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        FBGlowLabel *label = [[FBGlowLabel alloc] init];
        
        CGFloat value = imageView.frame.size.width > imageView.frame.size.height ? imageView.frame.size.width : imageView.frame.size.height;
        CGFloat base = value/1920;
        
        UIFont *font = [UIFont fontWithName:[fontProperty objectForKey:@"fontName"] size:[[fontProperty objectForKey:@"fontSize"] floatValue] * base];
        if (font == nil) {
            NSLog(@"没找到您配置的字体哦！！！");
            font = [UIFont fontWithName:@"DS-Digital" size:[[fontProperty objectForKey:@"fontSize"] floatValue] * base];
        }
        [label setFont:font];
        //描边
        NSArray *strokes = [[fontProperty objectForKey:@"strokeColor"] componentsSeparatedByString:@","];
        if (strokes!=nil && [strokes count] == 4) {
            label.strokeColor = [UIColor colorWithRed:[strokes[0] floatValue]/255 green:[strokes[1] floatValue]/255 blue:[strokes[2] floatValue]/255 alpha:[strokes[3] floatValue]];
        }else{
            label.strokeColor = [UIColor colorWithRed:0.937 green:0.337 blue:0.157 alpha:0.7];
        }
        
        label.strokeWidth = [[fontProperty objectForKey:@"strokeWidth"] floatValue];
        //发光
        label.layer.shadowRadius = [[fontProperty objectForKey:@"shadowRadius"] floatValue];
        
        NSArray *shadows = [[fontProperty objectForKey:@"shadowColor"] componentsSeparatedByString:@","];
        if (shadows!=nil && [shadows count] == 4) {
            label.layer.shadowColor = [UIColor colorWithRed:[shadows[0] floatValue]/255 green:[shadows[1] floatValue]/255 blue:[shadows[2] floatValue]/255 alpha:[shadows[3] floatValue]].CGColor;
        }else{
            label.layer.shadowColor = [UIColor colorWithRed:0.937 green:0.337 blue:0.157 alpha:1].CGColor;
        }
        
        label.layer.shadowOffset = CGSizeFromString([fontProperty objectForKey:@"shadowOffset"]);
        label.layer.shadowOpacity = [[fontProperty objectForKey:@"shadowOpacity"] floatValue];
        
        NSArray *fontColors = [[fontProperty objectForKey:@"fontColor"] componentsSeparatedByString:@","];
        if (fontColors!=nil && [fontColors count] == 4) {
            [label setTextColor:[UIColor colorWithRed:[fontColors[0] floatValue]/255 green:[fontColors[1] floatValue]/255 blue:[fontColors[2] floatValue]/255 alpha:[fontColors[3] floatValue]]];
        }else{
            [label setTextColor:[UIColor colorWithRed:0.937 green:0.337 blue:0.157 alpha:0.7]];
        }
        
        [label setText:[self getCurrentTimeWithDate:_selectDate]];
        [imageView addSubview:label];
        
        CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName: font}];
        
        CGSize adaptionSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
        
        CGSize gap = CGSizeFromString([fontProperty objectForKey:@"position"]);
        
        label.frame = CGRectMake(imageView.frame.size.width - adaptionSize.width - gap.width*base, imageView.frame.size.height - gap.height*base, adaptionSize.width, adaptionSize.height);
        
        UIImage *resultImage = [self convertViewToImage:imageView andScale:image.scale];
        image = resultImage;
    }
    
    if (_isAlbumBonderOn){
        BOOL isBonderRotate = NO;
        if(image.size.height > image.size.width){
            image = [image imageRotatedByDegrees:270];
            isBonderRotate = YES;
        }
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        NSString *bonderContent = [[[[_bonderList objectAtIndex:_selectTypeIndex] objectForKey:@"Bonders"] objectAtIndex:_selectBonderIndex] objectForKey:@"bonder"];
        NSArray *bonders = [bonderContent componentsSeparatedByString:@","];
        int num = [self getRandomNumber:0 to:(int)([bonders count] - 1)];
        UIImage *bonderImage = [UIImage imageNamed:[bonders objectAtIndex:num]];
        [bonderImage drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (isBonderRotate) {
            newImage = [newImage imageRotatedByDegrees:90];
        }
        image = newImage;
    }
    [self onSaveImage:image];
}

/**同步方式保存图片到系统的相机胶卷中---返回的是当前保存成功后相册图片对象集合*/
-(void)syncSaveImage:(UIImage *)image{
    __block NSString *createdAssetID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        createdAssetID = [PHAssetChangeRequest             creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showErrorMessage:NSLocalizedString(@"SaveError", nil)];
        }else{
            PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil];
            if (assets == nil)
            {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showErrorMessage:NSLocalizedString(@"SaveError", nil)];
                return;
            }
            
            //2 拥有自定义相册（与 APP 同名，如果没有则创建）--调用刚才的方法
            PHAssetCollection *assetCollection = [self getAssetCollectionWithAppNameAndCreateIfNo];
            if (assetCollection == nil) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showErrorMessage:NSLocalizedString(@"CreateAlbumError", nil)];
                return;
            }
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                //--告诉系统，要操作哪个相册
                PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                //--添加图片到自定义相册--追加--就不能成为封面了
                //--[collectionChangeRequest addAssets:assets];
                //--插入图片到自定义相册--插入--可以成为封面
                [collectionChangeRequest insertAssets:assets atIndexes:[NSIndexSet indexSetWithIndex:0]];
            } error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccessMessage:NSLocalizedString(@"SaveSuccess", nil)];
            });
        }
    }];
}

/**拥有与 APP 同名的自定义相册--如果没有则创建*/
-(PHAssetCollection *)getAssetCollectionWithAppNameAndCreateIfNo
{
    //1 获取以 APP 的名称
    NSString *title = [NSBundle mainBundle].infoDictionary[(__bridge NSString *)kCFBundleNameKey];
    //2 获取与 APP 同名的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        //遍历
        if ([collection.localizedTitle isEqualToString:title]) {
            //找到了同名的自定义相册--返回
            return collection;
        }
    }
    
    //说明没有找到，需要创建
    NSError *error = nil;
    __block NSString *createID = nil; //用来获取创建好的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //发起了创建新相册的请求，并拿到ID，当前并没有创建成功，待创建成功后，通过 ID 来获取创建好的自定义相册
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        createID = request.placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        [MBProgressHUD showErrorMessage:NSLocalizedString(@"CreateAlbumError", nil)];
        return nil;
    }else{
        //通过 ID 获取创建完成的相册 -- 是一个数组
        return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createID] options:nil].firstObject;
    }
}

- (void)directionChange:(TgDirection)direction {
    switch (direction) {
        case TgDirectionPortrait:
        _deviceOrientation = UIDeviceOrientationPortrait;
        break;
        
        case TgDirectionDown:
        _deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
        break;
        
        case TgDirectionRight:
        _deviceOrientation = UIDeviceOrientationLandscapeRight;
        break;
        
        case TgDirectionleft:
        _deviceOrientation = UIDeviceOrientationLandscapeLeft;
        break;
        
        default:
        break;
    }
}

- (IBAction)onPress:(id)sender{
    if(_isAlbumOn){
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        if (PHAuthorizationStatusAuthorized == authStatus) {
            BLImagePickerViewController *imgVc = [[BLImagePickerViewController alloc]init];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:imgVc];
            imgVc.imageClipping = YES;
            imgVc.showCamera = NO;
            imgVc.navColor = [UIColor blackColor];
            imgVc.maxNum = 1;
            [imgVc setFinishedBlock:^(NSArray<UIImage *> *resultAry, NSArray<PHAsset *> *assetsArry, UIImage *editedImage) {
                if(editedImage){
                    [self saveAlbumPhotoWithImage:editedImage];
                }else{
                    [MBProgressHUD showErrorMessage:NSLocalizedString(@"EditError", nil)];
                }
            }];
            [imgVc setCancleBlock:^(NSString *cancleStr) {
                [nav popViewControllerAnimated:YES];
            }];
            [self presentViewController:nav animated:YES completion:nil];
        }else{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
            }];
        }
        return;
    }
    if([@"0" isEqualToString:[[_productContents objectAtIndex:_selectCameraIndex] objectForKey:@"isPurchase"]]){
        if ([SKPaymentQueue canMakePayments]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Tip", nil) message:NSLocalizedString(@"ShouldPay", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"BuySingle", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self requestProductData:[[_productContents objectAtIndex:_selectCameraIndex] objectForKey:@"ProductCode"]];
            }];
            UIAlertAction *allAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"BuyAll", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self requestProductData:ALL_PRODUCT_ID];
            }];
            
            [alertController addAction:okAction];
            [alertController addAction:allAction];
            [alertController addAction:cancelAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
            NSLog(@"允许程序内付费购买");
        }
        else
        {
            NSLog(@"不允许程序内付费购买");
            [MBProgressHUD showErrorMessage:NSLocalizedString(@"NoPermission", nil)];
        }
        return;
    }
    
    AVAuthorizationStatus authorStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authorStatus == AVAuthorizationStatusAuthorized){
        if (_isAutoSave) {
            PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
            if (PHAuthorizationStatusAuthorized == authStatus) {
                [self takePhoto];
            }else{
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    
                }];
            }
        }else{
            [self takePhoto];
        }
        
    }else{
        [MBProgressHUD showErrorMessage:NSLocalizedString(@"NoAccessCamera", nil)];
    }
}

-(void)takePhoto{
    //播放音效
    SystemSoundID soundID;
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &soundID);
    //播放短音频
    AudioServicesPlaySystemSound(soundID);
    AudioServicesDisposeSystemSoundID(soundID);
    
    [MBProgressHUD showActivityMessageInWindow:NSLocalizedString(@"Process", nil)];
    AVCaptureConnection *connect = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if(connect.supportsVideoMirroring && [@"Back" isEqualToString:_status] == NO){
        connect.videoMirrored = YES;
    }
    
    if([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait){
        connect.videoOrientation = AVCaptureVideoOrientationPortrait;
    }else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown){
        connect.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft){
        connect.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }else{
        connect.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
    
    NSLog(@"拍摄方向:%zd",connect.videoOrientation);
    if(!connect)
    {
        NSLog(@"拍照失败");
        [MBProgressHUD hideHUD];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connect completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if(imageDataSampleBuffer==NULL){
            [MBProgressHUD hideHUD];
            return;
        }
        [weakSelf savePhoto:imageDataSampleBuffer];
    }];
}

- (void)savePhoto:(CMSampleBufferRef )imageDataSampleBuffer{
    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
    UIImage *image = [UIImage imageWithData:imageData];
    [self savePhotoWithImage:image];
}

- (void)savePhotoWithImage:(UIImage *)image{
    UIDeviceOrientation orinetation = [[UIDevice currentDevice] orientation];
    NSLog(@"%zd",_deviceOrientation);
    UIImageOrientation defaultOrientation = image.imageOrientation;
    image = [image fixOrientation];
    
    BOOL isLockScreen = NO;
    if(orinetation != _deviceOrientation || (_deviceOrientation == UIDeviceOrientationPortrait && orinetation == UIDeviceOrientationPortrait && defaultOrientation == UIImageOrientationRight)){
        isLockScreen = YES;
    }
    
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    _selectFilter = [[[themeManager getThemeFilters] objectAtIndex:_selectFilterIndex] objectForKey:@"filter"];
    _selectTexture = [[[themeManager getThemeFilters] objectAtIndex:_selectFilterIndex] objectForKey:@"texture"];
    
    if ([@"" isEqualToString:_selectFilter] == NO) {
        image = [self createFilterWithImage:image andFilterName:_selectFilter];
    }
    
    image = [image fixOrientation];
    if ([@"" isEqualToString:_selectTexture] == NO) {
        image = [self createTextureWithImage:image andTextureName:_selectTexture];
    }
    
    if (_isDateOn) {
        NSDictionary *fontProperty = [themeManager getThemeFontProperty];
        if(isLockScreen){
            if (_deviceOrientation == UIDeviceOrientationPortraitUpsideDown){
                image = [image imageRotatedByDegrees:180];
            }else if (_deviceOrientation == UIDeviceOrientationLandscapeLeft){
                image = [image imageRotatedByDegrees:270];
            }else if (_deviceOrientation == UIDeviceOrientationLandscapeRight){
                image = [image imageRotatedByDegrees:90];
            }
        }else{
            if(defaultOrientation == UIImageOrientationDown){
                image = [image imageRotatedByDegrees:270];
            }else if (defaultOrientation == UIImageOrientationLeft){
                image = [image imageRotatedByDegrees:180];
            }else if (defaultOrientation == UIImageOrientationUp){
                image = [image imageRotatedByDegrees:90];
            }else if(defaultOrientation == UIImageOrientationUpMirrored){
                image = [image imageRotatedByDegrees:270];
            }else if (defaultOrientation == UIImageOrientationRightMirrored){
                image = [image imageRotatedByDegrees:180];
            }else if (defaultOrientation == UIImageOrientationDownMirrored){
                image = [image imageRotatedByDegrees:90];
            }
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        FBGlowLabel *label = [[FBGlowLabel alloc] init];
        
        CGFloat value = imageView.frame.size.width > imageView.frame.size.height ? imageView.frame.size.width : imageView.frame.size.height;
        CGFloat base = value/1920;
        
        UIFont *font = [UIFont fontWithName:[fontProperty objectForKey:@"fontName"] size:[[fontProperty objectForKey:@"fontSize"] floatValue] * base];
        if (font == nil) {
            NSLog(@"没找到您配置的字体哦！！！");
            font = [UIFont fontWithName:@"DS-Digital" size:[[fontProperty objectForKey:@"fontSize"] floatValue] * base];
        }
        [label setFont:font];
        //描边
        NSArray *strokes = [[fontProperty objectForKey:@"strokeColor"] componentsSeparatedByString:@","];
        if (strokes!=nil && [strokes count] == 4) {
            label.strokeColor = [UIColor colorWithRed:[strokes[0] floatValue]/255 green:[strokes[1] floatValue]/255 blue:[strokes[2] floatValue]/255 alpha:[strokes[3] floatValue]];
        }else{
            label.strokeColor = [UIColor colorWithRed:0.937 green:0.337 blue:0.157 alpha:0.7];
        }
        
        label.strokeWidth = [[fontProperty objectForKey:@"strokeWidth"] floatValue];
        //发光
        label.layer.shadowRadius = [[fontProperty objectForKey:@"shadowRadius"] floatValue];
        
        NSArray *shadows = [[fontProperty objectForKey:@"shadowColor"] componentsSeparatedByString:@","];
        if (shadows!=nil && [shadows count] == 4) {
            label.layer.shadowColor = [UIColor colorWithRed:[shadows[0] floatValue]/255 green:[shadows[1] floatValue]/255 blue:[shadows[2] floatValue]/255 alpha:[shadows[3] floatValue]].CGColor;
        }else{
            label.layer.shadowColor = [UIColor colorWithRed:0.937 green:0.337 blue:0.157 alpha:1].CGColor;
        }
        
        label.layer.shadowOffset = CGSizeFromString([fontProperty objectForKey:@"shadowOffset"]);
        label.layer.shadowOpacity = [[fontProperty objectForKey:@"shadowOpacity"] floatValue];
        
        NSArray *fontColors = [[fontProperty objectForKey:@"fontColor"] componentsSeparatedByString:@","];
        if (fontColors!=nil && [fontColors count] == 4) {
            [label setTextColor:[UIColor colorWithRed:[fontColors[0] floatValue]/255 green:[fontColors[1] floatValue]/255 blue:[fontColors[2] floatValue]/255 alpha:[fontColors[3] floatValue]]];
        }else{
            [label setTextColor:[UIColor colorWithRed:0.937 green:0.337 blue:0.157 alpha:0.7]];
        }
        
        [label setText:[self getCurrentTimeWithDate:_selectDate]];
        [imageView addSubview:label];
        
        CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName: font}];
        
        CGSize adaptionSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
        
        CGSize gap = CGSizeFromString([fontProperty objectForKey:@"position"]);
        
        label.frame = CGRectMake(imageView.frame.size.width - adaptionSize.width - gap.width*base, imageView.frame.size.height - gap.height*base, adaptionSize.width, adaptionSize.height);
        
        UIImage *resultImage = [self convertViewToImage:imageView andScale:image.scale];
        image = resultImage;
    }
    
    if (_isBonderOn){
        if(isLockScreen){
            if (_deviceOrientation == UIDeviceOrientationLandscapeLeft){
                image = [image imageRotatedByDegrees:270];
            }else if (_deviceOrientation == UIDeviceOrientationLandscapeRight){
                image = [image imageRotatedByDegrees:90];
            }else if (_deviceOrientation == UIDeviceOrientationPortraitUpsideDown){
                image = [image imageRotatedByDegrees:90];
            }else if (_deviceOrientation == UIDeviceOrientationPortrait){
                image = [image imageRotatedByDegrees:270];
            }
        }else{
            if(defaultOrientation == UIImageOrientationDown || defaultOrientation == UIImageOrientationRight){
                image = [image imageRotatedByDegrees:270];
            }else if (defaultOrientation == UIImageOrientationLeft || defaultOrientation == UIImageOrientationUp){
                image = [image imageRotatedByDegrees:90];
            }else if(defaultOrientation == UIImageOrientationUpMirrored || defaultOrientation == UIImageOrientationLeftMirrored){
                image = [image imageRotatedByDegrees:270];
            }else if (defaultOrientation == UIImageOrientationDownMirrored || defaultOrientation == UIImageOrientationRightMirrored){
                image = [image imageRotatedByDegrees:90];
            }
        }
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        NSString *bonderContent = [[[[_bonderList objectAtIndex:_selectTypeIndex] objectForKey:@"Bonders"] objectAtIndex:_selectBonderIndex] objectForKey:@"bonder"];
        NSArray *bonders = [bonderContent componentsSeparatedByString:@","];
        int num = [self getRandomNumber:0 to:(int)([bonders count] - 1)];
        UIImage *bonderImage = [UIImage imageNamed:[bonders objectAtIndex:num]];
        [bonderImage drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if(newImage){
            if(isLockScreen){
                if([@"Back" isEqualToString:_status] && (_deviceOrientation == UIDeviceOrientationPortrait || _deviceOrientation == UIDeviceOrientationPortraitUpsideDown)){
                    newImage = [newImage imageRotatedByDegrees:90];
                }else if (_deviceOrientation == UIDeviceOrientationPortrait || _deviceOrientation == UIDeviceOrientationPortraitUpsideDown){
                    newImage = [newImage imageRotatedByDegrees:90];
                }
            }else{
                if(defaultOrientation == UIImageOrientationLeft || defaultOrientation == UIImageOrientationRight){
                    newImage = [newImage imageRotatedByDegrees:90];
                }else if (defaultOrientation == UIImageOrientationLeftMirrored || defaultOrientation == UIImageOrientationRightMirrored){
                    newImage = [newImage imageRotatedByDegrees:90];
                }
            }
            
            image = newImage;
        }
    }
    
    if (!_isBonderOn && !_isDateOn) {
        if (_deviceOrientation == UIDeviceOrientationLandscapeRight || _deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
            image = [image imageRotatedByDegrees:180];
        }
    }
    
    [self onSaveImage:image];
}

- (void)onSaveImage:(UIImage *)image{
    NSString *fileName = [self getFileName];
    NSLog(@"%@",fileName);
    NSString *path_document = NSHomeDirectory();
    //设置一个图片的存储路径
    NSString *imagePath = [path_document stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@.png",fileName]];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    UIImage *bigImage = [[UIImage alloc] initWithCGImage:image.CGImage];
    if (image.size.width > image.size.height) {
        bigImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeft];
    }
    [UIImagePNGRepresentation(bigImage) writeToFile:imagePath atomically:YES];
    
    if(_isAutoSave){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self syncSaveImage:image];
        });
    }
    
    NSString *thumbPath = [path_document stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@.jpg",fileName]];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    
    if(image.size.height > image.size.width){
        image = [image imageRotatedByDegrees:270];
    }
    
    BOOL isSaved = [UIImageJPEGRepresentation(image, 0) writeToFile:thumbPath atomically:YES];
    
    if (!_isAutoSave){
        if (isSaved) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccessMessage:NSLocalizedString(@"SaveSuccess", nil)];
        }else{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showErrorMessage:NSLocalizedString(@"SaveError", nil)];
        }
    }
    
    if ([_imageLists count] == 0) {
        [_imageLists addObject:fileName];
    }else{
        [_imageLists insertObject:fileName atIndex:0];
    }
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(onSaveImageCache) object:nil];
    [thread start];
}

- (void)onSaveImageCache{
    NSString *dataString = [_imageLists objectToJSONString];
    [[NSUserDefaults standardUserDefaults] setObject:dataString forKey:@"ClassicImage_FileName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getFileName{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYYMMddHHmmssSSS"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *fileName = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    return fileName;
}

-(int)getRandomNumber:(int)from to:(int)to
{
    int randomNum = (int)(from + (arc4random() % (to - from + 1)));
    NSLog(@"随机到的数值：%d",randomNum);
    return randomNum;
}

- (UIImage *)createFilterWithImage:(UIImage *)image andFilterName:(NSString *)filterName{
    NSArray *filters = [filterName componentsSeparatedByString:@","];
    int num = [self getRandomNumber:0 to:(int)([filters count] - 1)];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    NSString *filterString = [filters objectAtIndex:num];
    if ([filterString hasSuffix:@".acv"]) {
        PhotoXAcvFilter *acvFilter = [[PhotoXAcvFilter alloc]initWithACVData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filterString ofType:nil]]];
        acvFilter.mix = 1;
        [pic addTarget:acvFilter];
        [acvFilter useNextFrameForImageCapture];
        [pic processImage];
        UIImage *newImage = [acvFilter imageFromCurrentFramebuffer];
        if (newImage) {
            return newImage;
        }
    }else{
        GPUImageFilter *outFilter = [[[NSClassFromString(filterString) class] alloc] init];
        [pic addTarget:outFilter];
        [outFilter useNextFrameForImageCapture];
        [pic processImage];
        UIImage *newImage = [outFilter imageFromCurrentFramebuffer];
        if(newImage){
            return newImage;
        }
    }
    
    return image;
}

- (UIImage *)createTextureWithImage:(UIImage *)image andTextureName:(NSString *)textureName{
    NSArray *textures = [textureName componentsSeparatedByString:@","];
    int num = [self getRandomNumber:0 to:(int)([textures count] - 1)];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    UIImage *textureImage = [UIImage imageNamed:[textures objectAtIndex:num]];
    HCTestFilter *texture = [[HCTestFilter alloc] initWithTextureImage:textureImage];
    [pic addTarget:texture];
    [texture useNextFrameForImageCapture];
    [pic processImage];
    UIImage *newImage = [texture imageFromCurrentFramebuffer];
    if(image.size.width == newImage.size.height){
        newImage = [newImage imageRotatedByDegrees:270];
    }
    if (newImage) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(newImage.size.width, newImage.size.height), NO, newImage.scale);
        [image drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
        [newImage drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height) blendMode:kCGBlendModePlusLighter alpha:1.0];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultImage;
    }
    return image;
}

/**拥有与 APP 同名的自定义相册--如果没有则创建*/
-(PHAssetCollection *)getAssetCollectionWithAppNameAndCreateId
{
    //1 获取以 APP 的名称
    NSString *title = [NSBundle mainBundle].infoDictionary[(__bridge NSString *)kCFBundleNameKey];
    //2 获取与 APP 同名的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        //遍历
        if ([collection.localizedTitle isEqualToString:title]) {
            //找到了同名的自定义相册--返回
            return collection;
        }
    }
    
    //说明没有找到，需要创建
    NSError *error = nil;
    __block NSString *createID = nil; //用来获取创建好的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //发起了创建新相册的请求，并拿到ID，当前并没有创建成功，待创建成功后，通过 ID 来获取创建好的自定义相册
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        createID = request.placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        NSLog(@"创建失败");
        return nil;
    }else{
        NSLog(@"创建成功");
        //通过 ID 获取创建完成的相册 -- 是一个数组
        if (createID) {
            PHFetchResult<PHAssetCollection *> *result = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createID] options:nil];
            return result.firstObject;
        }
        return nil;
    }
}

- (void)onSave:(UIImage *)image
{
    //(1) 获取当前的授权状态
    PHAuthorizationStatus lastStatus = [PHPhotoLibrary authorizationStatus];
    
    //(2) 请求授权
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        //回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            if(status == PHAuthorizationStatusDenied) //用户拒绝（可能是之前拒绝的，有可能是刚才在系统弹框中选择的拒绝）
            {
                if (lastStatus == PHAuthorizationStatusNotDetermined) {
                    //说明，用户之前没有做决定，在弹出授权框中，选择了拒绝
                    [MBProgressHUD showErrorMessage:NSLocalizedString(@"SaveError", nil)];
                    return;
                }
                // 说明，之前用户选择拒绝过，现在又点击保存按钮，说明想要使用该功能，需要提示用户打开授权
                [MBProgressHUD showErrorMessage:NSLocalizedString(@"NoAccessAlbum", nil)];
            }
            else if(status == PHAuthorizationStatusAuthorized) //用户允许
            {
                //保存图片---调用上面封装的方法
                [self saveImageToCustomAblumWithImage:image];
            }
            else if (status == PHAuthorizationStatusRestricted)
            {
                [MBProgressHUD showErrorMessage:NSLocalizedString(@"NoAccessAlbum", nil)];
            }
        });
    }];
}

/**同步方式保存图片到系统的相机胶卷中---返回的是当前保存成功后相册图片对象集合*/
-(PHFetchResult<PHAsset *> *)syncSaveImageWithPhotos:(UIImage *)image
{
    //--1 创建 ID 这个参数可以获取到图片保存后的 asset对象
    __block NSString *createdAssetID = nil;
    
    //--2 保存图片
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //----block 执行的时候还没有保存成功--获取占位图片的 id，通过 id 获取图片---同步
        createdAssetID = [PHAssetChangeRequest             creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    
    //--3 如果失败，则返回空
    if (error) {
        return nil;
    }
    
    //--4 成功后，返回对象
    //获取保存到系统相册成功后的 asset 对象集合，并返回
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil];
    return assets;
    
}

/**将图片保存到自定义相册中*/
-(void)saveImageToCustomAblumWithImage:(UIImage *)image
{
    //1 将图片保存到系统的【相机胶卷】中---调用刚才的方法
    PHFetchResult<PHAsset *> *assets = [self syncSaveImageWithPhotos:image];
    if (assets == nil)
    {
        [MBProgressHUD showErrorMessage:NSLocalizedString(@"SaveError", nil)];
        return;
    }
    
    //2 拥有自定义相册（与 APP 同名，如果没有则创建）--调用刚才的方法
    PHAssetCollection *assetCollection = [self getAssetCollectionWithAppNameAndCreateId];
    if (assetCollection == nil) {
        [MBProgressHUD showErrorMessage:NSLocalizedString(@"CreateAlbumError", nil)];
        return;
    }
    
    //3 将刚才保存到相机胶卷的图片添加到自定义相册中 --- 保存带自定义相册--属于增的操作，需要在PHPhotoLibrary的block中进行
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //--告诉系统，要操作哪个相册
        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        //--添加图片到自定义相册--追加--就不能成为封面了
        //--[collectionChangeRequest addAssets:assets];
        //--插入图片到自定义相册--插入--可以成为封面
        [collectionChangeRequest insertAssets:assets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    if (error) {
        [MBProgressHUD showErrorMessage:NSLocalizedString(@"SaveError", nil)];
        return;
    }
    [MBProgressHUD showSuccessMessage:NSLocalizedString(@"SaveSuccess", nil)];
}

- (UIImage*)convertViewToImage:(UIImageView *)view andScale:(CGFloat)scale{
    CGSize size = view.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *resultImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:view.image.imageOrientation];
    return resultImage;
}

//获取当地时间
- (NSString *)getDateTimeWithDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateType = [[NSUserDefaults standardUserDefaults] objectForKey:kDateType];
    if ([@"1" isEqualToString:dateType]) {
        [formatter setDateFormat:@"MM/dd/yy"];
    }else if ([@"2" isEqualToString:dateType]){
        [formatter setDateFormat:@"dd/MM/yy"];
    }else{
        [formatter setDateFormat:@"yy/MM/dd"];
    }
    
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}

//获取当地时间
- (NSString *)getCurrentTimeWithDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateType = [[NSUserDefaults standardUserDefaults] objectForKey:kDateType];
    NSMutableString *whiteSpace = [NSMutableString new];
    NSDictionary *fontProperty = [[ThemeManager sharedThemeManager] getThemeFontProperty];
    NSInteger count = [[fontProperty objectForKey:@"distance"] integerValue];
    for (int i = 0; i < count; i++) {
        [whiteSpace appendString:@" "];
    }
    if ([@"1" isEqualToString:dateType]) {
        [formatter setDateFormat:[NSString stringWithFormat:@"MM%@dd%@yy",whiteSpace,whiteSpace]];
    }else if ([@"2" isEqualToString:dateType]){
        [formatter setDateFormat:[NSString stringWithFormat:@"dd%@MM%@yy",whiteSpace,whiteSpace]];
    }else{
        [formatter setDateFormat:[NSString stringWithFormat:@"yy%@MM%@dd",whiteSpace,whiteSpace]];
    }
    
    NSString *dateTime = [formatter stringFromDate:date];
    NSString *result = [NSString stringWithFormat:@"' %@",dateTime];
    return result;
}

- (IBAction)onChange:(id)sender{
    //切换至前置摄像头
    if([@"Back" isEqualToString:_status])
    {
        _status = @"Front";
        AVCaptureDevice *device;
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for(AVCaptureDevice *tmp in devices)
        {
            if(tmp.position == AVCaptureDevicePositionFront)
            device = tmp;
        }
        [_session beginConfiguration];
        [_session removeInput:self.videoInput];
        self.videoInput = nil;
        self.videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:device error:nil];
        if([_session canAddInput:self.videoInput])
        [_session addInput:self.videoInput];
        [_session commitConfiguration];
    }
    //切换至后置摄像头
    else
    {
        _status = @"Back";
        AVCaptureDevice *device;
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for(AVCaptureDevice *tmp in devices)
        {
            if(tmp.position == AVCaptureDevicePositionBack)
            device = tmp;
        }
        [_session beginConfiguration];
        [_session removeInput:self.videoInput];
        self.videoInput = nil;
        self.videoInput=[[AVCaptureDeviceInput alloc]initWithDevice:device error:nil];
        if([_session canAddInput:self.videoInput])
        [_session addInput:self.videoInput];
        [_session commitConfiguration];
    }
    if (_isBigModel) {
        [self refreshBigModeLayout];
    }else{
        [self refreshCameraLayout];
    }
}

- (void)refreshCameraLayout{
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    NSString *imageName = [NSString stringWithFormat:@"Camera_%@_%@",_status,_resolution];
    UIImage *image = [themeManager themeImageWithName:imageName];
    if (image == nil) {
        image = [themeManager themeImageWithName:[NSString stringWithFormat:@"Camera_%@_1334X750",_status]];
    }
    [_cameraSkin setImage:image];
    
    NSDictionary *positions = [themeManager themePositionsWithStatus:_status andResolution:_resolution];
    
    [_settingBtn setFrame: [self getFrameWithString:[positions objectForKey:@"Setting"]]];
    [_settingBtn setImage:[themeManager themeImageWithName:@"set"] forState:UIControlStateNormal];
    
    [_flashBtn setFrame: [self getFrameWithString:[positions objectForKey:@"Flashlight"]]];
    if (_isAutoFlash) {
        [_flashBtn setImage:[themeManager themeImageWithName:@"Flash_automatic"] forState:UIControlStateNormal];
    }else{
        [_flashBtn setImage:[themeManager themeImageWithName:@"Flash_off"] forState:UIControlStateNormal];
    }
    
    [_dateBtn setFrame: [self getFrameWithString:[positions objectForKey:@"Date"]]];
    if (_isDateOn) {
        [_dateBtn setImage:[themeManager themeImageWithName:@"Date_watermark_on"] forState:UIControlStateNormal];
    }else if(_isBonderOn){
        [_dateBtn setImage:[themeManager themeImageWithName:@"Date_frame"] forState:UIControlStateNormal];
    }else{
        [_dateBtn setImage:[themeManager themeImageWithName:@"Date_watermark_off"] forState:UIControlStateNormal];
    }
    
    [_pressBtn setFrame: [self getFrameWithString:[positions objectForKey:@"Press"]]];
    [_pressBtn setImage:[themeManager themeImageWithName:@"cam_button"] forState:UIControlStateNormal];
    [_pressBtn setImage:[themeManager themeImageWithName:@"cam_button_press"] forState:UIControlStateHighlighted];
    
    [self.previewLayer setFrame: [self getFrameWithString:[positions objectForKey:@"Shot"]]];
    [_clearView setFrame: [self getFrameWithString:[positions objectForKey:@"Shot"]]];
    
    [_changeBtn setFrame: [self getFrameWithString:[positions objectForKey:@"Change"]]];
    [_changeBtn setImage:[themeManager themeImageWithName:@"Camera_changes"] forState:UIControlStateNormal];
    
    [_albumBtn setFrame: [self getFrameWithString:[positions objectForKey:@"Album"]]];
    [_albumBtn setImage:[themeManager themeImageWithName:@"album_button"] forState:UIControlStateNormal];
}

- (CGRect)getFrameWithString:(NSString *)string{
    CGRect frame = CGRectFromString([NSString stringWithFormat:@"{%@}",string]);
    CGRect result = CGRectMake(frame.origin.x/_scale*_factor, frame.origin.y/_scale*_factor, frame.size.width/_scale*_factor, frame.size.height/_scale*_factor);
    return result;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_deviceMotion stop];
    if (self.session) {
        [self.session stopRunning];
    }
}

@end


