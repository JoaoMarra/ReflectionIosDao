//
//  TestModel.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DaoModel.h"

@interface PersonModel : DaoModel

@property(nonatomic, strong) NSString *rg;
@property(nonatomic, strong) NSString *name;
@property(nonatomic) int age;
@property(nonatomic, strong) NSDate *birth;
@property(nonatomic) double currency;

@end
