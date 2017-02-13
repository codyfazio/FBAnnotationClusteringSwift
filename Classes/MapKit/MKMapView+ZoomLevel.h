// MKMapView+ZoomLevel.h
#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
    zoomLevel:(NSUInteger)zoomLevel
    animated:(BOOL)animated;

+ (MKCoordinateRegion)coordinateRegionWithPixelSize:(CGSize)pixelSize
                                   centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                       andZoomLevel:(NSUInteger)zoomLevel;
- (double) zoomLevel;

@end
