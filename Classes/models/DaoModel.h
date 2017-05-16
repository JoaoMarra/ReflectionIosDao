//
//  DaoModel.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DaoModel : NSObject

-(instancetype)initWithDBDictionary:(NSDictionary *)dictionary;

-(void)configureWithReflectionDictionary:(NSDictionary *)dictionary;

+(NSString *)tableName:(Class )tableModel;

-(void)insertModel;
-(void)updateModel;
-(void)deleteModel;

@end
