//
//  CameraViewController.h
//  ClassicCamera
//
//  Created by 张文洁 on 2017/10/30.
//  Copyright © 2017年 JamStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <StoreKit/StoreKit.h>
#import <MessageUI/MessageUI.h>

@interface CameraViewController : UIViewController <MFMailComposeViewControllerDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver,UIPickerViewDelegate,UIPickerViewDataSource>

/**
 *  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
 */
@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

@end
