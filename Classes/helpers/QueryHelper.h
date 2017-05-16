//
//  QueryHelper.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QueryHelper : NSObject

typedef enum {
    EQUAL,
    NOTEQUAL,
    LIKE,
    NOT_LIKE,
    CONTAINS,
    MORE_THAN,
    MORE_EQUAL,
    LESS_THAN,
    LESS_EQUAL
} WHERE_COMPARATION;

typedef enum {
    ASCENDING,
    DESCENDING
} ORDER_BY;

+(NSString *)whereComparationToString:(WHERE_COMPARATION) comparation;

@end
