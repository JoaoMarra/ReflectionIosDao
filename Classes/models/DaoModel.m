//
//  DaoModel.m
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import "DaoModel.h"
#import "DBManager.h"
#import <objc/runtime.h>
#import "PropertyHelper.h"
#import "DateHelper.h"

@interface DaoModel()

@property(nonatomic, strong) NSString *insertBase;
@property(nonatomic, strong) id default_primary_key;

@end

@implementation DaoModel

-(instancetype)initWithDBDictionary:(NSDictionary *)dictionary {
    self = [self init];
    
    [self configureWithReflectionDictionary:dictionary];
    
    return self;
}

-(void)configureWithReflectionDictionary:(NSDictionary *)dictionary {
    if(!dictionary)
        return;
    
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList(self.class, &propertyCount);
    objc_property_t property;
    NSString *compareSting, *propertName;
    id value;
    for (NSUInteger i=0; i<propertyCount; i++) {
        property = properties[i];
        compareSting = @([PropertyHelper getPropertyType:property]);
        propertName = @(property_getName(property));
        value = dictionary[propertName];
    
        if(value) {
            if([@"NSDate" isEqualToString:compareSting])
                [self setValue:[DateHelper dateFromString:value] forKey:propertName];
            else
                [self setValue:value forKey:propertName];
        }
        
        
    }
}

+(NSString *)tableName:(Class )tableModel {
    return NSStringFromClass(tableModel);
}

+(NSDictionary *)tableDescription:(Class)tableModel {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    unsigned int propertyCount;
    
    objc_property_t *properties = class_copyPropertyList(tableModel, &propertyCount);
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
        
        if(typeString) {
            [dictionary setObject:typeString forKey:@(property_getName(property))];
        }
    }

    
    return (NSDictionary *)dictionary;
}

-(void)insertModel {
    NSMutableString *query = [NSMutableString new];
    [query appendString:self.insertBase];
    [query appendString:@" ("];
    
    unsigned int propertyCount;
    
    objc_property_t *properties = class_copyPropertyList(self.class, &propertyCount);
    objc_property_t property;
    NSString *compareSting;
    id object;
    for (NSUInteger i=0; i<propertyCount; i++) {
        property = properties[i];
        compareSting = @([PropertyHelper getPropertyType:property]);
        object = [self valueForKey:@(property_getName(property))];
        if(object) {
            if([@"NSDate" isEqualToString:compareSting])
                [query appendString:[NSString stringWithFormat:@"\"%@\",",[DateHelper stringFromDate:object]]];
            else if([@"NSString" isEqualToString:compareSting])
                [query appendString:[NSString stringWithFormat:@"\"%@\",",object]];
            else
                [query appendString:[NSString stringWithFormat:@"%@,",object]];
        } else {
            [query appendString:@"NULL,"];
        }
        
    }
    if([query hasSuffix:@","])
        [query replaceCharactersInRange:NSMakeRange(query.length-1, 1) withString:@")"];
    
    [DBManager runQueryForInt:query.UTF8String];
}

-(void)updateModel {
    NSMutableString *query = [NSMutableString new];
    [query appendString:self.insertBase];
    [query appendString:@" ("];
    
    unsigned int propertyCount;
    
    objc_property_t *properties = class_copyPropertyList(self.class, &propertyCount);
    objc_property_t property;
    NSString *compareSting;
    id object;
    for (NSUInteger i=0; i<propertyCount; i++) {
        property = properties[i];
        compareSting = @([PropertyHelper getPropertyType:property]);
        object = [self valueForKey:@(property_getName(property))];
        if(object) {
            if([@"NSDate" isEqualToString:compareSting])
                [query appendString:[NSString stringWithFormat:@"\"%@\",",[DateHelper stringFromDate:object]]];
            else if([@"NSString" isEqualToString:compareSting])
                [query appendString:[NSString stringWithFormat:@"\"%@\",",object]];
            else
                [query appendString:[NSString stringWithFormat:@"%@,",object]];
        } else {
            [query appendString:@"NULL,"];
        }
        
    }
    if([query hasSuffix:@","])
        [query replaceCharactersInRange:NSMakeRange(query.length-1, 1) withString:@")"];
    
    [DBManager runQueryForInt:query.UTF8String];

}

-(void)deleteModel {
    
}

-(NSString *)primaryKeyName {
    return DEFAULT_PRIMARY_KEY;
}

-(id)primaryKeyValue {
    return [self valueForKey:[self primaryKeyName]];
}

#pragma mark - Creating components

-(NSString *)insertBase {
    if(!_insertBase) {
        NSMutableString *base = [NSMutableString new];
        [base appendString:@"REPLACE INTO "];
        [base appendString:[DaoModel tableName:self.class]];
        [base appendString:@" ("];
        
        unsigned int propertyCount;
        
        objc_property_t *properties = class_copyPropertyList(self.class, &propertyCount);
        objc_property_t property;
        for (NSUInteger i=0; i<propertyCount; i++) {
            property = properties[i];
            [base appendString:[NSString stringWithFormat:@"%s,",property_getName(property)]];
        }
        if([base hasSuffix:@","])
            [base replaceCharactersInRange:NSMakeRange(base.length-1, 1) withString:@")"];
        
        [base appendString:@" VALUES\n"];
        _insertBase = (NSString *)base;
    }
    return _insertBase;
}
@end
