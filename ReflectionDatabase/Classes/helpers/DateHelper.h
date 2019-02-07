//
//  DateHelper.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DB_DATE_FORMATE_STRING @"yyyy-MM-dd HH:mm:ss"

@interface DateHelper : NSObject

+(NSDate *)dateFromString:(NSString *)string;
+(NSString *)stringFromDate:(NSDate *)date;

@end
