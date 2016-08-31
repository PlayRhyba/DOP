//
//  DOPContacts.h
//  DynamicObjectParser
//
//  Created by Alexander Snigurskyi on 2016-08-31.
//  Copyright © 2016 Alexander Snigurskyi. All rights reserved.
//


#import "DOPBaseObject.h"


@interface DOPContacts : DOPBaseObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone;

@end
