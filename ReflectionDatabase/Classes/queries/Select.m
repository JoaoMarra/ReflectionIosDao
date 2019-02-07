//
//  Select.m
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import "Select.h"

@implementation Select

+(SelectQueryTransaction<Class> *) from:(Class)type {
    SelectQueryTransaction<Class> * transaction = [[SelectQueryTransaction alloc] initWithClass:type];
    
    return transaction;
}

@end
