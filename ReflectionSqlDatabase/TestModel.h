//
//  TestModel.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DaoModel.h"

@interface TestModel : DaoModel

@property(nonatomic, strong) NSString *string;
@property(nonatomic) int intVal;
@property(nonatomic) float floatVal;
@property(nonatomic) double doubleVal;
@property(nonatomic, strong) NSDate *date;
@property(nonatomic) long longVal;


@end
