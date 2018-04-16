# CCUIModel

CCUIModel is A usefull libraray which make UI drived by model

How to use： 
    UI property with single model relation
        *directly make value：
            * UI property type is id：
            [CCUIModel makeRelation:^(void) {
                label.text = createNotifer(person, @"name").idValue;
            }];
            * UI property type is bool：
            [CCUIModel makeRelation:^(void) {
                label.hidden = createNotifer(person, @"display").idValue.boolValue;
            }];
            * Need to transfer model value:
            _label.text = [createNotifer(person, @"name") setTransfer:^id(id value) {
                return [NSString stringWithFormat:@"name:%@",value];
            }].idValue;
        * call method or selector when model value changed:
            * selector
                [createNotifer(person, @"name") makeRelation:self WithSelector:@selector(setText:)];
            * block
                [createNotifer(person, @"name") makeRelation:self withBlock:^(id value) {
                _label.text = value;
                    }];
    Sometimes UI propery will relate more than one model value：
    We need to set a transfer under this circumstances.
        * directly make value：

            CCUIModel* uimodel = createNotifer(person, @"name").with(createNotifer(person, @"age")).with(createNotifer(person, @"title"));
            [uimodel setTransfer3:^id(id name, id age, id title) {
                return [NSString stringWithFormat:@"name:%@ age:%@ title:%@", name, age, title];
            }];
            _label.text = uimodel.idValue;
        
        * notify to selector
            
            CCUIModel* uimodel = createNotifer(person, @"name").with(createNotifer(person, @"age")).with(createNotifer(person, @"title"));
            [uimodel setTransfer3:^id(id name, id age, id title) {
                return [NSString stringWithFormat:@"name:%@ age:%@ title:%@", name, age, title];
            }];
            [uimodel addBind:self WithSelector:@selector(setText:)];
        
        * notify to block
            
            CCUIModel* uimodel = createNotifer(person, @"name").with(createNotifer(person, @"age")).with(createNotifer(person, @"title"));
                [uimodel setTransfer3:^id(id name, id age, id title) {
            return [NSString stringWithFormat:@"name:%@ age:%@ title:%@", name, age, title];
            }];
            [uimodel addBind:self withBlock:^(id value) {
                _label.text = value;
            }];

    I have already init some propery default, If you need to make relation with new ui property, please do as following
    bool initListenerProperty(Class  cls, NSString* prop);
    init listener property




## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

CCUIModel is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod "CCUIModel"
```

## Author

aruisi, scorplot@aliyun.com

