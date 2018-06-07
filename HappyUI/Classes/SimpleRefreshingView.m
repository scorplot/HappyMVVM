//
//  SimpleRefreshingView.m
//  CCUIModel
//
//  Created by Aruisi on 4/24/18.
//

#import "SimpleRefreshingView.h"

@implementation SimpleRefreshingView {
    BOOL _refreshing;
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
        [_indicator startAnimating];
        [self addSubview:_indicator];
    }
    
    if (_hint == nil) {
        _hint = [[UILabel alloc] init];
        _hint.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
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
        _hint.text = NSLocalizedString(@"release to refesh", nil);
    } else {
        _hint.text = NSLocalizedString(@"pull to refesh", nil);
    }
}

-(void)setRefreshing:(BOOL)refreshing {
    if (_refreshing != refreshing) {
        _refreshing = refreshing;
        
        if (_refreshing) {
            _indicator.hidden = NO;
            _hint.hidden = YES;
        } else {
            _indicator.hidden = YES;
            _hint.hidden = NO;
        }
        
        if (_refreshing) {
            [_indicator startAnimating];
        }
    }
}
-(BOOL)refreshing {
    return _refreshing;
}
@end
