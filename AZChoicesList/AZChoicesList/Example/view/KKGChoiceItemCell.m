//
//  KKGChoiceItemCell.m
//  AZChoicesList
//
//  Created by 云联智慧 on 2021/1/5.
//

#import "KKGChoiceItemCell.h"

@interface KKGChoiceItemCell ()
@property(nonatomic,strong)UIButton *leftButton;
@property(nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong) UILabel *subTitleLabel;
@property (nonatomic,strong) UIView *lineView;
@end
@implementation KKGChoiceItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        
        
        _titleLabel = [[UILabel alloc]init];
        [self.contentView addSubview:_titleLabel];
        
        _leftButton = [[UIButton alloc]init];
        [self.contentView addSubview:_leftButton];
        
        _subTitleLabel = [[UILabel alloc]init];
        [self.contentView addSubview:_subTitleLabel];
        
        _lineView = [[UIView alloc]init];
        [self.contentView addSubview:_lineView];
    }
    return self;
}
-(void)layoutSubviews
{
    
    _leftButton.frame = CGRectMake(16, (self.frame.size.height - 30.0) * 0.5, 30, 30);
    _leftButton.selected = _isSelected;
    _leftButton.userInteractionEnabled = NO;
    [_leftButton setImage:[UIImage imageNamed:@"radio_normal"] forState:UIControlStateNormal];
    [_leftButton setImage:[UIImage imageNamed:@"radio_selected"] forState:UIControlStateSelected];
    
    _leftButton.hidden = _isJustForShow?YES:NO;
    
    _titleLabel.frame = CGRectMake(_leftButton.frame.origin.x + _leftButton.frame.size.width + 16.0, 6.0, SCREEN_W - _leftButton.frame.size.width - 16.0 - 16.0, 18.0);
    if(_isJustForShow)
    {
        _titleLabel.frame = CGRectMake(16.0, 6.0, SCREEN_W - 16.0 - 16.0, 18.0);
    }
    _titleLabel.font = [UIFont systemFontOfSize:16.0];
    _titleLabel.textColor = [UIColor colorWithRed:(CGFloat)28 / 255 green:(CGFloat)28 / 255 blue:(CGFloat)28 / 255 alpha:1.0];
    _titleLabel.text = _title;
    
    
    _subTitleLabel.frame = CGRectMake(_leftButton.frame.origin.x + _leftButton.frame.size.width + 16.0, _titleLabel.frame.origin.y + _titleLabel.frame.size.height, SCREEN_W - _leftButton.frame.size.width - 16.0 - 16.0, 26.0);
    if(_isJustForShow)
    {
        _subTitleLabel.frame = CGRectMake(16.0, _titleLabel.frame.origin.y + _titleLabel.frame.size.height, SCREEN_W - 16.0 - 16.0, 26.0);
    }
    _subTitleLabel.font = [UIFont systemFontOfSize:14.0];
    _subTitleLabel.textColor = [UIColor colorWithRed:(CGFloat)134 / 255 green:(CGFloat)137 / 255 blue:(CGFloat)141 / 255 alpha:1.0];
    _subTitleLabel.text = _subTitle;
    
    /** 如果没有子标题或者说子标题为空，就让主标题居中显示 */
    if(!_subTitle || [_subTitle isEqualToString:@""])
    {
        
        if(_isJustForShow)
        {
            _titleLabel.frame = CGRectMake(16.0, (self.frame.size.height - 18.0) / 2.0, SCREEN_W - 16.0 - 16.0, 18.0);
        }
        else
        {
            _titleLabel.frame = CGRectMake(_leftButton.frame.origin.x + _leftButton.frame.size.width + 16.0, (self.frame.size.height - 18.0) / 2.0, SCREEN_W - _leftButton.frame.size.width - 16.0 - 16.0, 18.0);
        }
    }
    _lineView.frame = CGRectMake(16.0, self.frame.size.height - 0.6, SCREEN_W - 32.0, 0.6);
    _lineView.backgroundColor = [UIColor colorWithRed:(CGFloat)134 / 255 green:(CGFloat)137 / 255 blue:(CGFloat)141 / 255 alpha:1.0];
    _lineView.hidden = _isShowBottomLine?NO:YES;
}
@end
