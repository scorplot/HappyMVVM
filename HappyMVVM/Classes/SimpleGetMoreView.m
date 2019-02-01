//
//  SimpleGetMoreView.m
//  HappyMVVM
//
//  Created by Aruisi on 4/24/18.
//

#import "SimpleGetMoreView.h"

@implementation SimpleGetMoreView {
    BOOL _gettingMore;
    UIActivityIndicatorView* _indicator;
    UILabel* _hint;
}
@synthesize shouldTrigger;

-(instancetype)init {
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

-(void)setupView {
    if (_indicator == nil) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        CGRect rc = self.frame;
        _indicator.center = CGPointMake(rc.size.width/2, _indicator.frame.size.height/2);
        [_indicator stopAnimating];
        [self addSubview:_indicator];
    }
    
    if (_hint == nil) {
        _hint = [[UILabel alloc] init];
        _hint.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        CGRect rc = self.frame;
        rc.origin.x = 10;
        rc.size.width -= 20;
        rc.origin.y = 0;
        rc.size.height = rc.size.height;
        _hint.frame = rc;
        _hint.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_hint];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect rc = self.frame;
    _indicator.center = CGPointMake(rc.size.width/2, _indicator.frame.size.height/2);
    
    rc = self.frame;
    rc.origin.x = 10;
    rc.size.width -= 20;
    rc.origin.y = 0;
    rc.size.height = rc.size.height;
    _hint.frame = rc;
    _hint.textAlignment = NSTextAlignmentCenter;
}

-(void)scrollOffset:(CGFloat)offset {
    if (offset > self.offsetTrigger) {
        _hint.text = NSLocalizedString(@"release to get more", nil);
    } else {
        _hint.text = NSLocalizedString(@"pull to get more", nil);
    }
}


-(void)setGettingMore:(BOOL)gettingMore {
    if (_gettingMore != gettingMore) {
        _gettingMore = gettingMore;
        
        if (_gettingMore) {
            _indicator.hidden = NO;
            _hint.hidden = YES;
            [_indicator startAnimating];
        } else {
            _indicator.hidden = YES;
            _hint.hidden = NO;
        }
    }
}

-(BOOL)gettingMore {
    return _gettingMore;
}
-(CGFloat)offsetTrigger {
    return self.frame.size.height;
}

@end
