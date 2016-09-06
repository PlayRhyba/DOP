//
//  NSObject+DOPUtilities.m
//  DynamicObjectParser
//
//  Created by Alexander Snigurskyi on 2016-09-06.
//  Copyright © 2016 Alexander Snigurskyi. All rights reserved.
//


#import "NSObject+DOPUtilities.h"


@implementation NSObject (DOPUtilities)


+ (BOOL)isClass:(Class)classA subclassOf:(Class)classB {
    while (classA) {
        if (classA == classB) {
            return YES;
        }
        
        classA = class_getSuperclass(classA);
    }
    
    return NO;
}


+ (void)enumeratePropertiesOfClass:(Class)objectClass
                         withBlock:(void (^)(objc_property_t property, NSString *propertyName, Class class, BOOL *stop))block {
    if (objectClass && block) {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList(objectClass, &count);
        
        for (unsigned int i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
            
            NSString *attributesString = [NSString stringWithUTF8String:property_getAttributes(property)];
            NSString *attributes = [attributesString componentsSeparatedByString:@","].firstObject;
            
            if ([attributes hasPrefix:@"T@"]) {
                NSArray *components = [attributes componentsSeparatedByString:@"\""];
                
                if (components.count > 0) {
                    NSString *classNameString = components[1];
                    Class class = NSClassFromString(classNameString);
                    
                    if (class != nil) {
                        BOOL stop = NO;
                        block(property, propertyName, class, &stop);
                        if (stop) break;
                    }
                }
            }
        }
    }
}

@end
