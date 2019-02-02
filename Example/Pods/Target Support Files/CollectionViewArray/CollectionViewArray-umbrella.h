#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "UICollectionView+CCUIModel.h"
#import "CollectionViewArray.h"
#import "CollectionViewProtocolListener.h"

FOUNDATION_EXPORT double CollectionViewArrayVersionNumber;
FOUNDATION_EXPORT const unsigned char CollectionViewArrayVersionString[];

