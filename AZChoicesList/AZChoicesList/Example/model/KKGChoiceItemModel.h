//
//  KKGChoiceItemModel.h
//  AZChoicesList
//
//  Created by 云联智慧 on 2021/1/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKGChoiceItemModel : NSObject
/** 需要显示或者说需要转成拼音的字段 */
@property(nonatomic,copy)NSString *itemTitle;
/** 子标题 */
@property(nonatomic,copy)NSString *subTitle;
/** 汉语转拼音之后，返回的拼音大写，结尾是每个汉字的首字母 例如，柯柯哥，转换为赋值给这个字段就是KEKEGEKKG*/
@property(nonatomic,copy)NSString *capitalSpell;
/** 汉语转拼音之后,返回的每个汉字的首字母，排序用，针对第一个字的首字母相同情况下，比较第二个字首字母来排序，以此类推。例如，柯柯哥，转换为赋值给这个字段就是KKG */
@property(nonatomic,copy)NSString *wordPrefixSpell;
@end

NS_ASSUME_NONNULL_END
