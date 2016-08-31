//
//  DOPEmployee.h
//  DynamicObjectParser
//
//  Created by Alexander Snigurskyi on 2016-08-31.
//  Copyright © 2016 Alexander Snigurskyi. All rights reserved.
//


#import "DOPBaseObject.h"


@class DOPPosition;
@class DOPTask;


@interface DOPEmployee : DOPBaseObject

@property (nonatomic, strong) NSString *firstname;
@property (nonatomic, strong) NSString *lastname;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) DOPPosition *position;
@property (nonatomic, strong) NSArray <DOPTask *> *tasks;

@end
