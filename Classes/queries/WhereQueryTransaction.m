//
//  WhereQueryTransaction.m
//  ReflectionSqlDatabase
//
//  Created by Mais App on 18/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import "WhereQueryTransaction.h"

@interface WhereQueryTransaction()

@property(nonatomic) Class modelClass;

@property(nonatomic, strong) NSMutableArray<WhereNode *>* whereNodes;

@end

@implementation WhereQueryTransaction

-(id)initWithClass:(Class)modelClass {
    self = [self init];
    self.modelClass = modelClass;
    
    return self;
}

-(NSArray<WhereNode *> *)getWhereNodes {
    return (NSArray *)self.whereNodes;
}

-(Class)getModelClass {
    return self.modelClass;
}

-(instancetype) where:(NSString *)columnName value:(id)value comparation:(WHERE_COMPARATION)comparation {
    
    [self.whereNodes addObject:[[WhereNode alloc] initWithColumnName:columnName value:value comparation:comparation]];
    
    return self;
}

#pragma mark - Creating components

-(NSMutableArray *)whereNodes {
    if(!_whereNodes) {
        _whereNodes = [NSMutableArray new];
    }
    return _whereNodes;
}

@end
