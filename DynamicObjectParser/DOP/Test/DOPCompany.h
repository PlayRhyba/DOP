//
//  DOPCompany.h
//  DynamicObjectParser
//
//  Created by Alexander Snigurskyi on 2016-08-31.
//  Copyright © 2016 Alexander Snigurskyi. All rights reserved.
//


#import "DOPBaseObject.h"


@class DOPContacts;
@class DOPEmployee;


@interface DOPCompany : DOPBaseObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) DOPContacts *contacts;
@property (nonatomic, strong) NSArray <DOPEmployee *> *employees;

@end
