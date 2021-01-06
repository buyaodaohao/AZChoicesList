//
//  KKGChoiceItemCell.h
//  AZChoicesList
//
//  Created by 云联智慧 on 2021/1/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKGChoiceItemCell : UITableViewCell
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *subTitle;
/** 针对有选择需要的列表，纪录某项是否被选中 */
@property(nonatomic,assign)BOOL isSelected;
/** 是否展示分割线，某个区域最后一个一般不展示分割线 */
@property(nonatomic,assign)BOOL isShowBottomLine;
/** 是否只是展示列表不做选择用 */
@property(nonatomic,assign)BOOL isJustForShow;
@end

NS_ASSUME_NONNULL_END
