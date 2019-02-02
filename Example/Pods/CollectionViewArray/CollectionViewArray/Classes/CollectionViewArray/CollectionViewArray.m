//
//  CollectionViewArray.m
//  Pods
//
//  Created by aruisi on 2017/7/19.
//
//

#import "CollectionViewArray.h"
#import "CollectionViewProtocolListener.h"
#import "objc/runtime.h"
#import <UIKit/UIKit.h>
@implementation CollectionViewArray

@end
void CollectionViewConnectArray(UICollectionView * _Nullable collectionView ,NSArray<NSObject*>* _Nullable dataSource,CollectionViewArray * _Nullable listener){
    CollectionViewProtocolListener * protocalListener =  [[CollectionViewProtocolListener alloc]init];
    protocalListener.listener = listener;
    protocalListener.dataSource= dataSource;
    protocalListener.collectionView = collectionView;
    collectionView.dataSource= protocalListener;
    collectionView.delegate= protocalListener;
    if ([[UIDevice currentDevice].systemVersion floatValue] >=10.0) {
        if (@available(iOS 10.0, *)) {
            collectionView.prefetchDataSource= protocalListener;
        } else {
            // Fallback on earlier versions
        }
    }
    static const void* key;
    objc_setAssociatedObject(collectionView, &key, protocalListener, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@implementation UICollectionView (UICollectionViewArray)

- (void)setCv_collectionViewArray:(CollectionViewArray *)cv_collectionViewArray
{
    if (cv_collectionViewArray == nil)
    {
        CollectionViewConnectArray(self, nil, nil);
    }
    else
    {
        CollectionViewConnectArray(self, self.cv_dataSource, cv_collectionViewArray);
    }
    objc_setAssociatedObject(self, @"cv_collectionViewArray", cv_collectionViewArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CollectionViewArray *)cv_collectionViewArray
{
    return objc_getAssociatedObject(self, @"cv_collectionViewArray");
}


- (void)setCv_dataSource:(NSArray<NSObject *> *)cv_dataSource
{
    if (cv_dataSource == nil)
    {
        CollectionViewConnectArray(self, nil, nil);
    }
    else
    {
        CollectionViewConnectArray(self, cv_dataSource, self.cv_collectionViewArray);
    }
    objc_setAssociatedObject(self, @"cv_dataSource", cv_dataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<NSObject *> *)cv_dataSource
{
    return objc_getAssociatedObject(self, @"cv_dataSource");
}

@end
