//
//  CustomPlaceHolderTextColorTextField.m
//  LiquorStoreApp
//
//  Created by Vanguard on 11/5/14.
//  Copyright (c) 2014 ParthPatel. All rights reserved.
//

#import "CustomPlaceHolderTextColorTextField.h"

@implementation CustomPlaceHolderTextColorTextField


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    }
    return self;
}
/*
-(void) drawPlaceholderInRect:(CGRect)rect  {
    
    if (self.placeholder)
    {
        // color of placeholder text
        UIColor *placeHolderTextColor = [UIColor whiteColor];
        //[UIColor colorWithRed:77/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];

        CGSize drawSize = [self.placeholder sizeWithAttributes:[NSDictionary dictionaryWithObject:self.font forKey:NSFontAttributeName]];
        CGRect drawRect = CGRectMake(rect.origin.x, (rect.size.height- self.font.pointSize)/2, rect.size.width, self.font.pointSize);
        
        // verticially align text
        drawRect.origin.y = (rect.size.height - drawSize.height) * 0.5;
        
        // set alignment
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = self.textAlignment;
        
        // dictionary of attributes, font, paragraphstyle, and color
        NSDictionary *drawAttributes = @{NSFontAttributeName: self.font,
                                         NSParagraphStyleAttributeName : paragraphStyle,
                                         NSForegroundColorAttributeName : placeHolderTextColor};
        
        
        // draw
        [self.placeholder drawInRect:drawRect withAttributes:drawAttributes];
//        [self.placeholder drawInRect:drawRect withFont:self.font lineBreakMode:NSLineBreakByWordWrapping alignment:self.textAlignment];
    }
}
*/
@end
