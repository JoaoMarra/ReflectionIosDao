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
#import "DBHelper.h"

@interface DBManager()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;

@property (nonatomic, strong) NSMutableArray *arrResults;
@property (nonatomic) int affectedRows;
@property (nonatomic) int lastInsertedRowID;

@property (nonatomic, strong) NSString *databasePath;

@property(nonatomic) BOOL debug;

@end

@implementation DBManager

+(void)initDB:(id<DBManagerDelegate>)delegate {
    int version = delegate.dbSchemeVersion;
    
    if(![DBManager checkSchemeVersion:version]) { //create new database
        NSUserDefaults *tableDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"ReflectionSqlDatabase"];
        NSMutableDictionary *tableDic = [[tableDefaults objectForKey:@"tables"] mutableCopy];
        
        if( !tableDic) {
            tableDic = [NSMutableDictionary new];
        }
        NSMutableArray<NSString *> *defaultKeys = [[tableDic allKeys] mutableCopy];
        
        NSArray<Class> *classes = delegate.dbDaoClasses;
        NSMutableDictionary *checkedTables = [NSMutableDictionary new];
        NSString *tableName;
        if(classes) {
            for(Class cl in classes) {
                tableName = [DaoModel tableName:cl];
                
                [checkedTables setObject:@"" forKey:tableName];
                if([tableDic objectForKey:tableName]) {
                    [DBManager updateTable:cl oldDescription:[tableDic objectForKey:tableName]];
                    [tableDic setObject:[DaoModel tableDescription:cl] forKey:tableName];
                } else {
                    [DBManager createTable:cl];
                    [tableDic setObject:[DaoModel tableDescription:cl] forKey:tableName];
                }
                [defaultKeys removeObject:tableName];
            }
            
            //check tables do drop:
            for(NSString *key in defaultKeys) {
                if(!checkedTables[key]) {
                    [DBManager dropTableName:key];
                    [tableDefaults removeObjectForKey:tableName];
                }
            }
            [tableDefaults setObject:tableDic forKey:@"tables"];
            [tableDefaults synchronize];
        }
        
        if([delegate respondsToSelector:@selector(dbPostCreationOrUpdate)]) {
            [delegate dbPostCreationOrUpdate];
        }
    }
    
}

+(BOOL)checkSchemeVersion:(int)version {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"ReflectionSqlDatabase"];
    NSNumber *savedVersion = [defaults objectForKey:@"scheme_version"];
    if(savedVersion) {
        if([savedVersion intValue] >= version)
            return YES;
    }
    
    savedVersion = [NSNumber numberWithInt:version];
    [defaults setObject:savedVersion forKey:@"scheme_version"];
    [defaults synchronize];
    
    return NO;
}

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
            DBLog(@"%@", [error localizedDescription]);
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
+(int*)runQueryForInt:(const char*)query {
    if([DBManager runQuery:query executable:YES]) {
        int *retorno = malloc(sizeof(int)*2);
        retorno[0] = DBManager.manager.lastInsertedRowID;
        retorno[1] = DBManager.manager.affectedRows;
        return retorno;
    }
    return nil;
}

+(void)runQueryForArray:(const char*)query async:(void (^)(NSArray *results))completion {
    
}
+(void)runQueryForInt:(const char*)query async:(void (^)(int* result))completion {
    
}

+(BOOL)runQuery:(const char*)query executable:(BOOL)executable {
    CFAbsoluteTime timeInSeconds = CFAbsoluteTimeGetCurrent();
    DBLog(@"DB RUN QUERY:\n%s", query);
    
    sqlite3 *sqlite3Database;
    DBManager *manager = DBManager.manager;
    
    [manager prepareQuery];
    
    BOOL result = NO;
    BOOL openDatabaseResult = sqlite3_open([manager.databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        if(executable) {
            result = [manager executableQuery:query database:sqlite3Database];
        } else {
            sqlite3_stmt *compiledStatement;
            int prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, nil);
            if(prepareStatementResult == SQLITE_OK) {
                NSMutableArray *results = [manager nonExecutableQuery:compiledStatement];
                [manager.arrResults addObjectsFromArray:results];
                DBLog(@"DB QUERY SUCCESS");
                result = YES;
                sqlite3_finalize(compiledStatement);
            } else {
                DBLog(@"DB QUERY FAILED");
            }
        }
        sqlite3_close(sqlite3Database);
    } else {
        DBLog(@"DB QUERY FAILED");
    }

    DBLog(@"DB QUERY END: %f\n", CFAbsoluteTimeGetCurrent()-timeInSeconds);
    
    return result;
}

