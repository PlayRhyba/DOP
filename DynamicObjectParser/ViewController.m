//
//  ViewController.m
//  DynamicObjectParser
//
//  Created by Alexander Snigurskyi on 2016-08-31.
//  Copyright © 2016 Alexander Snigurskyi. All rights reserved.
//


#import "ViewController.h"
#import "DOPCompany.h"


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
                NSLog(@"Company: %@", company.name);
            }
        }
    }
}

@end
