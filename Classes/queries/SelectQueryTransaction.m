//
//  SelectQueryTransaction.m
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import "SelectQueryTransaction.h"
#import "DaoModel.h"
#import "DBManager.h"
#import "DaoModel.h"

@interface SelectQueryTransaction()

@property(nonatomic) Class modelClass;

@property(nonatomic, strong) NSMutableString *orderBy;
@property(nonatomic) int limit;

@end

@implementation SelectQueryTransaction

-(id)initWithClass:(Class)modelClass {
    self = [self init];
    self.modelClass = modelClass;
    self.limit = 0;
    
    return self;
}

-(SelectQueryTransaction *) where:(NSString *)columnName value:(id)value comparation:(WHERE_COMPARATION)comparation {
    
    
    return self;
}

-(SelectQueryTransaction *) orderBy:(NSString *)columnName order:(ORDER_BY)order{
    if(!self.orderBy) {
        self.orderBy = [NSMutableString new];
    }
    [self.orderBy appendString:@" "];
    [self.orderBy appendString:columnName];
    [self.orderBy appendString:@" "];
    if(order == ASCENDING) {
        [self.orderBy appendString:@"ASC"];
    } else {
        [self.orderBy appendString:@"DESC"];
    }
    return self;
}

-(SelectQueryTransaction *) limit:(int)limit {
    self.limit = limit;
    return self;
}

-(NSArray *)execute {
    
    NSMutableString *query = [NSMutableString new];
    [query appendString:@"SELECT * FROM "];
    [query appendString:[DaoModel tableName:self.modelClass]];
    
    if(self.orderBy)
        [query appendString:self.orderBy];
    if(self.limit > 0) {
        [query appendString:[NSString stringWithFormat:@" limit %d",self.limit]];
    }
    
    NSArray *data = [DBManager runQueryForArray:query.UTF8String];
    
    if(data) {
        NSMutableArray *models = [NSMutableArray new];
        
        for(NSDictionary *dictionary in data) {
            [models addObject:(DaoModel *)[[self.modelClass alloc]initWithDBDictionary:dictionary]];
        }
        
        return (NSArray *)models;
    }
    
    return nil;
}

@end