-(BOOL)executableQuery:(const char*)query database:(sqlite3 *)sqlite3Database {
    char *error;
    int executeQueryResults = sqlite3_exec(sqlite3Database, query, nil, nil, &error);
    if (executeQueryResults == SQLITE_OK) {
        self.affectedRows = sqlite3_changes(sqlite3Database);
        self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
        DBLog(@"DB QUERY SUCCESS");
        return YES;
    } else {
        DBLog(@"DB Error: %s", error);
    }
    return NO;
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

+(void)updateTable:(Class)modelClass oldDescription:(NSDictionary *)oldDescription {
    
    NSDictionary *description = [DaoModel tableDescription:modelClass];
    NSMutableString *retainColumns = [NSMutableString new];
    NSArray<NSString *> *keys = oldDescription.allKeys;
    for(NSString *key in keys) {
        if(description[key]) {
            [retainColumns appendFormat:@"%@,",key];
        }
    }
    if([retainColumns hasSuffix:@","])
        [retainColumns replaceCharactersInRange:NSMakeRange(retainColumns.length-1, 1) withString:@""];
    
    NSString *tempName = [NSString stringWithFormat:@"%@_temp",[DaoModel tableName:modelClass]];
    [DBManager createTableName:tempName class:modelClass];
    
    NSString *copyQuery = [NSString stringWithFormat:@"INSERT INTO %@ (%@)\nSELECT %@ from %@",tempName,retainColumns,retainColumns,[DaoModel tableName:modelClass]];
    [DBManager runQuery:copyQuery.UTF8String executable:YES];
    
    [DBManager dropTable:modelClass];
    [DBManager runQuery:[NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@",tempName, [DaoModel tableName:modelClass]].UTF8String executable:YES];
}

+(void)createTable:(Class)modelClass {
    
    if(![modelClass isSubclassOfClass:DaoModel.class]) {
        DBLog(@"DB Error: NOT SUBCLASS OF DaoModel");
        return;
    }
    
    [DBManager createTableName:[DaoModel tableName:modelClass] class:modelClass];
    
}

+(void)createTableName:(NSString *)tableName class:(Class)modelClass {
    NSMutableString *query = [NSMutableString new];
    [query appendString:@"CREATE TABLE IF NOT EXISTS "];
    [query appendString:tableName];
    [query appendString:@"("];
    
    unsigned int propertyCount;
    
    objc_property_t *properties = class_copyPropertyList(modelClass, &propertyCount);
    objc_property_t property;
    NSString *typeString;
    NSString *compareSting;
    BOOL keySet = NO;
    const char*properyName;
    DaoModel *model = [modelClass alloc];
    NSString *keyName = model.primaryKeyName;
    for (NSUInteger i=0; i<propertyCount; i++) {
        property = properties[i];
        compareSting = @([PropertyHelper getPropertyType:property]);
        properyName = property_getName(property);
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
        
        if(!keySet && [keyName isEqualToString:@(properyName)]) {
            typeString = [typeString stringByAppendingString:@" primary key"];
            keySet = YES;
        }
        
        if(typeString)
            [query appendString:[NSString stringWithFormat:@"\n%s %@,",properyName,typeString]];
    }
    
    if(!keySet) {
        [query appendFormat:@"%@ INTEGER primary key autoincrement)",keyName];
    }
    
    if([query hasSuffix:@","])
        [query replaceCharactersInRange:NSMakeRange(query.length-1, 1) withString:@")"];
    
    [DBManager runQuery:query.UTF8String executable:YES];
}

+(void)dropTable:(Class)modelClass {
    if(![modelClass isSubclassOfClass:DaoModel.class]) {
        DBLog(@"DB Error: NOT SUBCLASS OF DaoModel");
        return;
    }
    
    [DBManager dropTableName:[DaoModel tableName:modelClass]];
}

+(void)dropTableName:(NSString *)tableName {
    NSMutableString *query = [NSMutableString new];
    [query appendString:@"DROP TABLE IF EXISTS "];
    [query appendString:tableName];
    
    [DBManager runQuery:query.UTF8String executable:YES];
}

+(int)rowCount:(Class)modelClass {
    NSString *countQuery = [NSString stringWithFormat:@"select count(*) as count from %@",[DaoModel tableName:modelClass]];
    
    if([DBManager runQuery:countQuery.UTF8String executable:NO]) {
        NSArray *results = [DBManager.manager.arrResults copy];
        if(results.count > 0 && results[0][@"count"])
            return [results[0][@"count"] intValue];
    }
    return 0;
}

+(void)setDebugMode:(BOOL)debug {
    [DBManager manager].debug = debug;
}

+(BOOL)isDebugMode {
    BOOL debug = [DBManager manager].debug;
    return debug;
}

#pragma mark - Creating components

-(NSString *)databasePath {
    if(!_databasePath) {
        _databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    }
    return _databasePath;
}
    
@end
