//
//  WhereQueryTransaction.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 18/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QueryHelper.h"
#import "WhereNode.h"

@interface WhereQueryTransaction<ObjectType> : NSObject

-(id)initWithClass:(Class)modelClass;

-(NSArray<WhereNode *> *)getWhereNodes;
-(Class)getModelClass;

-(instancetype) where:(NSString *)columnName value:(id)value comparation:(WHERE_COMPARATION)comparation;

@end
