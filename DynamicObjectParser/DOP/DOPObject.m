//
//  DOPObject.m
//  DynamicObjectParser
//
//  Created by Alexander Snigurskyi on 2016-08-31.
//  Copyright © 2016 Alexander Snigurskyi. All rights reserved.
//


#import "DOPObject.h"
#import <objc/runtime.h>


@interface DOPObject ()

+ (BOOL)isClass:(Class)classA subclassOf:(Class)classB;
- (void)fillPropertiesForClass:(Class)class withDictionary:(NSDictionary *)dictionary;

@end


@implementation DOPObject


#pragma mark - Public Methods


- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        [self fillPropertiesForClass:[self superclass] withDictionary:dictionary];
        [self fillPropertiesForClass:[self class] withDictionary:dictionary];
    }
    
    return self;
}


#pragma mark - Internal Logic


+ (BOOL)isClass:(Class)classA subclassOf:(Class)classB {
    while (classA) {
        if (classA == classB) {
            return YES;
        }
        
        classA = class_getSuperclass(classA);
    }
    
    return NO;
}


- (void)fillPropertiesForClass:(Class)class withDictionary:(NSDictionary *)dictionary {
    if (class && dictionary) {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList(class, &count);
        
        for (unsigned int i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
            
            id value = [dictionary objectForKey:propertyName];
            
            if (value) {
                NSString *attributesString = [NSString stringWithUTF8String:property_getAttributes(property)];
                NSString *attributes = [attributesString componentsSeparatedByString:@","].firstObject;
                
                if ([attributes hasPrefix:@"T@"]) {
                    NSArray *components = [attributes componentsSeparatedByString:@"\""];
                    
                    if (components.count > 0) {
                        NSString *classNameString = components[1];
                        Class class = NSClassFromString(classNameString);
                        
                        if (class != nil) {
                            if ([[self class] isClass:class subclassOf:[DOPObject class]] && [value isKindOfClass:[NSDictionary class]]) {
                                id object = [[class alloc]initWithDictionary:value];
                                [self setValue:object forKey:propertyName];
                            }
                            else if (class == [NSArray class]) {
                                
                                
                                //TODO: Handle arrays
                                
                                
                            }
                            else if ([value isKindOfClass:class]) {
                                [self setValue:value forKey:propertyName];
                            }
                        }
                    }
                }
            }
        }
    }
}

@end
