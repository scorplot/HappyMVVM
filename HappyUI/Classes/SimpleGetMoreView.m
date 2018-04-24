//
//  SimpleGetMoreView.m
//  CCUIModel
//
//  Created by Aruisi on 4/24/18.
//

#import "SimpleGetMoreView.h"

@implementation SimpleGetMoreView {
    BOOL _gettingMore;
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

-(void)didMoveToSuperview {
    if (_superView != self.superview) {
        if (_superView != nil) {
            [_superView removeObserver:self forKeyPath:@"bounds"];
            [_superView removeObserver:self forKeyPath:@"contentSize"];
            [_superView removeObserver:self forKeyPath:@"contentInset"];
            [_superView removeObserver:self forKeyPath:@"contentOffset"];
        }
        
        UIEdgeInsets inset = _superView.contentInset;
        inset.bottom -= _insert.bottom;
        _superView.contentInset = inset;

        _superView = (UIScrollView*)self.superview;
        if ([_superView isKindOfClass:[UIScrollView class]]) {
            [_superView addObserver:self forKeyPath:@"bounds" options:0 context:nil];
            [_superView addObserver:self forKeyPath:@"contentSize" options:0 context:nil];
            [_superView addObserver:self forKeyPath:@"contentInset" options:0 context:nil];
            [_superView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
            _isDraaging = NO;
            
            [self lazySubView];
            [self layoutIfNeeded];
        } else {
            _superView = nil;
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        UIEdgeInsets inset = _superView.contentInset;
        CGRect rc = _superView.frame;
        self.frame = CGRectMake(0, _superView.contentSize.height+inset.bottom, rc.size.width, self.frame.size.height);
    } else if ([keyPath isEqualToString:@"contentInset"]) {
        UIEdgeInsets inset = _superView.contentInset;
        CGRect rc = _superView.frame;
        self.frame = CGRectMake(0, _superView.contentSize.height+inset.bottom, rc.size.width, self.frame.size.height);
    } else if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint offset = _superView.contentOffset;
        if (offset.y > _superView.contentSize.height + _insert.bottom - _superView.frame.size.height + self.frame.size.height) {
            _hint.text = NSLocalizedString(@"release to get more", nil);
            if (_superView.isDragging != _isDraaging) {
                _isDraaging = _superView.isDragging;
                if (_superView.isDragging == NO) {
                    BOOL trigger = NO;
                    if (self.shouldTrigger) {
                        trigger = self.shouldTrigger();
                    }
                    self.gettingMore = trigger;
                }
            }
        } else {
            _hint.text = NSLocalizedString(@"pull to get more", nil);
        }
    } else if ([keyPath isEqualToString:@"bounds"]) {
        UIEdgeInsets inset = _superView.contentInset;
        CGRect rc = _superView.frame;
        self.frame = CGRectMake(0, _superView.contentSize.height+inset.bottom, rc.size.width, self.frame.size.height);
    }
}

-(void)setGettingMore:(BOOL)gettingMore {
    if (_gettingMore != gettingMore) {
        _gettingMore = gettingMore;
        
        [self lazySubView];
        
        UIEdgeInsets inset = _superView.contentInset;
        if (_gettingMore) {
            _insert = UIEdgeInsetsMake(0, 0, self.frame.size.height, 0);
            _indicator.hidden = NO;
            _hint.hidden = YES;
            inset.bottom += _insert.bottom;
        } else {
            inset.bottom -= _insert.bottom;
            _insert = UIEdgeInsetsZero;
            _indicator.hidden = YES;
            _hint.hidden = NO;
        }
        _superView.contentInset = inset;
    }
}

-(BOOL)gettingMore {
    return _gettingMore;
}
@end
