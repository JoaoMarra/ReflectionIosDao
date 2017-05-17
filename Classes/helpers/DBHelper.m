//
//  DBHelper.m
//  ReflectionSqlDatabase
//
//  Created by Mais App on 17/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import "DBHelper.h"
#import "DBManager.h"

@implementation DBHelper

void DBLog(NSString *format, ...) {
    //if([DBManager isDebugMode]) {
        va_list argumentList;
        va_start(argumentList, format);
        NSLogv(format, argumentList);
        va_end(argumentList);
    //}
}

@end
