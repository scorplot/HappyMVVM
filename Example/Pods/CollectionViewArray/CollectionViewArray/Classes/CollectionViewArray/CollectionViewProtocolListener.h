//
//  CollectionViewProtocolListener.h
//  Pods
//
//  Created by aruisi on 2017/7/19.
//
//

#import <Foundation/Foundation.h>
#import "CollectionViewArray.h"
@interface CollectionViewProtocolListener : NSObject<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDataSourcePrefetching,UIScrollViewDelegate>
@property(nonatomic,strong)NSArray * dataSource;
@property(nonatomic,strong)CollectionViewArray * listener;
@property(nonatomic,weak)UICollectionView  * collectionView;
@end
