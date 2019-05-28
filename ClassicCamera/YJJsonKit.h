//
//  YJJsonKit.h
//  YJKit
//
//  Created by 张文洁 on 2017/8/18.
//  Copyright © 2017年 张文洁. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YJJsonKit : NSObject

@end

@interface NSObject (JSONWrapper)

- (NSString *)objectToJSONString;

@end

@interface NSString (JSONWrapper)

- (id)JSONObject;
- (id)objectFromJSONString;

@end


@interface NSData (JSONWrapper)

- (NSString *)stringFromJSONData;

-(id)objectFromJSONString;

@end
