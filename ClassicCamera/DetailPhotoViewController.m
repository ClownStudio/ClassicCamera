//
//  DetailPhotoViewController.m
//  ClassicCamera
//
//  Created by 张文洁 on 2017/12/22.
//  Copyright © 2017年 JamStudio. All rights reserved.
//

#import "DetailPhotoViewController.h"
#import <Photos/Photos.h>
#import <MBProgressHUD+JDragon.h>
#import "ThemeManager.h"
#import "NotificationMacro.h"
#import "PhotoEditViewController.h"

@interface DetailPhotoViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@end

@implementation DetailPhotoViewController{
    NSString *_resolution;
    NSInteger _screenWidth;
    NSInteger _screenHeight;
    NSInteger _scale;
    NSDictionary *_positions;
    UICollectionView *_largeCollectionView;
    CGFloat _factor;
    CGFloat _photoWidth;
    CGFloat _photoHeight;
    UIButton *_backBtn;
    UIButton *_cameraBtn;
    UIButton *_saveBtn;
    UIButton *_deleteBtn;
    UIButton *_editBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _scale = [UIScreen mainScreen].scale;
    _resolution = [NSString stringWithFormat:@"%dX%d",(int)(_screenWidth*_scale),(int)(_screenHeight*_scale)];
    
    ThemeManager * themeManager = [ThemeManager sharedThemeManager];
    UIImage *image = [themeManager themeImageWithName:[NSString stringWithFormat:@"Camera_Album_%@",_resolution]];
    if (image == nil) {
        image = [themeManager themeImageWithName:@"Camera_Album_1334X750"];
    }
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [background setImage:image];
    [self.view addSubview:background];
    
    if ([@"2001X1125" isEqualToString:_resolution]) {
        _factor = 1.5;
    }else{
        _factor = 1;
    }
    
    NSString *albumPath = [[NSBundle mainBundle] pathForResource:@"album" ofType:@"plist"];
    NSDictionary *albumList = [NSDictionary dictionaryWithContentsOfFile:albumPath];
    _positions = [albumList objectForKey:_resolution];
    if (_positions == nil) {
        _positions = [albumList objectForKey:@"1334X750"];
    }
    
    CGRect contentFrame = [self getFrameWithString:[_positions objectForKey:@"content"]];
    _photoWidth = contentFrame.size.width;
    _photoHeight = contentFrame.size.width/16*9;
    
    _backBtn = [[UIButton alloc] initWithFrame:[self getFrameWithString:[_positions objectForKey:@"largeBack"]]];
    [_backBtn setImage:[themeManager themeImageWithName:@"return"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backBtn];
    
    _cameraBtn = [[UIButton alloc] initWithFrame:[self getFrameWithString:[_positions objectForKey:@"camera"]]];
    [_cameraBtn setImage:[themeManager themeImageWithName:@"camera"] forState:UIControlStateNormal];
    [_cameraBtn addTarget:self action:@selector(onCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cameraBtn];
    
    _saveBtn = [[UIButton alloc] initWithFrame:[self getFrameWithString:[_positions objectForKey:@"save"]]];
    [_saveBtn setImage:[themeManager themeImageWithName:@"save"] forState:UIControlStateNormal];
    [_saveBtn addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveBtn];
    
    _deleteBtn = [[UIButton alloc] initWithFrame:[self getFrameWithString:[_positions objectForKey:@"delete"]]];
    [_deleteBtn setImage:[themeManager themeImageWithName:@"delete"] forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(onDelete:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteBtn];
    
    _editBtn = [[UIButton alloc] initWithFrame:[self getFrameWithString:[_positions objectForKey:@"edit"]]];
    [_editBtn setImage:[themeManager themeImageWithName:@"edit"] forState:UIControlStateNormal];
    [_editBtn addTarget:self action:@selector(onEdit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_editBtn];
    
    UICollectionViewFlowLayout *largeLayout = [[UICollectionViewFlowLayout alloc] init];
    [largeLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [largeLayout setItemSize:CGSizeMake(_photoWidth, _photoHeight)];
    [largeLayout setMinimumLineSpacing:0];
    _largeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _photoWidth, _photoHeight) collectionViewLayout:largeLayout];
    if (@available(iOS 11.0, *)) {
        _largeCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _largeCollectionView.bounces = NO;
    [_largeCollectionView registerClass:[LargePhotoCollectionViewCell class] forCellWithReuseIdentifier:@"LargePhotoCell"];
    [_largeCollectionView setBackgroundColor:[UIColor blackColor]];
    [_largeCollectionView setPagingEnabled:YES];
    _largeCollectionView.delegate = self;
    _largeCollectionView.dataSource = self;
    _largeCollectionView.center = self.view.center;
    [self.view addSubview:_largeCollectionView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_largeCollectionView reloadData];
    if (self.selectedIndex != 0) {
        [_largeCollectionView setContentOffset:CGPointMake((int)_photoWidth*self.selectedIndex, 0)];
        self.selectedIndex = 0;
    }
}

-(IBAction)onEdit:(id)sender{
    NSLog(@"%f  %f",_largeCollectionView.contentOffset.x,_photoWidth);
    int page = roundf(_largeCollectionView.contentOffset.x/_photoWidth);
    NSString *fileName = [self.photoList objectAtIndex:page];
    PhotoEditViewController *photoEditViewController = [[PhotoEditViewController alloc] init];
    photoEditViewController.selectedImageName = fileName;
    [self.navigationController pushViewController:photoEditViewController animated:YES];
}

-(IBAction)onSave:(id)sender{
    int page = roundf(_largeCollectionView.contentOffset.x/_photoWidth);
    NSString *path_document = NSHomeDirectory();
    NSString *fileName = [self.photoList objectAtIndex:page];
    NSString *imagePath = [path_document stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@.png",fileName]];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Tip", nil) message:NSLocalizedString(@"SelectSaveVersion", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Small", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width * [UIScreen mainScreen].scale/3, image.size.height * [UIScreen mainScreen].scale/3));
        [image drawInRect:CGRectMake(0, 0,image.size.width * [UIScreen mainScreen].scale/3, image.size.height * [UIScreen mainScreen].scale/3)];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self savePhoto:resultImage];
    }];
    
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Medium", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width * [UIScreen mainScreen].scale/3 *2, image.size.height * [UIScreen mainScreen].scale/3 *2));
        [image drawInRect:CGRectMake(0, 0,image.size.width * [UIScreen mainScreen].scale/3 *2, image.size.height * [UIScreen mainScreen].scale/3 *2)];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self savePhoto:resultImage];
    }];
    
    UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Normal", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width * [UIScreen mainScreen].scale, image.size.height * [UIScreen mainScreen].scale));
        [image drawInRect:CGRectMake(0, 0,image.size.width * [UIScreen mainScreen].scale, image.size.height * [UIScreen mainScreen].scale)];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self savePhoto:resultImage];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:firstAction];
    [alertController addAction:secondAction];
    [alertController addAction:thirdAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(IBAction)onDelete:(id)sender{
    int page = roundf(_largeCollectionView.contentOffset.x/_photoWidth);
    [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoDeleteNotification object:[NSString stringWithFormat:@"%d",page]];
    [self.photoList removeObjectAtIndex:page];
    if ([self.photoList count] == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [_largeCollectionView reloadData];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _saveBtn.userInteractionEnabled = NO;
    _deleteBtn.userInteractionEnabled = NO;
    _editBtn.userInteractionEnabled = NO;
}


-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        _saveBtn.userInteractionEnabled = YES;
        _deleteBtn.userInteractionEnabled = YES;
        _editBtn.userInteractionEnabled = YES;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _saveBtn.userInteractionEnabled = YES;
    _deleteBtn.userInteractionEnabled = YES;
    _editBtn.userInteractionEnabled = YES;
}

-(IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onCamera:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (CGRect)getFrameWithString:(NSString *)string{
    CGRect frame = CGRectFromString([NSString stringWithFormat:@"{%@}",string]);
    CGRect result = CGRectMake(frame.origin.x/_scale*_factor, frame.origin.y/_scale*_factor, frame.size.width/_scale*_factor, frame.size.height/_scale*_factor);
    return result;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *path_document = NSHomeDirectory();
    NSString *fileName = [self.photoList objectAtIndex:indexPath.row];
    NSString *imagePath = [path_document stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@.jpg",fileName]];
    static NSString *ID = @"LargePhotoCell";
    LargePhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    [cell setImageWithUrl:imagePath];
    return cell;
}

- (void)savePhoto:(UIImage *)image
{
    [MBProgressHUD showActivityMessageInWindow:NSLocalizedString(@"Saving", nil)];
    //1 将图片保存到系统的【相机胶卷】中---调用刚才的方法
    [self syncSaveImage:image];
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

@end
