//
//  QueryHelper.m
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import "QueryHelper.h"

@implementation QueryHelper

+(NSString *)whereComparationToString:(WHERE_COMPARATION) comparation {
    
    switch(comparation) {
        case EQUAL:
            return @"=";
        case NOT_EQUAL:
            return @"<>";
        case LIKE:
            return @"like";
        case NOT_LIKE:
            return @"not like";
        case MORE_THAN:
            return @">";
        case MORE_EQUAL:
            return @">=";
        case LESS_THAN:
            return @"<";
        case LESS_EQUAL:
            return @"<=";
    }
    return @"";
}

@end
