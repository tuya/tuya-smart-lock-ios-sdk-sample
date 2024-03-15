//
//  NSData+Addition.h
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/3/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Addition)

- (NSTimeInterval)hourTimeStampWithOffset:(NSInteger)offset;

@end

NS_ASSUME_NONNULL_END
