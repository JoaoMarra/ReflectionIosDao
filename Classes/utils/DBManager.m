//
//  DBManager.m
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>
#import "DaoModel.h"
#import <objc/runtime.h>
#import "PropertyHelper.h"
#import "DateHelper.h"

@interface DBManager()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;

@property (nonatomic, strong) NSMutableArray *arrResults;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

@property (nonatomic, strong) NSString *databasePath;

@end

@implementation DBManager

+(instancetype)manager {
    static DBManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] initWithDatabaseFilename:@"reflection_db_file"];
    });
    return manager;
}

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename {
    self = [super init];
    if (self) {
        // Set the documents directory path to the documentsDirectory property.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        
        // Keep the database filename.
        self.databaseFilename = dbFilename;
        
        // Copy the database file into the documents directory if necessary.
        [self copyDatabaseIntoDocumentsDirectory];
    }
    return self;
}

-(void)copyDatabaseIntoDocumentsDirectory{
    // Check if the database file exists in the documents directory.
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        // The database file does not exist in the documents directory, so copy it from the main bundle now.
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        // Check if any error occurred during copying and display it.
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

//Clear Memory
-(void)prepareQuery {
    if (self.arrResults != nil) {
        [self.arrResults removeAllObjects];
        self.arrResults = nil;
    }
    self.arrResults = [[NSMutableArray alloc] init];
}

+(NSArray *)runQueryForArray:(const char*)query {
    if([DBManager runQuery:query executable:NO]) {
        NSArray *results = [DBManager.manager.arrResults copy];
        return results;
    }
    return nil;
}
+(int)runQueryForInt:(const char*)query {
    if([DBManager runQuery:query executable:YES]) {
        return DBManager.manager.affectedRows;
    }
    return -1;
}

+(void)runQueryForArray:(const char*)query async:(void (^)(NSArray *results))completion {
    
}
+(void)runQueryForInt:(const char*)query async:(void (^)(int rowCount))completion {
    
}

+(BOOL)runQuery:(const char*)query executable:(BOOL)executable {
    NSLog(@"DB RUN QUERY: %s", query);
    
    sqlite3 *sqlite3Database;
    DBManager *manager = DBManager.manager;
    
    [manager prepareQuery];
    
    BOOL result = NO;
    BOOL openDatabaseResult = sqlite3_open([manager.databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        sqlite3_stmt *compiledStatement;
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK) {
            if(executable) {
                [manager executableQuery:compiledStatement database:sqlite3Database];
                result = YES;
            } else {
                NSMutableArray *results = [manager nonExecutableQuery:compiledStatement];
                [manager.arrResults addObjectsFromArray:results];
                NSLog(@"DB QUERY SUCCESS");
                result = YES;
            }
            sqlite3_finalize(compiledStatement);
        }
        sqlite3_close(sqlite3Database);
    }
    
    return result;
}

-(void)executableQuery:(sqlite3_stmt *)compiledStatement database:(sqlite3 *)sqlite3Database {
    int executeQueryResults = sqlite3_step(compiledStatement);
    if (executeQueryResults == SQLITE_DONE) {
        self.affectedRows = sqlite3_changes(sqlite3Database);
        self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
        NSLog(@"DB QUERY SUCCESS");
    } else {
        NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
    }
}

-(NSMutableArray *)nonExecutableQuery:(sqlite3_stmt *)compiledStatement {
    NSMutableArray *results = [NSMutableArray new];
    NSMutableDictionary *objectDic;
    NSString *value, *column;
    while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
        
        objectDic = [NSMutableDictionary new];
        int totalColumns = sqlite3_column_count(compiledStatement);
        
        for (int i=0; i<totalColumns; i++){
            char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
            
            if (dbDataAsChars != NULL) {
                value = [NSString  stringWithUTF8String:dbDataAsChars];
            }
            
            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
            if (dbDataAsChars != NULL) {
                column = [NSString stringWithUTF8String:dbDataAsChars];
            }
            
            if(value && column) {
                [objectDic setObject:value forKey:column];
            }
        }
        [results addObject:objectDic];
    }
    
    return results;
}

+(void)createTable:(Class)modelClass {
    
    if(![modelClass isSubclassOfClass:DaoModel.class]) {
        NSLog(@"DB Error: NOT SUBCLASS OF DaoModel");
        return;
    }
    
    NSMutableString *query = [NSMutableString new];
    [query appendString:@"CREATE TABLE IF NOT EXISTS "];
    [query appendString:[DaoModel tableName:modelClass]];
    [query appendString:@"("];
    
    unsigned int propertyCount;
    
    objc_property_t *properties = class_copyPropertyList(modelClass, &propertyCount);
    objc_property_t property;
    NSString *typeString;
    NSString *compareSting;
    for (NSUInteger i=0; i<propertyCount; i++) {
        property = properties[i];
        compareSting = @([PropertyHelper getPropertyType:property]);
        typeString = nil;
        if([@"i" isEqualToString:compareSting])
            typeString = @"int";
        else if([@"f" isEqualToString:compareSting])
            typeString = @"double";
        else if([@"d" isEqualToString:compareSting])
            typeString = @"double";
        else if([@"q" isEqualToString:compareSting])
            typeString = @"bigint";
        else if([@"NSDate" isEqualToString:compareSting])
            typeString = [NSString stringWithFormat:@"varchar(%lu)",(unsigned long)DB_DATE_FORMATE_STRING.length];
        else if([@"NSString" isEqualToString:compareSting])
            typeString = @"varchar(255)";
        
        if(typeString)
            [query appendString:[NSString stringWithFormat:@"\n%s %@,",property_getName(property),typeString]];
    }
    if([query hasSuffix:@","])
        [query replaceCharactersInRange:NSMakeRange(query.length-1, 1) withString:@")"];
    
    [DBManager runQuery:query.UTF8String executable:YES];
    
}

+(void)dropTable:(Class)modelClass {
    if(![modelClass isSubclassOfClass:DaoModel.class]) {
        NSLog(@"DB Error: NOT SUBCLASS OF DaoModel");
        return;
    }
    
    NSMutableString *query = [NSMutableString new];
    [query appendString:@"DROP TABLE IF EXISTS "];
    [query appendString:[DaoModel tableName:modelClass]];
    
    [DBManager runQuery:query.UTF8String executable:YES];
}

#pragma mark - Creating components

-(NSString *)databasePath {
    if(!_databasePath) {
        _databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    }
    return _databasePath;
}
    
@end
