//
//  DOPObject.m
//  DynamicObjectParser
//
//  Created by Alexander Snigurskyi on 2016-08-31.
//  Copyright © 2016 Alexander Snigurskyi. All rights reserved.
//


#import "DOPObject.h"
#import "NSObject+DOPUtilities.h"


@interface DOPObject ()

@property (nonatomic, strong) NSMutableDictionary *initialState;

- (void)fillPropertiesForClass:(Class)class withDictionary:(NSDictionary *)dictionary;

- (NSMutableDictionary *)dictionaryWithSerializationMode:(DOPObjectSerializationMode)serializationMode
                                                forClass:(Class)class;

- (BOOL)isValueChanged:(id)currentValue propertyName:(NSString *)propertyName;

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


- (NSMutableDictionary *)dictionaryWithSerializationMode:(DOPObjectSerializationMode)serializationMode {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    if ((serializationMode == DOPObjectSerializationModeChangedOnly) && ([self trackObjectChanges] == NO)) {
        return result;
    }
    
    [result addEntriesFromDictionary:[self dictionaryWithSerializationMode:serializationMode
                                                                  forClass:[self superclass]]];
    
    [result addEntriesFromDictionary:[self dictionaryWithSerializationMode:serializationMode
                                                                  forClass:[self class]]];
    return result;
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


- (void)fillPropertiesForClass:(Class)class withDictionary:(NSDictionary *)dictionary {
    if (class && class != [DOPObject class] && dictionary) {
        [NSObject enumeratePropertiesOfClass:class
                                   withBlock:^(objc_property_t property, NSString *propertyName, __unsafe_unretained Class class, BOOL *stop) {
                                       id value = [dictionary objectForKey:propertyName];
                                       
                                       if (value) {
                                           if ([NSObject isClass:class subclassOf:[DOPObject class]] && [value isKindOfClass:[NSDictionary class]]) {
                                               id newValue = [[class alloc]initWithDictionary:value];
                                               [self setValue:newValue forKey:propertyName];
                                           }
                                           else if (class == [NSArray class] && [value isKindOfClass:[NSArray class]]) {
                                               Class objectsClass = [self classOfObjectsInCollectionForProperty:property withName:propertyName];
                                               
                                               if (objectsClass && [NSObject isClass:objectsClass subclassOf:[DOPObject class]]) {
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


- (NSMutableDictionary *)dictionaryWithSerializationMode:(DOPObjectSerializationMode)serializationMode
                                                forClass:(Class)class {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    if (class && class != [DOPObject class]) {
        [NSObject enumeratePropertiesOfClass:class
                                   withBlock:^(objc_property_t property, NSString *propertyName, __unsafe_unretained Class class, BOOL *stop) {
                                       id value = [self valueForKey:propertyName];
                                       
                                       if ([NSObject isClass:class subclassOf:[DOPObject class]] && [value isKindOfClass:[DOPObject class]]) {
                                           NSDictionary *dictionary = [(DOPObject *)value dictionaryWithSerializationMode:serializationMode];
                                           
                                           if (dictionary.count > 0) {
                                               result[propertyName] = dictionary;
                                           }
                                       }
                                       else if (class == [NSArray class] && [value isKindOfClass:[NSArray class]]) {
                                           NSMutableArray *dictionaries = [NSMutableArray arrayWithCapacity:[(NSArray *)value count]];
                                           
                                           for (id obj in (NSArray *)value) {
                                               if ([obj isKindOfClass:[DOPObject class]]) {
                                                   NSDictionary *dictionary = [(DOPObject *)obj dictionaryWithSerializationMode:serializationMode];
                                                   
                                                   if (dictionary.count > 0) {
                                                       [dictionaries addObject:dictionary];
                                                   }
                                               }
                                           }
                                           
                                           if (dictionaries.count > 0) {
                                               result[propertyName] = dictionaries;
                                           }
                                       }
                                       else if (value == nil || [value isKindOfClass: class]) {
                                           BOOL shouldBeAdded = YES;
                                           
                                           if (serializationMode == DOPObjectSerializationModeChangedOnly) {
                                               shouldBeAdded = [self isValueChanged:value propertyName:propertyName];
                                           }
                                           
                                           if (shouldBeAdded) {
                                               result[propertyName] = value ?: [NSNull null];
                                           }
                                       }
                                   }];
    }
    
    return result;
}


- (BOOL)isValueChanged:(id)currentValue propertyName:(NSString *)propertyName {
    if ([self trackObjectChanges]) {
        id oldValue = self.initialState[propertyName];
        
        if ((oldValue == nil && [currentValue isKindOfClass:[NSNull class]]) ||
            (currentValue == nil && [oldValue isKindOfClass:[NSNull class]]) ||
            ((currentValue == nil) && (oldValue == nil)) ||
            ([currentValue isKindOfClass:[NSNull class]] && [oldValue isKindOfClass:[NSNull class]])) {
            return NO;
        }
        
        BOOL changed = ((oldValue == nil) && currentValue) || ((currentValue == nil) && oldValue);
        changed = changed || ((oldValue && currentValue) && ([oldValue isEqual:currentValue] == NO));
        return changed;
    }
    
    return NO;
}

@end
