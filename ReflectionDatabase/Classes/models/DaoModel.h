//
//  DaoModel.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_PRIMARY_KEY @"default_primary_key"

@interface DaoModel : NSObject

-(instancetype)initWithDBDictionary:(NSDictionary *)dictionary;

-(void)configureWithReflectionDictionary:(NSDictionary *)dictionary;

+(NSString *)tableName:(Class)tableModel;
+(NSDictionary *)tableDescription:(Class)tableModel;

-(BOOL)insertModel;
-(BOOL)updateModel;
-(BOOL)deleteModel;

-(NSString *)primaryKeyName;
-(id)primaryKeyValue;

@end

@protocol DaoModelProtocol <NSObject>

-(NSString *)primaryKeyName;
-(id)primaryKeyValue;

@end
