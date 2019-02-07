//
//  PropertyHelper.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface PropertyHelper : NSObject

+(const char *)getPropertyType:(objc_property_t) property;

@end
