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
    model.intVal = 1;
    model.floatVal = 1;
    model.doubleVal = 1;
    model.longVal = 1;
    model.date = [NSDate new];
    [model insertModel];
    
    model.string = @"VALUE2";
    model.intVal = 2;
    model.floatVal = 2;
    model.doubleVal = 2;
    model.longVal = 2;
    [model insertModel];
    
    model.string = @"VALUE3";
    model.intVal = 3;
    model.floatVal = 3;
    model.doubleVal = 3;
    model.longVal = 3;
    [model insertModel];
    
    NSArray<TestModel *> *array = [[[[[[Select from:TestModel.class]
                                    where:@"string" value:@"VALUE%" comparation:LIKE]
                                    where:@"intVal" value:[NSNumber numberWithInt:1] comparation:MORE_THAN]
                                    orderBy:@"longVal" order:DESCENDING]
                                    limit:1]
                                    execute];
    array = [[[Select from:TestModel.class]
                                    where:@"string" value:@"VALUE" comparation:EQUAL]
                                    execute];
    NSLog(@"END PROGRAM");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
