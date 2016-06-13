//
//  PDLMapViewUtil.h
//  PDLDividingRuleView
//
//  Created by qiyun on 16/6/12.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface UIProgressView (PDLCustomProgressView)

- (CGSize)sizeThatFits:(CGSize)size;

@end

@implementation UIProgressView (PDLCustomProgressView)

- (CGSize)sizeThatFits:(CGSize)size {
    
    CGSize newSize = CGSizeMake(self.frame.size.width,5);
    return newSize;
}

@end

@interface  MKMapView (PDLMapViewUtil)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

- (void)dividingRuleUpdate;
- (void)showScale:(BOOL)scale;

@end
