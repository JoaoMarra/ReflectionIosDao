//
//  ViewController.m
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import "ViewController.h"
#import "PersonModel.h"
#import "DBManager.h"
#import "Select.h"

@interface ViewController ()<DBManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [DBManager setDebugMode:YES];
    [DBManager initDB:self];
    NSLog(@"END PROGRAM");
}


#pragma mark - DBManagerDelegate methods

-(int)dbSchemeVersion {
    return 1;
}

-(NSArray<Class> *)dbDaoClasses {
    return @[PersonModel.class];
}

-(void)dbPostCreationOrUpdate {
    PersonModel *model = [PersonModel new];
    model.rg = @"rg";
    model.name = @"Pedro";
    model.age = 16;
    model.birth = [NSDate new];
    [model insertModel];
    
    //NSArray<PersonModel *> *array = [Select from:PersonModel.class].execute;
    //NSLog(@"ARRAY - %lu",(unsigned long)array.count);
}


@end
