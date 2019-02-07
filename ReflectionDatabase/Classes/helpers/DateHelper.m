//
//  DateHelper.m
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import "DateHelper.h"

@implementation DateHelper

+(NSDate *)dateFromString:(NSString *)string {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"Greenwich"];
    [dateFormatter setDateFormat:DB_DATE_FORMATE_STRING];
    [dateFormatter setTimeZone:tz];
    NSDate *date = [dateFormatter dateFromString:string];
    
    return date;
}

+(NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"Greenwich"];
    [dateFormatter setDateFormat:DB_DATE_FORMATE_STRING];
    [dateFormatter setTimeZone:tz];
    
    NSString *dateFormatted = [dateFormatter stringFromDate:date];
    
    if ( dateFormatted == nil ) {
        return @"0000-00-00 00:00:00";
    } else {
        return dateFormatted;
    }
}

@end
