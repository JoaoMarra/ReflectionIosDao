//
//  Delete.m
//  ReflectionSqlDatabase
//
//  Created by Mais App on 18/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import "Delete.h"

@implementation Delete

+(DeleteQueryTransaction<Class> *) from:(Class)type {
    DeleteQueryTransaction<Class> * transaction = [[DeleteQueryTransaction alloc] initWithClass:type];
    
    return transaction;
}

@end
