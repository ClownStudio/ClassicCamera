//
//  YJJsonKit.m
//  YJKit
//
//  Created by 张文洁 on 2017/8/18.
//  Copyright © 2017年 张文洁. All rights reserved.
//

#import "YJJsonKit.h"

@implementation YJJsonKit

@end

@implementation NSObject (JSONWrapper)

- (NSString *)objectToJSONString{
    NSString *jsonString = nil;
    NSError *error;
    
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
        } else {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
    }
    return jsonString;
}

@end

@implementation NSString (JSONWrapper)

- (id)JSONObject{
    NSError* error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                                options:NSJSONReadingMutableContainers
                                                  error:&error];
    
    if (error != nil) {
        NSLog(@"NSString JSONObject error: %@", [error localizedDescription]);
    }
    
    return object;
}

- (id)objectFromJSONString{
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error != nil) {
        NSLog(@"error = %@",error);
        return nil;
    }
    return result;
}

@end

@implementation NSData (JSONWrapper)

- (NSString *)stringFromJSONData{
    NSString *jsonString = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    return jsonString;
}

-(id)objectFromJSONString{
    NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableContainers error:&error];
    if (error != nil) {
        return nil;
    }
    return result;
}

@end
