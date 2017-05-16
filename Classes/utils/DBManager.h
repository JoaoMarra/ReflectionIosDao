//
//  DBManager.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBManager : NSObject

+(instancetype)manager;

+(NSArray *)runQueryForArray:(const char*)query;
+(int)runQueryForInt:(const char*)query;

+(void)runQueryForArray:(const char*)query async:(void (^)(NSArray *results))completion;
+(void)runQueryForInt:(const char*)query async:(void (^)(int rowCount))completion;

+(void)createTable:(Class)modelClass;
+(void)dropTable:(Class)modelClass;

@end
