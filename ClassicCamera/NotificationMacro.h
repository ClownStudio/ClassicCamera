//
//  NotificationMacro.h
//  ThemeSkinSetupExample
//
//  Created by Macmini on 16/1/28.
//
//

#ifndef NotificationMacro_h
#define NotificationMacro_h

#define kThemeChangedNotification @"ThemeChangedNotification"
#define kPhotoDeleteNotification @"PhotoDeleteNotification"

#define kProductPurchaseKey @"Product_Purchase"
#define kBonderProductPurchaseKey @"Bonder_Product_Purchase"
#define kThemeIndexKey @"theme"

#define kAlertAppStoreProduct @"AlertAppStoreProduct"
#define kDateType @"DateType"
#define kStoreProductKey [NSString stringWithFormat:@"storeProduct%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]

#define APP_ID @"1039766045"

#define ALL_PRODUCT_ID [NSString stringWithFormat:@"%@.pro",[[NSBundle mainBundle] bundleIdentifier]]

#endif /* NotificationMacro_h */
