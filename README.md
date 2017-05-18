# ReflectionDao
SQLite library for iOS using reflection written on Objective C. The central ideia is to simplify the creation of DAO classes, and **no need for complex configurations**.

# How to use

Here is some example of DAO classes used on the examples below:

```objective-c
//PersonModel.h
@interface PersonModel : DaoModel

@property(nonatomic, strong) NSString *rg;
@property(nonatomic, strong) NSString *name;
@property(nonatomic) int age;
@property(nonatomic, strong) NSDate *birth;

@end

//PersonModel.m
@implementation PersonModel

-(NSString *)primaryKeyName {
    return @"rg";
}

@end

//AddressModel.h
@interface AddressModel : DaoModel

@property(nonatomic, strong) NSString *rgPerson;
@property(nonatomic, strong) NSString *stringAddress;

@end
```

`@-(NSString *)primaryKeyName` return the name of the property that represents the pirmary key of the table. If you don\`t indicate it, the library will create an default Number id that can be accessed with the method `-(id)primaryKeyValue` and `-(NSString *)primaryKeyName` to access the column name.

To initiate you data base use the `DBManagerDelegate` and `+(void)initDB:(id<DBManagerDelegate>)delegate` from `DBManager` class:

```objective-c
@interface AppDelegate ()<DBManagerDelegate>

...

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DBManager initDB:self];
    return YES;
}

...

#pragma mark - DBManagerDelegate methods

//return db scheme version
-(int)dbSchemeVersion {
    return 1;
}
//return an array of Dao Classes
-(NSArray<Class> *)dbDaoClasses {
    return @[PersonModel.class, AddressModel.class];
}

//do something after create or update db - @optional
-(void)dbPostCreationOrUpdate {

}
```
Drop, Create and Alter tables are all managed by the library.

# Usage examples

You can use the lib directly from the model class or using Query Classes. Here is some examples:

```objective-c
    PersonModel *person = [PersonModel new];
    person.rg = @"rg";
    person.name = @"Pedro";
    person.age = 16;
    person.birth = [NSDate new];
    [person insertModel];
    
    AddressModel *address = [AddressModel new];
    address.rgPerson = @"rg";
    address.stringAddress = @"somewhere";
    [address insertModel];
    
    ...
    
    [person delete]; //delete the person
```
Query using Query Classes

```objective-c
    NSArray<AddressModel *> *addresses = [[[[Select from:AddressModel.class]
                                            where:@"rgPerson" value:@"rg" comparation:EQUAL]
                                            orderBy:DEFAULT_PRIMARY_KEY order:DESCENDING]
                                            limit:5].execute;
                                    
    ...
    
    int del = [Delete from:PersonModel.class].execute;
          
```
