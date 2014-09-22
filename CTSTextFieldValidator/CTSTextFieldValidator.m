//
//  CTSTextFieldValidator.m
//  SDKSandbox
//
//  Created by Mukesh Patil on 18/09/14.
//  Copyright (c) 2014 CitrusPay. All rights reserved.
//

#import "CTSTextFieldValidator.h"
#import "TestParams.h"
#import "CTSUtility.h"


@interface CTSPopUp : UIView

@property (nonatomic,assign) CGRect showOnRect;
@property (nonatomic,assign) int popWidth;
@property (nonatomic,assign) CGRect fieldFrame;
@property (nonatomic,copy) NSString *strMsg;
@property (nonatomic,retain) UIColor *popUpColor;

@end

@implementation CTSPopUp
@synthesize showOnRect,popWidth,fieldFrame,popUpColor;

-(void)drawRect:(CGRect)rect{
    const CGFloat *color=CGColorGetComponents(popUpColor.CGColor);
    
    UIGraphicsBeginImageContext(CGSizeMake(30, 20));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, color[0], color[1], color[2], 1);
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 7.0, [UIColor blackColor].CGColor);
	CGPoint points[3] = { CGPointMake(15, 5), CGPointMake(25, 25),
		CGPointMake(5,25)};
    CGContextAddLines(ctx, points, 3);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect imgframe=CGRectMake((showOnRect.origin.x+((showOnRect.size.width-30)/2)), ((showOnRect.size.height/2)+showOnRect.origin.y), 30, 13);
    
    UIImageView *img=[[UIImageView alloc] initWithImage:viewImage highlightedImage:nil];
    [self addSubview:img];
    img.translatesAutoresizingMaskIntoConstraints=NO;
    NSDictionary *dict=NSDictionaryOfVariableBindings(img);
    [img.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[img(%f)]",imgframe.origin.x,imgframe.size.width] options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    [img.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[img(%f)]",imgframe.origin.y,imgframe.size.height] options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    
    UIFont *font=[UIFont fontWithName:FontName size:FontSize];
    CGSize size=[self.strMsg boundingRectWithSize:CGSizeMake(fieldFrame.size.width-(PaddingInErrorPopUp*2), 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    size=CGSizeMake(ceilf(size.width), ceilf(size.height));
    
    UIView *view=[[UIView alloc] initWithFrame:CGRectZero];
    [self insertSubview:view belowSubview:img];
    view.backgroundColor=self.popUpColor;
    view.layer.cornerRadius=5.0;
    view.layer.shadowColor=[[UIColor blackColor] CGColor];
    view.layer.shadowRadius=5.0;
    view.layer.shadowOpacity=1.0;
    view.layer.shadowOffset=CGSizeMake(0, 0);
    view.translatesAutoresizingMaskIntoConstraints=NO;
    dict=NSDictionaryOfVariableBindings(view);
    [view.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[view(%f)]",fieldFrame.origin.x+(fieldFrame.size.width-(size.width+(PaddingInErrorPopUp*2))),size.width+(PaddingInErrorPopUp*2)] options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    [view.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[view(%f)]",imgframe.origin.y+imgframe.size.height,size.height+(PaddingInErrorPopUp*2)] options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    
    UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectZero];
    lbl.font=font;
    lbl.numberOfLines=0;
    lbl.backgroundColor=[UIColor clearColor];
    lbl.text=self.strMsg;
    lbl.textColor=ColorFont;
    [view addSubview:lbl];
    
    lbl.translatesAutoresizingMaskIntoConstraints=NO;
    dict=NSDictionaryOfVariableBindings(lbl);
    [lbl.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[lbl(%f)]",(float)PaddingInErrorPopUp,size.width] options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    [lbl.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[lbl(%f)]",(float)PaddingInErrorPopUp,size.height] options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    [self removeFromSuperview];
    return NO;
}

@end
//***********************************************************************************************************************************

@interface CTSTextFieldValidatorSupport : NSObject<UITextFieldDelegate>

@property (nonatomic,retain) id<UITextFieldDelegate> delegate;
@property (nonatomic,assign) BOOL validateOnCharacterChanged;
@property (nonatomic,assign) BOOL validateOnResign;
@property(nonatomic) NSInteger tag;                // default is 0
@property(nonatomic) CGFloat location; /* Location of the tab stop inside the line fragment rect coordinate system */
@property (nonatomic,retain) NSString* type;
@property (nonatomic,unsafe_unretained) CTSPopUp *popUp;
@end

