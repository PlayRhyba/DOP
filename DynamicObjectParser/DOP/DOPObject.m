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
                                           BOOL shouldBeAdded = YES;
                                           
                                           if (serializationMode == DOPObjectSerializationModeChangedOnly) {
                                               shouldBeAdded = [(DOPObject *)value changed];
                                           }
                                           
                                           if (shouldBeAdded) {
                                               NSDictionary *dictionary = [(DOPObject *)value dictionaryWithSerializationMode:serializationMode];
                                               result[propertyName] = dictionary;
                                           }
                                       }
                                       else if (class == [NSArray class] && [value isKindOfClass:[NSArray class]]) {
                                           BOOL shouldBeAdded = YES;
                                           
                                           if (serializationMode == DOPObjectSerializationModeChangedOnly) {
                                               
                                               
                                               //TODO: Check value changed
                                               
                                               
                                           }
                                           
                                           if (shouldBeAdded) {
                                               NSMutableArray *dictionaries = [NSMutableArray arrayWithCapacity:[(NSArray *)value count]];
                                               
                                               for (id obj in (NSArray *)value) {
                                                   if ([obj isKindOfClass:[DOPObject class]]) {
                                                       NSDictionary *dictionary = [(DOPObject *)obj dictionaryWithSerializationMode:serializationMode];
                                                       [dictionaries addObject:dictionary];
                                                   }
                                               }
                                               
                                               result[propertyName] = dictionaries;
                                           }
                                       }
                                       else if (value == nil || [value isKindOfClass: class]) {
                                           BOOL shouldBeAdded = YES;
                                           
                                           if (serializationMode == DOPObjectSerializationModeChangedOnly) {
                                               
                                               
                                               //TODO: Check value changed
                                               
                                               
                                           }
                                           
                                           if (shouldBeAdded) {
                                               result[propertyName] = value ?: [NSNull null];
                                           }
                                       }
                                   }];
    }
    
    return result;
}


- (NSDictionary *)fullDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    [result addEntriesFromDictionary:[self dictionaryWithSerializationMode:DOPObjectSerializationModeFull
                                                                  forClass:[self superclass]]];
    
    [result addEntriesFromDictionary:[self dictionaryWithSerializationMode:DOPObjectSerializationModeFull
                                                                  forClass:[self class]]];
    return result;
}


- (NSDictionary *)changedDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    [result addEntriesFromDictionary:[self dictionaryWithSerializationMode:DOPObjectSerializationModeChangedOnly
                                                                  forClass:[self superclass]]];
    
    [result addEntriesFromDictionary:[self dictionaryWithSerializationMode:DOPObjectSerializationModeChangedOnly
                                                                  forClass:[self class]]];
    return result;
}

@end
