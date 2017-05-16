//
//  Select.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SelectQueryTransaction.h"

@interface Select<ObjectType> : NSObject

+(SelectQueryTransaction<ObjectType> *) from:(ObjectType)type;

@end
