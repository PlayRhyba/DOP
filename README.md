# DOP

The simple code illustrating the approach of objects' initialization, based on declared properties. Thanks for the dynamic nature of objC, sometimes it's possible to avoid the code like
```objc
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _object1 = dictionary[@"object1"];
        ...
    }

    return self;
}
```
in each of model and provide some universal soluton. The same is true for serrialization the object back to dictionary.

In this case everithing that should be done to describe model is to declare properies and inform the superclass about types of elements in collections
```objc
- (Class)classOfObjectsInCollectionForProperty:(objc_property_t)property withName:(NSString *)propertyName {
    if ([propertyName isEqualToString:kEmployees]) {
        return [DOPEmployee class];
    }

    return [super classOfObjectsInCollectionForProperty:property withName:propertyName];
}
```
For sure, sometimes during initialization it may be helpful to have possibility to take the whole responsibility for manual processing of some property
```objc
- (BOOL)manualProcessingForProperty:(objc_property_t)property withName:(NSString *)propertyName;

- (void)processValueForProperty:(objc_property_t)property
                       withName:(NSString *)propertyName
                 fromDictionary:(NSDictionary *)dictionary;
```
