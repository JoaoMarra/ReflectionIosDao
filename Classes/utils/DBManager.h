//
//  DBManager.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DBManagerDelegate;

@interface DBManager : NSObject

+(void)initDB:(id<DBManagerDelegate>)delegate;

+(NSArray *)runQueryForArray:(const char*)query;
+(int*)runQueryForInt:(const char*)query;

+(void)runQueryForArray:(const char*)query async:(void (^)(NSArray *results))completion;
+(void)runQueryForInt:(const char*)query async:(void (^)(int rowCount))completion;

+(void)setDebugMode:(BOOL)debug;
+(BOOL)isDebugMode;

@end

@protocol DBManagerDelegate <NSObject>

@required
-(int)dbSchemeVersion;
-(NSArray<Class> *)dbDaoClasses;

@optional
-(void)dbPostCreationOrUpdate;

@end
