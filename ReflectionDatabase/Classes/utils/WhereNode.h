//
//  WhereNode.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QueryHelper.h"

@interface WhereNode : NSObject

@property(nonatomic, strong) NSString *column;
@property(nonatomic) id value;
@property(nonatomic) WHERE_COMPARATION whereComparation;

-(instancetype)initWithColumnName:(NSString *)column value:(id)value comparation:(WHERE_COMPARATION)comparation;

-(NSString *)stringValue;

@end
