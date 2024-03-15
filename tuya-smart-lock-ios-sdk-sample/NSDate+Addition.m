//
//  NSData+Addition.m
//  tuya-smart-lock-ios-sdk-sample
//
//  Created by LingChen on 2024/3/13.
//

#import "NSDate+Addition.h"

@implementation NSDate (Addition)

- (NSTimeInterval)hourTimeStampWithOffset:(NSInteger)offset {
    // 获取用户当前日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 获取当前日期的年、月、日、小时
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:self];
    // 将分钟和秒设置为 0，以获取当前小时的整点时间
    [components setMinute:0];
    [components setSecond:0];
    
    // 使用当前的年、月、日、小时（分钟和秒都设置为0）来创建一个新的 NSDate
    NSDate *hourDate = [calendar dateFromComponents:components];
    
    NSDateComponents *addComponents = [[NSDateComponents alloc] init];
    [addComponents setHour:offset];
    NSDate *hoursLaterDate = [calendar dateByAddingComponents:addComponents toDate:hourDate options:0];
    
    NSTimeInterval hoursLaterTimestamp = [hoursLaterDate timeIntervalSince1970];

    return hoursLaterTimestamp;
    
}

@end
