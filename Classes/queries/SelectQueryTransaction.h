//
//  SelectQueryTransaction.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QueryHelper.h"

@interface SelectQueryTransaction<ObjectType> : NSObject

-(id)initWithClass:(Class)modelClass;

-(SelectQueryTransaction<ObjectType> *) where:(NSString *)columnName value:(id)value comparation:(WHERE_COMPARATION)comparation;

-(SelectQueryTransaction<ObjectType> *) orderBy:(NSString *)columnName order:(ORDER_BY)order;

-(SelectQueryTransaction<ObjectType> *) limit:(int)limit;

-(NSArray<ObjectType> *)execute;

@end
