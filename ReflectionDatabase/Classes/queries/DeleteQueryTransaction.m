//
//  DeleteQueryTransaction.m
//  ReflectionSqlDatabase
//
//  Created by Mais App on 18/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import "DeleteQueryTransaction.h"
#import "DaoModel.h"
#import "DBManager.h"

@implementation DeleteQueryTransaction

-(int)execute {
    
    NSArray<WhereNode *>* whereNodes = self.getWhereNodes;
    Class modelClass = self.getModelClass;
    
    NSMutableString *query = [NSMutableString new];
    [query appendString:@"DELETE FROM "];
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
    
    int *data = [DBManager runQueryForInt:query.UTF8String];
    
    if(data) {
        int count = data[1];
        free(data);
        return count;
    }
    
    return -1;
}

@end
