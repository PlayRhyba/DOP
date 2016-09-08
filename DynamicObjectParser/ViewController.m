//
//  ViewController.m
//  DynamicObjectParser
//
//  Created by Alexander Snigurskyi on 2016-08-31.
//  Copyright © 2016 Alexander Snigurskyi. All rights reserved.
//


#import "ViewController.h"
#import "DOPCompany.h"
#import "DOPContacts.h"
#import "DOPEmployee.h"
#import "DOPPosition.h"
#import "DOPTask.h"


static NSString * const kTestDataPath = @"testData.json";


@interface ViewController ()
@end


@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle]pathForResource:[kTestDataPath stringByDeletingPathExtension]
                                                    ofType:[kTestDataPath pathExtension]];
    
    if (path) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        if (data) {
            NSError *error = nil;
            
            id result = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
            if (error) {
                NSLog(@"Parsing test json file error: %@", error.localizedDescription);
            }
            else if ([result isKindOfClass:[NSDictionary class]]) {
                DOPCompany *company = [[DOPCompany alloc]initWithDictionary:(NSDictionary *)result];
                NSDictionary *fullSerialization = [company dictionaryWithSerializationMode:DOPObjectSerializationModeFull];
                
                NSLog(@"OBJECT FULL: %@", fullSerialization);
                
                company.name = @"Apple";
                company.contacts.phone = @"222-222-222";
                
                company.employees.firstObject.age = @50;
                company.employees.firstObject.position.salary = @70000;
                company.employees.firstObject.tasks.firstObject.title = @"Playing guitar";
                
                NSDictionary *changedOnlySerialization = [company dictionaryWithSerializationMode:DOPObjectSerializationModeChangedOnly];
                
                NSLog(@"CHANGES: %@", changedOnlySerialization);
            }
        }
    }
}

@end
