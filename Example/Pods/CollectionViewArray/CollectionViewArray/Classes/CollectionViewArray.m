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
void CollectionViewConnectArray(UICollectionView * _Nonnull collectionView ,NSArray<NSObject*>* _Nonnull dataSource,CollectionViewArray * _Nonnull listener){
    
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
