//
//  PDLMapViewUtil.m
//  PDLDividingRuleView
//
//  Created by qiyun on 16/6/12.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import "PDLMapView+DividingRule.h"
#import <objc/runtime.h>

@interface _PDLDividingRuleView : UIView

@property (nonatomic, strong) UILabel  *hTitle;
@property (nonatomic, strong) UILabel  *title;
@property (nonatomic, strong) UILabel  *fTitle;
@property (nonatomic, strong) UIProgressView  *progressView ;

- (id)initWithFrame:(CGRect)frame;

@end

@implementation _PDLDividingRuleView

- (id)initWithFrame:(CGRect)frame{
    
    if ([super initWithFrame:frame]) {
        
        self.frame = frame;
        
        if (!CGRectIsEmpty(self.frame)) {
            
            [self addSubview:self.progressView];
            [self addSubview:self.hTitle];
            [self addSubview:self.title];
            [self addSubview:self.fTitle];
        }
    }
    return self;
}

- (UIProgressView *)progressView{
    
    if (!_progressView) {
        
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(self.bounds) - 10, CGRectGetWidth(self.bounds) - 20, 0)];
        _progressView.trackTintColor    = [UIColor lightGrayColor];
        _progressView.progressTintColor = [UIColor redColor];
        _progressView.layer.borderWidth = 1;
        _progressView.layer.borderColor = [UIColor blackColor].CGColor;
        [_progressView setProgress:0.5];
    }
    return _progressView;
}

- (UILabel *)title{
    
    if (!_title) {
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)/2 - 15, 5, 30, 15)];
        _title.textAlignment    = NSTextAlignmentCenter;
        _title.font             = [UIFont boldSystemFontOfSize:9];
        _title.textColor        = [UIColor whiteColor];
    }
    return _title;
}

- (UILabel *)hTitle{
    
    if (!_hTitle) {
        
        _hTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 30, 15)];
        _hTitle.textAlignment   = NSTextAlignmentCenter;
        _hTitle.font            = [UIFont boldSystemFontOfSize:9];
        _hTitle.textColor = [UIColor whiteColor];
    }
    return _hTitle;
}

- (UILabel *)fTitle{
    
    if (!_fTitle) {
        
        _fTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - 40, 5, 40, 15)];
        _fTitle.textAlignment   = NSTextAlignmentRight;
        _fTitle.font            = [UIFont boldSystemFontOfSize:9];
        _fTitle.textColor       = [UIColor whiteColor];
    }
    return _fTitle;
}


@end

@implementation MKMapView (PDLMapViewUtil)

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395


#pragma mark -
#pragma mark Map conversion methods

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

#pragma mark -
#pragma mark Helper methods

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(NSUInteger)zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

- (void)dividingRuleUpdate{
    
    _PDLDividingRuleView *ruleView = (_PDLDividingRuleView *)[self viewWithTag:10086];
    
    BOOL scale = objc_getAssociatedObject(self, @"scaleEnable");
    
    if (scale && !ruleView.tag) {
        
        CGRect rect;
        rect.origin = CGPointMake(CGRectGetWidth(self.bounds) - 140, CGRectGetHeight(self.bounds) - 40);
        rect.size = CGSizeMake(120, 30);
        ruleView = [[_PDLDividingRuleView alloc] initWithFrame:rect];
        ruleView.tag = 10086;
        [self addSubview:ruleView];
        
    }else{
        
        //[ruleView removeFromSuperview];
        //ruleView = nil;
    }
    
    //[ruleView.progressView setTransform:CGAffineTransformMakeScale(10000.0f/[self getDistance], 1)];
    ruleView.hTitle.text = @"0";
    ruleView.fTitle.text = [self exchangeFromDistance:[self getDistance] showUnit:YES];
    
    CGFloat value = [ruleView.fTitle.text floatValue]/2;
    ruleView.title.text = [NSString stringWithFormat:@"%.1f",value];
}

- (NSString *)exchangeFromDistance:(CGFloat)distance showUnit:(BOOL)show{
    
    if (distance < pow(10, 3))  return show?[NSString stringWithFormat:@"%.1fm",distance]:[NSString stringWithFormat:@"%.1f",distance];
        
    else if (distance >= pow(10, 3) && distance < pow(10, 5))
        return show?[NSString stringWithFormat:@"%.1fkm",distance/pow(10, 3)]:[NSString stringWithFormat:@"%.1f",distance/pow(10, 3)];
        
    else if (distance >= pow(10, 5) && distance < pow(10, 7))
        return show?[NSString stringWithFormat:@"%.1fMm",distance/pow(10, 3)]:[NSString stringWithFormat:@"%.1f",distance/pow(10, 3)];
    
    else return nil;
}

- (CLLocationDistance)getDistance{
    
    CGPoint toPoint = CGPointMake(self.center.x + 100, self.center.y);
    
    CLLocationCoordinate2D coordinate2D_origin = [self convertPoint:self.center toCoordinateFromView:self];
    CLLocationCoordinate2D coordinate2D_end = [self convertPoint:toPoint toCoordinateFromView:self];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate2D_origin.latitude longitude:coordinate2D_origin.longitude];
    CLLocationDistance distance = [location distanceFromLocation:[[CLLocation alloc] initWithLatitude:coordinate2D_end.latitude
                                                                                            longitude:coordinate2D_end.longitude]];
    NSLog(@"距离  %f",distance);
    return distance;
}

#pragma mark -
#pragma mark Public methods

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated
{
    // clamp large numbers to 28
    zoomLevel = MIN(zoomLevel, 28);
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [self setRegion:region animated:animated];
}


- (void)showScale:(BOOL)scale{
    
    objc_setAssociatedObject(self, @"scaleEnable", @(scale), OBJC_ASSOCIATION_ASSIGN);
}



@end
