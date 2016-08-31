//
//  DOPObject.h
//  DynamicObjectParser
//
//  Created by Alexander Snigurskyi on 2016-08-31.
//  Copyright © 2016 Alexander Snigurskyi. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <objc/runtime.h>


@interface DOPObject : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (BOOL)manualProcessingForProperty:(objc_property_t)property withName:(NSString *)propertyName;

- (void)processValueForProperty:(objc_property_t)property
                       withName:(NSString *)propertyName
                 fromDictionary:(NSDictionary *)dictionary;

- (Class)classOfObjectsInCollectionForProperty:(objc_property_t)property withName:(NSString *)propertyName;
- (NSDictionary *)dictionary;

@end
