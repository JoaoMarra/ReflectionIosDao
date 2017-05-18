//
//  DeleteQueryTransaction.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 18/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WhereQueryTransaction.h"

@interface DeleteQueryTransaction<ObjectType> : WhereQueryTransaction<ObjectType>

-(int)execute;

@end
