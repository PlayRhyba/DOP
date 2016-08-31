//
//  DOPCompany.m
//  DynamicObjectParser
//
//  Created by Alexander Snigurskyi on 2016-08-31.
//  Copyright © 2016 Alexander Snigurskyi. All rights reserved.
//


#import "DOPCompany.h"
#import "DOPEmployee.h"


static NSString * const kEmployees = @"employees";


@implementation DOPCompany


#pragma mark - DOPObject


- (Class)classOfObjectsInCollectionForProperty:(objc_property_t)property withName:(NSString *)propertyName {
    if ([propertyName isEqualToString:kEmployees]) {
        return [DOPEmployee class];
    }
    
    return [super classOfObjectsInCollectionForProperty:property withName:propertyName];
}

@end