@implementation CTSTextFieldValidatorSupport
@synthesize delegate,validateOnCharacterChanged,popUp,validateOnResign;

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if([delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)])
        return [delegate textFieldShouldBeginEditing:textField];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if([delegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
        [delegate textFieldDidBeginEditing:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if([delegate respondsToSelector:@selector(textFieldShouldEndEditing:)])
        return [delegate textFieldShouldEndEditing:textField];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if([delegate respondsToSelector:@selector(textFieldDidEndEditing:)])
        [delegate textFieldDidEndEditing:textField];
    [popUp removeFromSuperview];
    if(validateOnResign)
        [(CTSTextFieldValidator *)textField validate];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    [(CTSTextFieldValidator *)textField dismissPopup];
    if(validateOnCharacterChanged)
        [(CTSTextFieldValidator *)textField performSelector:@selector(validate) withObject:nil afterDelay:0.1];
    else
        [(CTSTextFieldValidator *)textField setRightView:nil];
    if([delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
        [delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];

    // text limit
    if (textField.tag == _tag) {
        if (range.location == _location) {
            return NO;
        }
    }
    
    // Card number
    if ([_type isEqualToString:CARD_TYPE]) {
        return [CTSUtility appendHyphenForCardnumber:textField replacementString:string shouldChangeCharactersInRange:range];
    }
    
    // Mobile number4
    if ([_type isEqualToString:MOBILE_TYPE]) {
        return [CTSUtility appendHyphenForMobilenumber:textField replacementString:string shouldChangeCharactersInRange:range];
    }

    
    if ([_type isEqualToString:NUMERIC_TYPE]) {
        return [CTSUtility enterNumericOnly:string];
    }
    
    if ([_type isEqualToString:ALPHABETICAL_TYPE]) {
        return [CTSUtility enterCharecterOnly:string];
    }

    
    // CVV
    if ([_type isEqualToString:CVV_TYPE]) {
        return [CTSUtility validateCVVNumber:textField replacementString:string shouldChangeCharactersInRange:range];
    }

//    [(CTSTextFieldValidator *)textField dismissPopup];
//    if(validateOnCharacterChanged)
//        [(CTSTextFieldValidator *)textField performSelector:@selector(validate) withObject:nil afterDelay:0.1];
//    else
//        [(CTSTextFieldValidator *)textField setRightView:nil];
//    if([delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
//        return [delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];


    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    if([delegate respondsToSelector:@selector(textFieldShouldClear:)])
        return [delegate textFieldShouldClear:textField];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([delegate respondsToSelector:@selector(textFieldShouldReturn:)])
        return [delegate textFieldShouldReturn:textField];
    return YES;
}

-(void)setDelegate:(id<UITextFieldDelegate>)dele{
    delegate=dele;
}

@end

//***********************************************************************************************************************************


@interface CTSTextFieldValidator(){
    NSString *strLengthValidationMsg;
    CTSTextFieldValidatorSupport *supportObj;
    NSString *strMsg;
    NSMutableArray *arrRegx;
    CTSPopUp *popUp;
    UIColor *popUpColor;
}

-(void)tapOnError;

@end

@implementation CTSTextFieldValidator
@synthesize presentInView,validateOnCharacterChanged,popUpColor,isMandatory,validateOnResign;

#pragma mark - Default Methods of UIView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    arrRegx=[[NSMutableArray alloc] init];
    validateOnCharacterChanged=YES;
    isMandatory=YES;
    validateOnResign=YES;
    popUpColor=ColorPopUpBg;
    strLengthValidationMsg=[MsgValidateLength copy];
    supportObj=[[CTSTextFieldValidatorSupport alloc] init];
    supportObj.validateOnCharacterChanged=validateOnCharacterChanged;
    supportObj.validateOnResign=validateOnResign;
    NSNotificationCenter *notify=[NSNotificationCenter defaultCenter];
    [notify addObserver:self selector:@selector(didHideKeyboard) name:UIKeyboardWillHideNotification object:nil];
    return self;
}

-(void)setDelegate:(id<UITextFieldDelegate>)deleg{
    supportObj.delegate=deleg;
    super.delegate=supportObj;
}

-(void)setValidateOnCharacterChanged:(BOOL)validate{
    supportObj.validateOnCharacterChanged=validate;
    validateOnCharacterChanged=validate;
}

-(void)setValidateOnResign:(BOOL)validate{
    supportObj.validateOnResign=validate;
    validateOnResign=validate;
}

#pragma mark - Public methods
-(void)addRegx:(NSString *)strRegx withMsg:(NSString *)msg{
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:strRegx,@"regx",msg,@"msg", nil];
    [arrRegx addObject:dic];
}

-(void)addRegx:(NSString *)strRegx withMsg:(NSString *)msg tag:(NSInteger)tag location:(CGFloat)location{
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:strRegx,@"regx",msg,@"msg", nil];
    [arrRegx addObject:dic];
    supportObj.tag = tag;
    supportObj.location = location;
}

-(void)addRegx:(NSString *)strRegx withMsg:(NSString *)msg tag:(NSInteger)tag location:(CGFloat)location type:(NSString *)type{
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:strRegx,@"regx",msg,@"msg", nil];
    [arrRegx addObject:dic];
    supportObj.tag = tag;
    supportObj.location = location;
    supportObj.type = type;
}

