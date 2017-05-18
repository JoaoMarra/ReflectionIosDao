//
//  Address.h
//  ReflectionSqlDatabase
//
//  Created by Mais App on 17/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DaoModel.h"

@interface AddressModel : DaoModel

@property(nonatomic, strong) NSString *rgPerson;
@property(nonatomic, strong) NSString *stringAddress;

@end
