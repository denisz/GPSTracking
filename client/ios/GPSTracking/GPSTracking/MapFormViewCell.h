#import <XLForm/XLFormBaseCell.h>
#import <GoogleMaps/GoogleMaps.h>

extern NSString * const XLFormRowDescriptorTypeMapView;

@interface MapFormViewCell : XLFormBaseCell {
    IBOutlet GMSMapView *mapView;
    GMSMarker* marker;
    GMSCircle* circle;
    
}
 -(GMSMapView *) getMapView;
-(void) drawMarker:(CLLocation *) location;
-(void) drawCircle:(CLLocation *)location withRadius: (CLLocationDistance) radius;
-(void) clearViews;
@end