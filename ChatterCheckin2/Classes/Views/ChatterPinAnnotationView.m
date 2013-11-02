//
//  ChatterPinAnnotationView.m
//  ChatterCheckin2
//
//  Created by Jason Barker on 11/1/13.
//  Copyright (c) 2013 Salesforce.com. All rights reserved.
//

#import "ChatterPinAnnotationView.h"



static CGPoint CHATTER_PIN_CENTER_OFFSET = {4.0, -18.0};
static CGPoint CHATTER_PIN_CALLOUT_OFFSET = {-4.0, 10.0};



@implementation ChatterPinAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setImage: [UIImage imageNamed: @"chatterPin"]];
        [self setCenterOffset: CHATTER_PIN_CENTER_OFFSET];
        [self setCanShowCallout: YES];
        [self setCalloutOffset: CHATTER_PIN_CALLOUT_OFFSET];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