-(void)updateLengthValidationMsg:(NSString *)msg{
    strLengthValidationMsg=[msg copy];
}

-(void)addConfirmValidationTo:(CTSTextFieldValidator *)txtConfirm withMsg:(NSString *)msg{
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:txtConfirm,@"confirm",msg,@"msg", nil];
    [arrRegx addObject:dic];
}

-(BOOL)validate{
    if(isMandatory){
        if([self.text length]==0){
            [self showErrorIconForMsg:strLengthValidationMsg];
            return NO;
        }
    }
    for (int i=0; i<[arrRegx count]; i++) {
        NSDictionary *dic=[arrRegx objectAtIndex:i];
        if([dic objectForKey:@"confirm"]){
            CTSTextFieldValidator *txtConfirm=[dic objectForKey:@"confirm"];
            if(![txtConfirm.text isEqualToString:self.text]){
                [self showErrorIconForMsg:[dic objectForKey:@"msg"]];
                return NO;
            }
        }else if(![[dic objectForKey:@"regx"] isEqualToString:@""] && [self.text length]!=0 && ![self validateString:self.text withRegex:[dic objectForKey:@"regx"]]){
            [self showErrorIconForMsg:[dic objectForKey:@"msg"]];
            return NO;
        }
    }
    self.rightView=nil;
    return YES;
}

-(void)dismissPopup{
    [popUp removeFromSuperview];
}

#pragma mark - Internal Methods

-(void)didHideKeyboard{
    [popUp removeFromSuperview];
}

-(void)tapOnError{
    [self showErrorWithMsg:strMsg];
}

- (BOOL)validateString:(NSString*)stringToSearch withRegex:(NSString*)regexString {
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexString];
    return [regex evaluateWithObject:stringToSearch];
}

-(void)showErrorIconForMsg:(NSString *)msg{
    UIButton *btnError=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [btnError addTarget:self action:@selector(tapOnError) forControlEvents:UIControlEventTouchUpInside];
    [btnError setBackgroundImage:[UIImage imageNamed:IconImageName] forState:UIControlStateNormal];
    self.rightView=btnError;
    self.rightViewMode=UITextFieldViewModeAlways;
    strMsg=[msg copy];
}

-(void)showErrorWithMsg:(NSString *)msg{
    popUp=[[CTSPopUp alloc] initWithFrame:CGRectZero];
    popUp.strMsg=msg;
    popUp.popUpColor=popUpColor;
    popUp.showOnRect=[self convertRect:self.rightView.frame toView:presentInView];
    popUp.fieldFrame=[self.superview convertRect:self.frame toView:presentInView];
    popUp.backgroundColor=[UIColor clearColor];
    [presentInView addSubview:popUp];
    
    popUp.translatesAutoresizingMaskIntoConstraints=NO;
    NSDictionary *dict=NSDictionaryOfVariableBindings(popUp);
    [popUp.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[popUp]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    [popUp.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[popUp]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    supportObj.popUp=popUp;
}

@end