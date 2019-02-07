//
//  WhereNode.m
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import "WhereNode.h"
#import "DateHelper.h"

@implementation WhereNode

-(instancetype)initWithColumnName:(NSString *)column value:(id)value comparation:(WHERE_COMPARATION)comparation {
    self = [self init];
    self.column = column;
    self.value = value;
    self.whereComparation = comparation;
    
    return self;
}

-(NSString *)stringValue {
    
    NSString *valueString;
    if([self.value isKindOfClass:NSString.class])
        valueString = [NSString stringWithFormat:@"\"%@\"",self.value];
     else if([self.value isKindOfClass:NSDate.class])
        valueString = [NSString stringWithFormat:@"\"%@\"",[DateHelper stringFromDate:self.value]];
     else
         valueString = [NSString stringWithFormat:@"%@",self.value];
    
    return [NSString stringWithFormat:@" %@ %@ %@ ",self.column, [QueryHelper whereComparationToString:self.whereComparation], valueString];
}

@end
