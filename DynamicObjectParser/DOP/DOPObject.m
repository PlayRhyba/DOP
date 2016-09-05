//
//  DOPObject.m
//  DynamicObjectParser
//
//  Created by Alexander Snigurskyi on 2016-08-31.
//  Copyright © 2016 Alexander Snigurskyi. All rights reserved.
//


#import "DOPObject.h"


@interface DOPObject ()

@property (nonatomic, strong) NSMutableDictionary *initialState;

+ (BOOL)isClass:(Class)classA subclassOf:(Class)classB;

+ (void)enumeratePropertiesOfClass:(Class)objectClass
                         withBlock:(void (^)(objc_property_t property, NSString *propertyName, Class class, BOOL *stop))block;

- (void)fillPropertiesForClass:(Class)class withDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)fullDictionary;
- (NSDictionary *)changedDictionary;

@end


@implementation DOPObject


#pragma mark - Getters/Setters


- (NSMutableDictionary *)initialState {
    if (_initialState == nil) {
        _initialState = [NSMutableDictionary dictionary];
    }
    
    return _initialState;
}


#pragma mark - Public Methods


- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        [self fillPropertiesForClass:[self superclass] withDictionary:dictionary];
        [self fillPropertiesForClass:[self class] withDictionary:dictionary];
    }
    
    return self;
}


- (NSDictionary *)dictionaryWithSerializationMode:(DOPObjectSerializationMode)serializationMode {
    switch (serializationMode) {
        case DOPObjectSerializationModeFull: {
            return [self fullDictionary];
        }
        case DOPObjectSerializationModeChangedOnly: {
            if ([self trackObjectChanges]) {
                return [self changedDictionary];
            }
            else {
                return [self fullDictionary];
            }
        }
    }
}


- (BOOL)changed {
    if ([self trackObjectChanges]) {
        
        
        //TODO: Check if some properties have been changed
        
        
    }
    
    return NO;
}


#pragma mark - Configuration


- (BOOL)manualProcessingForProperty:(objc_property_t)property withName:(NSString *)propertyName {
    return NO;
}


- (BOOL)trackObjectChanges {
    return NO;
}


- (void)processValueForProperty:(objc_property_t)property
                       withName:(NSString *)propertyName
                 fromDictionary:(NSDictionary *)dictionary {}


- (Class)classOfObjectsInCollectionForProperty:(objc_property_t)property withName:(NSString *)propertyName {
    return nil;
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


- (void)fillPropertiesForClass:(Class)class withDictionary:(NSDictionary *)dictionary {
    if (class && dictionary) {
        [[self class]enumeratePropertiesOfClass:class
                                      withBlock:^(objc_property_t property, NSString *propertyName, __unsafe_unretained Class class, BOOL *stop) {
                                          id value = [dictionary objectForKey:propertyName];
                                          
                                          if (value) {
                                              if ([[self class] isClass:class subclassOf:[DOPObject class]] && [value isKindOfClass:[NSDictionary class]]) {
                                                  id newValue = [[class alloc]initWithDictionary:value];
                                                  [self setValue:newValue forKey:propertyName];
                                              }
                                              else if (class == [NSArray class] && [value isKindOfClass:[NSArray class]]) {
                                                  Class objectsClass = [self classOfObjectsInCollectionForProperty:property withName:propertyName];
                                                  
                                                  if (objectsClass && [[self class] isClass:objectsClass subclassOf:[DOPObject class]]) {
                                                      NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[(NSArray *)value count]];
                                                      
                                                      for (id obj in (NSArray *)value) {
                                                          if ([obj isKindOfClass:[NSDictionary class]]) {
                                                              id object = [[objectsClass alloc]initWithDictionary:(NSDictionary *)obj];
                                                              
                                                              if (object) {
                                                                  [objects addObject:object];
                                                              }
                                                          }
                                                      }
                                                      
                                                      [self setValue:objects forKey:propertyName];
                                                  }
                                              }
                                              else if ([value isKindOfClass:class]) {
                                                  [self setValue:value forKey:propertyName];
                                                  
                                                  if ([self trackObjectChanges]) {
                                                      self.initialState[propertyName] = value;
                                                  }
                                              }
                                          }
                                      }];
    }
}


- (NSDictionary *)fullDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    
    //TODO: Serialize full object to dictionary
    
    
    return result;
}


- (NSDictionary *)changedDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    
    //TODO: Serialize only changed properties to dictionary
    
    
    return result;
}

@end
