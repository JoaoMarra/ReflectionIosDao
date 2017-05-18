//
//  Delete.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 18/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeleteQueryTransaction.h"

@interface Delete<ObjectType> : NSObject

+(DeleteQueryTransaction<ObjectType> *) from:(ObjectType)type;

@end
