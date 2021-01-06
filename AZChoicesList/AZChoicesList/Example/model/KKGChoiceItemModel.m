//
//  KKGChoiceItemModel.m
//  AZChoicesList
//
//  Created by 云联智慧 on 2021/1/5.
//

#import "KKGChoiceItemModel.h"

@interface KKGChoiceItemModel ()<NSCoding>

@end
@implementation KKGChoiceItemModel
#pragma mark NSCopying,NSCoding
/** 我这里是为了本地化存储数据，所以需要进行编码处理 */
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.itemTitle forKey:@"itemTitle"];
    [aCoder encodeObject:self.subTitle forKey:@"subTitle"];
    [aCoder encodeObject:self.capitalSpell forKey:@"capitalSpell"];
    [aCoder encodeObject:self.wordPrefixSpell forKey:@"wordPrefixSpell"];
    
    
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        
        self.itemTitle = [aDecoder decodeObjectForKey:@"itemTitle"];
        self.subTitle = [aDecoder decodeObjectForKey:@"subTitle"];
        self.capitalSpell = [aDecoder decodeObjectForKey:@"capitalSpell"];
        self.wordPrefixSpell = [aDecoder decodeObjectForKey:@"wordPrefixSpell"];
        
    }
    return self;
}
@end
