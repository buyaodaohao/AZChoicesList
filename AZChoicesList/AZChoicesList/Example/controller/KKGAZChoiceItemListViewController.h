//
//  KKGAZChoiceItemListViewController.h
//  AZChoicesList
//
//  Created by 云联智慧 on 2021/1/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class KKGChoiceItemModel;
@protocol KKGAZChoiceItemListViewControllerDelegate <NSObject>

-(void)didSelectedOneModel:(KKGChoiceItemModel *)model;

@end
@interface KKGAZChoiceItemListViewController : UIViewController
@property (nonatomic,weak) id<KKGAZChoiceItemListViewControllerDelegate> delegate;
/** 从外部传入的数据模型，传入就代表有选中的，想重新选择或者查看选择 */
@property (nonatomic,strong) KKGChoiceItemModel *outInModel;
/** 是否只是展示列表不做选择用 */
@property(nonatomic,assign)BOOL isJustForShow;
@end

NS_ASSUME_NONNULL_END
