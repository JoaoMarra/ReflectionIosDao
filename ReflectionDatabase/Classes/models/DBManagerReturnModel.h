//
//  DBManagerReturnModel.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 08/02/2019.
//  Copyright © 2019 marraware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManagerReturnModel : NSObject

@property (nonatomic) long long lastInsertedRowID;
@property (nonatomic) int affectedRows;

@end
