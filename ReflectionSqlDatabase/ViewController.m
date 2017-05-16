//
//  ViewController.m
//  ReflectionSqlDatabase
//
//  Created by Mais App on 16/05/17.
//  Copyright © 2017 marraware. All rights reserved.
//

#import "ViewController.h"
#import "TestModel.h"
#import "DBManager.h"
#import "Select.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [DBManager dropTable:TestModel.class];
    [DBManager createTable:TestModel.class];
    
    TestModel *model = [TestModel new];
    model.string = @"VALUE";
    model.intVal = 0;
    model.floatVal = 1;
    model.doubleVal = 2;
    model.longVal = 3;
    model.date = [NSDate new];
    [model insertModel];
    [model insertModel];
    [model insertModel];
    
    NSArray<TestModel *> *array = [Select from:TestModel.class].execute;
    NSLog(@"END PROGRAM");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
