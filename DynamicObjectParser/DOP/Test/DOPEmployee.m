//
//  DOPEmployee.m
//  DynamicObjectParser
//
//  Created by Alexander Snigurskyi on 2016-08-31.
//  Copyright © 2016 Alexander Snigurskyi. All rights reserved.
//


#import "DOPEmployee.h"
#import "DOPTask.h"


static NSString * const kTasks = @"tasks";


@implementation DOPEmployee


#pragma mark - DOPObject


- (Class)classOfObjectsInCollectionForProperty:(objc_property_t)property withName:(NSString *)propertyName {
    if ([propertyName isEqualToString:kTasks]) {
        return [DOPTask class];
    }
    
    return [super classOfObjectsInCollectionForProperty:property withName:propertyName];
}

@end
