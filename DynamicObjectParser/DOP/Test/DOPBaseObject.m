//
//  DOPBaseObject.m
//  DynamicObjectParser
//
//  Created by Alexander Snigurskyi on 2016-08-31.
//  Copyright © 2016 Alexander Snigurskyi. All rights reserved.
//


#import "DOPBaseObject.h"


static NSString * const kId = @"id";


@implementation DOPBaseObject


#pragma mark - DOPObject


- (NSMutableDictionary *)dictionaryWithSerializationMode:(DOPObjectSerializationMode)serializationMode {
    NSMutableDictionary *dictionary = [super dictionaryWithSerializationMode:serializationMode];
    
    if (serializationMode == DOPObjectSerializationModeChangedOnly && dictionary.count > 0) {
        if (_id) {
            dictionary[kId] = _id;
        }
    }
    
    return dictionary;
}


- (BOOL)trackObjectChanges {
    return YES;
}

@end
