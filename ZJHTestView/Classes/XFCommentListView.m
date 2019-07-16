//
//  XFCommentListView.m
//  XFVideo_ios
//
//  Created by haoxiaofeng on 2019/4/6.
//  Copyright © 2019年 haoxiaofeng. All rights reserved.
//

#import "XFCommentListView.h"

@interface XFCommentListView()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *listView;
@property (nonatomic, strong) UILabel *titleLab;

property_strong_non UITableView *tableview;
property_strong_non UIPanGestureRecognizer *pan;
property_assign_non BOOL panEnable;


@end

@implementation XFCommentListView

+ (id)commentListView
{
    static XFCommentListView *clv = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        clv = [[XFCommentListView alloc] init];
    });
    return clv;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.frame = CGRectMake(0, 0, 375, 675);
    self.listView = [[UIView alloc] initWithFrame:CGRectMake(0, 175, 375, 500)];
    [self addSubview:_listView];
  
    self.listView.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.6];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: _listView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(7,7)];
    //创建 layer
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _listView.bounds;
    //赋值
    maskLayer.path = maskPath.CGPath;
    _listView.layer.mask = maskLayer;
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = _listView.bounds;
    [_listView addSubview:effectView];
    
    _titleLab = [[UILabel alloc] init];
    [self.listView addSubview:_titleLab];
    _titleLab.text = @"评论";
    _titleLab.textColor = [UIColor whiteColor];
    _titleLab.font = FontDefault;
    _titleLab.textAlignment = NSTextAlignmentCenter;
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(self.mas_width);
        make.height.mas_equalTo(40);
    }];
    _tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self addSubview:_tableview];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.backgroundColor = [UIColor clearColor];
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab.mas_bottom);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.left.offset(0);
        make.right.offset(0);
    }];
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEvent:)];
    _pan.delegate = self;
    [self addGestureRecognizer:_pan];
}

- (void)scrollToTop
{
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    [window addSubview:self];
    [UIView animateWithDuration:0.27 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.layer.transform = CATransform3DMakeTranslation(0, 0, 1);
    } completion:nil];
}

- (void)show
{
    self.layer.transform = CATransform3DMakeTranslation(0, 675, 1);
    [self scrollToTop];
}

- (void)hide
{
//    self.layer.transform = CATransform3DMakeTranslation(0, 0, 1);
    [UIView animateWithDuration:0.27 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.layer.transform = CATransform3DMakeTranslation(0, 675, 1);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    point = [_listView.layer convertPoint:point fromLayer:self.layer]; //get layer using containsPoint:
    if (![_listView.layer containsPoint:point]) {
        [self hide];
    }
}

+ (UIImage *)coreBlurImage:(UIImage *)image withBlurNumber:(CGFloat)blur
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage= [CIImage imageWithCGImage:image.CGImage];
    //设置filter
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey]; [filter setValue:@(blur) forKey: @"inputRadius"];
    //模糊图片
    CIImage *result=[filter valueForKey:kCIOutputImageKey];
    CGImageRef outImage=[context createCGImage:result fromRect:[result extent]];
    UIImage *blurImage=[UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return blurImage;
}

#pragma mark -
#pragma mark - tableview delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSURLUbiquitousSharedItemMostRecentEditorNameComponentsKey];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.image = [UIImage imageNamed:@"111.jpg"];
    cell.imageView.frame = CGRectMake(0, 10, 40, 40);
    cell.imageView.layer.cornerRadius = (CGFloat)cell.imageView.width/2;
    cell.textLabel.text = [NSString stringWithFormat:@"这是第%ld条评论哦，这个评论很搞笑", indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = FontBig;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



//是否识别视图手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


/**
 *  平移手势响应事件
 *
 *  @param swipe swipe description
 */
- (void)panEvent:(UIPanGestureRecognizer *)panGestureRecognizer
{
    NSLog(@"hahahahah");
    // 在滑动状态下   并且没有到顶
    if (_tableview.decelerating == YES || _tableview.contentOffset.y > 0) {
        _tableview.scrollEnabled = YES;
        return;
    }
    CGPoint po = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    if (po.y <= 0) { // pan向上滑无效  tableview有效
        _tableview.scrollEnabled = YES;
    } else { // 下滑
        _tableview.scrollEnabled = NO;
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        _tableview.scrollEnabled = YES;
        CGPoint speed = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
        if (speed.y > 200) {
            [self hide];
        }
        else {
            [self scrollToTop];
        }
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        [self commitTranslation:[panGestureRecognizer translationInView:panGestureRecognizer.view]];
    }
}

/**
 *   判断手势方向
 *
 *  @param translation translation description
 */
- (void)commitTranslation:(CGPoint)translation
{
    if (translation.y >= 0) {
        //向上滑动
        self.transform = CGAffineTransformMakeTranslation(self.left, translation.y);
    }
    else {
        self.transform = CGAffineTransformMakeTranslation(self.left, 0);
        
    }
}


@end
