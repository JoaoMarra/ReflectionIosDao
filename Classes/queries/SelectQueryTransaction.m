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
#import "WhereNode.h"

@interface SelectQueryTransaction()
@property(nonatomic, strong) NSMutableString *orderBy;
@property(nonatomic) int limit;

@end

@implementation SelectQueryTransaction

-(id)initWithClass:(Class)modelClass {
    self = [super initWithClass:modelClass];
    self.limit = 0;
    
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
    
    NSArray<WhereNode *>* whereNodes = self.getWhereNodes;
    Class modelClass = self.getModelClass;
    
    NSMutableString *query = [NSMutableString new];
    [query appendString:@"SELECT * FROM "];
    [query appendString:[DaoModel tableName:modelClass]];
    
    if(whereNodes.count > 0) {
        [query appendString:@"\nwhere"];
        WhereNode *node;
        for(int i = 0; i < whereNodes.count; i++) {
            node = whereNodes[i];
            [query appendString:node.stringValue];
            if(i < whereNodes.count-1)
                [query appendString:@" AND\n"];
        }
    }
    
    if(self.orderBy) {
        [query appendString:[NSString stringWithFormat:@"\n ORDER BY %@",self.orderBy]];
    }
    if(self.limit > 0) {
        [query appendString:[NSString stringWithFormat:@"\nlimit %d",self.limit]];
    }
    
    NSArray *data = [DBManager runQueryForArray:query.UTF8String];
    
    if(data) {
        NSMutableArray *models = [NSMutableArray new];
        
        for(NSDictionary *dictionary in data) {
            [models addObject:(DaoModel *)[[modelClass alloc]initWithDBDictionary:dictionary]];
        }
        
        return (NSArray *)models;
    }
    
    return nil;
}

@end
