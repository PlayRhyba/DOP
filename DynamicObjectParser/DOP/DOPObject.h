//
//  DOPObject.h
//  DynamicObjectParser
//
//  Created by Alexander Snigurskyi on 2016-08-31.
//  Copyright © 2016 Alexander Snigurskyi. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <objc/runtime.h>


typedef NS_ENUM(NSUInteger, DOPObjectSerializationMode) {
    DOPObjectSerializationModeFull,
    DOPObjectSerializationModeChangedOnly,
};


@interface DOPObject : NSObject


#pragma mark - Public Methods


- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryWithSerializationMode:(DOPObjectSerializationMode)serializationMode;
- (BOOL)changed;


#pragma mark - Configuration


- (BOOL)manualProcessingForProperty:(objc_property_t)property withName:(NSString *)propertyName;
- (BOOL)trackObjectChanges;

- (void)processValueForProperty:(objc_property_t)property
                       withName:(NSString *)propertyName
                 fromDictionary:(NSDictionary *)dictionary;

- (Class)classOfObjectsInCollectionForProperty:(objc_property_t)property withName:(NSString *)propertyName;

@end
