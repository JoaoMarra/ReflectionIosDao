//
//  ViewController.m
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import "ViewController.h"
#import "PersonModel.h"
#import "AddressModel.h"
#import "DBManager.h"
#import "Select.h"

@interface ViewController ()<DBManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [DBManager setDebugMode:YES];
    [DBManager initDB:self];
    
    PersonModel *model = [PersonModel new];
    model.rg = @"rg";
    model.name = @"Pedro";
    model.age = 16;
    model.birth = [NSDate new];
    [model insertModel];
    AddressModel *address = [AddressModel new];
    address.rgPerson = @"rg";
    address.stringAddress = @"rua 1, bairro 1, cidade 1 - 1";
    [address insertModel];
    address.stringAddress = @"NOVO";
    [address updateModel];
    
    NSLog(@"PERSON - %d",[DBManager rowCount:PersonModel.class]);
    NSLog(@"ADDRESS - %d",[DBManager rowCount:AddressModel.class]);
    
    NSArray<AddressModel *> *addresses = [[[[Select from:AddressModel.class]
                                            where:@"rgPerson" value:@"rg" comparation:EQUAL]
                                           orderBy:DEFAULT_PRIMARY_KEY order:DESCENDING]
                                          limit:5].execute;
    
    NSLog(@"END PROGRAM");
}


#pragma mark - DBManagerDelegate methods

-(int)dbSchemeVersion {
    return 1;
}

-(NSArray<Class> *)dbDaoClasses {
    return @[PersonModel.class, AddressModel.class];
}

-(void)dbPostCreationOrUpdate {
    
}


@end
