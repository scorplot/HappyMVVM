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
    
    __weak UIScrollView* _superView;
    UIEdgeInsets _insert;
    BOOL _isDraaging;
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
    _insert = UIEdgeInsetsZero;
}

-(void)lazySubView {
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

-(void)didMoveToSuperview {
    if (_superView != self.superview) {
        if (_superView != nil) {
            [_superView removeObserver:self forKeyPath:@"bounds"];
            [_superView removeObserver:self forKeyPath:@"contentInset"];
            [_superView removeObserver:self forKeyPath:@"contentOffset"];
        }
        
        UIEdgeInsets inset = _superView.contentInset;
        inset.top -= _insert.top;
        _superView.contentInset = inset;

        _superView = (UIScrollView*)self.superview;
        if ([_superView isKindOfClass:[UIScrollView class]]) {
            [_superView addObserver:self forKeyPath:@"bounds" options:0 context:nil];
            [_superView addObserver:self forKeyPath:@"contentInset" options:0 context:nil];
            [_superView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
            
            UIEdgeInsets inset = _superView.contentInset;
            CGRect rc = _superView.frame;
            self.frame = CGRectMake(0, -inset.top - self.frame.size.height+_insert.top, rc.size.width, self.frame.size.height);
            [self layoutSubviews];
        } else {
            _superView = nil;
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentInset"]) {
        UIEdgeInsets inset = _superView.contentInset;
        CGRect rc = _superView.frame;
        self.frame = CGRectMake(0, -inset.top - self.frame.size.height+_insert.top, rc.size.width, self.frame.size.height);
    } else if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint offset = _superView.contentOffset;
        if (-offset.y-_insert.top > self.frame.size.height) {
            _hint.text = NSLocalizedString(@"release to refesh", nil);
            if (_superView.isDragging != _isDraaging) {
                _isDraaging = _superView.isDragging;
                if (_superView.isDragging == NO) {
                    BOOL trigger = NO;
                    if (self.shouldTrigger) {
                        trigger = self.shouldTrigger();
                    }
                    self.refreshing = trigger;
                }
            }
        } else {
            _hint.text = NSLocalizedString(@"pull to refesh", nil);
        }
    } else if ([keyPath isEqualToString:@"bounds"]) {
        UIEdgeInsets inset = _superView.contentInset;
        CGRect rc = _superView.frame;
        self.frame = CGRectMake(0, -inset.top - self.frame.size.height+_insert.top, rc.size.width, self.frame.size.height);
        [self layoutIfNeeded];
    }
}

-(void)setRefreshing:(BOOL)refreshing {
    if (_refreshing != refreshing) {
        _refreshing = refreshing;
        
        [self lazySubView];
        
        UIEdgeInsets inset = _superView.contentInset;
        if (_refreshing) {
            [_indicator startAnimating];
            _insert = UIEdgeInsetsMake(self.frame.size.height, 0, 0, 0);
            _indicator.hidden = NO;
            _hint.hidden = YES;
            inset.top += _insert.top;
        } else {
            inset.top -= _insert.top;
            _insert = UIEdgeInsetsZero;
            _indicator.hidden = YES;
            _hint.hidden = NO;
        }
        _superView.contentInset = inset;
    }
}
-(BOOL)refreshing {
    return _refreshing;
}
@end
