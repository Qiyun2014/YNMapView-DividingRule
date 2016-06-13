//
//  ViewController.m
//  PDLDividingRuleView
//
//  Created by qiyun on 16/6/12.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "PDLMapView+DividingRule.h"

@interface ViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation ViewController


- (MKMapView *)mapView
{
    if (!_mapView)
    {
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate           = self;
        _mapView.clipsToBounds      = YES;
        _mapView.showsUserLocation  = YES;
        _mapView.rotateEnabled      = NO;
        _mapView.mapType            = MKMapTypeHybrid;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0)   _mapView.showsScale = YES;  //设置成NO表示不显示比例尺；YES表示显示比例尺
        [_mapView showScale:YES];
        
        [[_mapView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            //去除高德地图的文字标记
            if (idx == 1) {     [obj removeFromSuperview];  }
            
            //去除法律信息文字的标记
            if (idx == [_mapView subviews].count){ [obj removeFromSuperview]; }
        }];
    }
    return _mapView;
}

- (void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    
    self.mapView.frame              = self.view.bounds;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = 100.0;                    //100m 移動ごとに通知
    //self.locationManager.distanceFilter = kCLDistanceFilterNone;    //全ての動きを通知（デフォルト）

    [self.locationManager startUpdatingLocation];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.mapView];
    
    [self initLocationManager];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.00, 106.00) zoomLevel:10 animated:YES];
    });
}


- (void)initLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    
    NSLog(@"regionWillChangeAnimated");
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    NSLog(@"regionDidChangeAnimated");
    [self.mapView dividingRuleUpdate];
}


- (void)mapViewWillStartRenderingMap:(MKMapView *)mapView{
    
    [self.mapView dividingRuleUpdate];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations firstObject];//取出第一个位置
    CLLocationCoordinate2D coordinate = location.coordinate;//位置坐标
    [self.mapView setCenterCoordinate:coordinate animated:YES];
    
    NSLog(@"didUpdateLocations");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
