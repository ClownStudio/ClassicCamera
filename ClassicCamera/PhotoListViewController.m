//
//  PhotoListViewController.m
//  ClassicCamera
//
//  Created by 张文洁 on 2018/5/7.
//  Copyright © 2018年 JamStudio. All rights reserved.
//

#import "PhotoListViewController.h"
#import "ThemeManager.h"
#import "NotificationMacro.h"
#import <MBProgressHUD+JDragon.h>
#import "YJJsonKit.h"
#import "PhotoListCollectionViewCell.h"
#import "DetailPhotoViewController.h"

@interface PhotoListViewController () <UICollectionViewDelegate,UICollectionViewDataSource>

@end

@implementation PhotoListViewController{
    CGFloat _margin, _gutter;
    NSString *_resolution;
    NSInteger _screenWidth;
    NSInteger _screenHeight;
    NSInteger _scale;
    UIImageView *_albumSkin;
    NSDictionary *_positions;
    UIButton *_backBtn;
    int _photoWidth;
    int _photoHeight;
    UIView *_largeContentView;
    CGFloat _factor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _scale = [UIScreen mainScreen].scale;
    _albumSkin = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [_albumSkin setUserInteractionEnabled:YES];
    _resolution = [NSString stringWithFormat:@"%dX%d",(int)(_screenWidth*_scale),(int)(_screenHeight*_scale)];
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
    [_albumSkin setImage:image];
    [self.view addSubview:_albumSkin];
    
    NSString *albumPath = [[NSBundle mainBundle] pathForResource:@"album" ofType:@"plist"];
    NSDictionary *albumList = [NSDictionary dictionaryWithContentsOfFile:albumPath];
    _positions = [albumList objectForKey:_resolution];
    if (_positions == nil) {
        _positions = [albumList objectForKey:@"1334X750"];
    }
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    [layout setItemSize:CGSizeMake((_screenHeight - 30)/2/9*16, (_screenHeight - 30)/2)];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.collectionView = [[UICollectionView alloc] initWithFrame:_albumSkin.bounds collectionViewLayout:layout];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[PhotoListCollectionViewCell class] forCellWithReuseIdentifier:@"PhotoListCell"];
    [_albumSkin addSubview:self.collectionView];
    _backBtn = [[UIButton alloc] initWithFrame:[self getFrameWithString:[_positions objectForKey:@"back"]]];
    [_backBtn setImage:[themeManager themeImageWithName:@"back_album"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [_albumSkin addSubview:_backBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeletePhotoWithIndex:) name:kPhotoDeleteNotification object:nil];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    NSLog(@"viewSafeAreaInsetsDidChange-%@",NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
    
    CGFloat width = _screenWidth - self.view.safeAreaInsets.right - self.view.safeAreaInsets.left;
    CGFloat height = _screenHeight - self.view.safeAreaInsets.top -self.view.safeAreaInsets.bottom;
    
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setItemSize:CGSizeMake((height - 30)/2/9*16, (height - 30)/2)];
    CGRect temp = self.collectionView.frame;
    temp.origin.x = self.view.safeAreaInsets.left;
    temp.origin.y = self.view.safeAreaInsets.top;
    temp.size.width = width;
    temp.size.height = height;
    self.collectionView.frame = temp;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    DetailPhotoViewController *details = [[DetailPhotoViewController alloc] init];
    details.photoList = [NSMutableArray arrayWithArray:self.imageList];
    details.selectedIndex = (int)indexPath.row;
    [self.navigationController pushViewController:details animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.imageList count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoListCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoListCell" forIndexPath:indexPath];
    NSString *imagePath = [self.imageList objectAtIndex:indexPath.row];
    [cell setImageWithImagePath:imagePath];
    return cell;
}

- (CGRect)getFrameWithString:(NSString *)string{
    CGRect frame = CGRectFromString([NSString stringWithFormat:@"{%@}",string]);
    CGRect result = CGRectMake(frame.origin.x/_scale*_factor, frame.origin.y/_scale*_factor, frame.size.width/_scale*_factor, frame.size.height/_scale*_factor);
    return result;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

-(IBAction)onBack:(id)sender{
    [self.collectionView removeFromSuperview];
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    self.collectionView = nil;
    if ([@"2001X1125" isEqualToString:_resolution]) {
        [self performSelector:@selector(onDismissViewController) withObject:self afterDelay:0.05];
    }else{
        [self onDismissViewController];
    }
}

-(IBAction)onDeletePhotoWithIndex:(NSNotification *)notification{
    NSInteger index = [(NSString *)notification.object integerValue];
    [MBProgressHUD showActivityMessageInWindow:NSLocalizedString(@"Deleting", nil)];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSString *path_document = NSHomeDirectory();
    NSString *fileName = [self.imageList objectAtIndex:index];
    NSString *imagePath = [path_document stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@.png",fileName]];
    NSString *thumbPath = [path_document stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@.jpg",fileName]];
    [self deleteFileWithUrl:imagePath];
    [self deleteFileWithUrl:thumbPath];
    [indexSet addIndex:index];
    [self.imageList removeObjectsAtIndexes:indexSet];
    [self.collectionView reloadData];
    NSString *dataString = [self.imageList objectToJSONString];
    [[NSUserDefaults standardUserDefaults] setObject:dataString forKey:@"ClassicImage_FileName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSelector:@selector(deleteAnimation) withObject:nil afterDelay:0.5];
}

- (void)deleteFileWithUrl:(NSString *)url{
    [[NSFileManager defaultManager] removeItemAtPath:url error:nil];
}

- (void)deleteAnimation{
    [MBProgressHUD hideHUD];
    [MBProgressHUD showSuccessMessage:NSLocalizedString(@"Deleted", nil)];
}

- (void)onDismissViewController{
    [self.navigationController popViewControllerAnimated:YES];
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
