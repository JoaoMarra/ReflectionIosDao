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
    
    if([self.primaryKeyName isEqualToString:DEFAULT_PRIMARY_KEY] && dictionary[DEFAULT_PRIMARY_KEY]){
        self.default_primary_key = dictionary[DEFAULT_PRIMARY_KEY];
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
    NSMutableString *base = [NSMutableString new];
    NSMutableString *data = [NSMutableString new];
    
    [base appendString:@"REPLACE INTO "];
    [base appendString:[DaoModel tableName:self.class]];
    [base appendString:@" ("];
    [data appendString:@"("];
    if([self.primaryKeyName isEqualToString:DEFAULT_PRIMARY_KEY] && self.default_primary_key){
        [base appendString:[NSString stringWithFormat:@"%@,",DEFAULT_PRIMARY_KEY]];
        [data appendString:[NSString stringWithFormat:@"%@,",self.default_primary_key]];
    }
    
    unsigned int propertyCount;
    
    objc_property_t *properties = class_copyPropertyList(self.class, &propertyCount);
    objc_property_t property;
    NSString *compareSting;
    id object;
    for (NSUInteger i=0; i<propertyCount; i++) {
        property = properties[i];
        
        compareSting = @([PropertyHelper getPropertyType:property]);
        if([DaoModel isValidPropertyType:compareSting]) {
            [base appendString:[NSString stringWithFormat:@"%s,",property_getName(property)]];
            object = [self valueForKey:@(property_getName(property))];
            if(object) {
                if([@"NSDate" isEqualToString:compareSting])
                    [data appendString:[NSString stringWithFormat:@"\"%@\",",[DateHelper stringFromDate:object]]];
                else if([@"NSString" isEqualToString:compareSting])
                    [data appendString:[NSString stringWithFormat:@"\"%@\",",object]];
                else
                    [data appendString:[NSString stringWithFormat:@"%@,",object]];
            } else {
                [data appendString:@"NULL,"];
            }
        }
    }
    if([base hasSuffix:@","])
        [base replaceCharactersInRange:NSMakeRange(base.length-1, 1) withString:@")"];
    [base appendString:@" VALUES\n"];
    
    if([data hasSuffix:@","])
        [data replaceCharactersInRange:NSMakeRange(data.length-1, 1) withString:@")"];
    
    NSString *query = [NSString stringWithFormat:@"%@ %@",base,data];
    
    int *retorno = [DBManager runQueryForInt:query.UTF8String];
    if(retorno) {
        if([self.primaryKeyName isEqualToString:DEFAULT_PRIMARY_KEY])
            self.default_primary_key = [NSNumber numberWithInt:retorno[0]];
        free(retorno);
    }
}

-(void)updateModel {
    [self insertModel];
}

-(void)deleteModel {
    
}

-(NSString *)primaryKeyName {
    return DEFAULT_PRIMARY_KEY;
}

-(id)primaryKeyValue {
    return [self valueForKey:[self primaryKeyName]];
}

+(BOOL)isValidPropertyType:(NSString *)propertyType {
    if([@"i" isEqualToString:propertyType])
        return YES;
    else if([@"f" isEqualToString:propertyType])
        return YES;
    else if([@"d" isEqualToString:propertyType])
        return YES;
    else if([@"q" isEqualToString:propertyType])
        return YES;
    else if([@"NSDate" isEqualToString:propertyType])
        return YES;
    else if([@"NSString" isEqualToString:propertyType])
        return YES;
    
    return NO;
}

@end
