//
//  NSObject+DOPUtilities.h
//  DynamicObjectParser
//
//  Created by Alexander Snigurskyi on 2016-09-06.
//  Copyright © 2016 Alexander Snigurskyi. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <objc/runtime.h>


@interface NSObject (DOPUtilities)

+ (BOOL)isClass:(Class)classA subclassOf:(Class)classB;

+ (void)enumeratePropertiesOfClass:(Class)objectClass
                         withBlock:(void (^)(objc_property_t property, NSString *propertyName, Class class, BOOL *stop))block;
@end
