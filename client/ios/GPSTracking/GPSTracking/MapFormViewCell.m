#import "MapFormViewCell.h"

NSString * const XLFormRowDescriptorTypeMapView = @"XLFormRowDescriptorMapView";

@interface MapFormViewCell(){}
@end

@implementation MapFormViewCell

+(void)load
{
    NSLog(@"call load method");
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:NSStringFromClass([MapFormViewCell class]) forKey:XLFormRowDescriptorTypeMapView];
}

#pragma mark - XLFormDescriptorCell

- (void)configure
{
    [super configure];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(GMSMapView *) getMapView {
    return mapView;
}

-(void)update
{
    [super update];
    BOOL isDisabled = self.rowDescriptor.isDisabled;
    self.selectionStyle = isDisabled ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
}

-(void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller
{
    if (self.rowDescriptor.action.formBlock){
        self.rowDescriptor.action.formBlock(self.rowDescriptor);
    }
    else if (self.rowDescriptor.action.formSelector){
//        [controller performSelector:self.rowDescriptor.action.formSelector withObject:self.rowDescriptor];
        [controller performFormSelector:self.rowDescriptor.action.formSelector withObject:self.rowDescriptor];
//        [controller performFormSeletor:self.rowDescriptor.action.formSelector withObject:self.rowDescriptor];
    }
    else if ([self.rowDescriptor.action.formSegueIdenfifier length] != 0){
        [controller performSegueWithIdentifier:self.rowDescriptor.action.formSegueIdenfifier sender:self.rowDescriptor];
    }
    else if (self.rowDescriptor.action.formSegueClass){
        UIViewController * controllerToPresent = [self controllerToPresent];
        NSAssert(controllerToPresent, @"either rowDescriptor.action.viewControllerClass or rowDescriptor.action.viewControllerStoryboardId or rowDescriptor.action.viewControllerNibName must be assigned");
        UIStoryboardSegue * segue = [[self.rowDescriptor.action.formSegueClass alloc] initWithIdentifier:self.rowDescriptor.tag source:controller destination:controllerToPresent];
        [controller prepareForSegue:segue sender:self.rowDescriptor];
        [segue perform];
    }
    else{
        UIViewController * controllerToPresent = [self controllerToPresent];
        if (controllerToPresent){
            if ([controllerToPresent conformsToProtocol:@protocol(XLFormRowDescriptorViewController)]){
                ((UIViewController<XLFormRowDescriptorViewController> *)controllerToPresent).rowDescriptor = self.rowDescriptor;
            }
            if (controller.navigationController == nil || [controllerToPresent isKindOfClass:[UINavigationController class]] || self.rowDescriptor.action.viewControllerPresentationMode == XLFormPresentationModePresent){
                [controller presentViewController:controllerToPresent animated:YES completion:nil];
            }
            else{
                [controller.navigationController pushViewController:controllerToPresent animated:YES];
            }
        }
        
    }
}

-(UIViewController *)controllerToPresent
{
    if (self.rowDescriptor.action.viewControllerClass){
        return [[self.rowDescriptor.action.viewControllerClass alloc] init];
    }
    else if ([self.rowDescriptor.action.viewControllerStoryboardId length] != 0){
        UIStoryboard * storyboard =  [self storyboardToPresent];
        NSAssert(storyboard != nil, @"You must provide a storyboard when rowDescriptor.action.viewControllerStoryboardId is used");
        return [storyboard instantiateViewControllerWithIdentifier:self.rowDescriptor.action.viewControllerStoryboardId];
    }
    else if ([self.rowDescriptor.action.viewControllerNibName length] != 0){
        Class viewControllerClass = NSClassFromString(self.rowDescriptor.action.viewControllerNibName);
        NSAssert(viewControllerClass, @"class owner of self.rowDescriptor.action.viewControllerNibName must be equal to %@", self.rowDescriptor.action.viewControllerNibName);
        return [[viewControllerClass alloc] initWithNibName:self.rowDescriptor.action.viewControllerNibName bundle:nil];
    }
    return nil;
}

-(void) clearViews
{
    if (circle != nil) {
        circle.map = nil;
    }
    
    circle = nil;
    
    if (marker != nil) {
        marker.map = nil;
    }
    
    marker = nil;
}
-(void) drawMarker: (CLLocation *)location
{
    if (marker != nil) {
        marker.map = nil;
    }

    marker = [[GMSMarker alloc] init];
    marker.position = location.coordinate;
    marker.groundAnchor = CGPointMake(0.5, 1);
    marker.icon = [GMSMarker markerImageWithColor:[UIColor colorWithRed:0.34 green:0.7 blue:0.84 alpha:1]];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = mapView;
}

-(void) drawCircle:(CLLocation *)location withRadius: (CLLocationDistance) radius
{
    if (circle != nil) {
        circle.map = nil;
    }
    
    CLLocationCoordinate2D circleCenter = location.coordinate;//CLLocationCoordinate2DMake(37.35, -122.0);
    circle = [GMSCircle circleWithPosition:circleCenter
                                             radius:radius];
    circle.strokeColor = [UIColor colorWithRed:0.27 green:0.54 blue:0.95 alpha:1];
    circle.fillColor = [UIColor colorWithRed:0.27 green:0.54 blue:0.95 alpha:0.2];
    circle.strokeWidth = 1;
    circle.map = mapView;
}

-(UIStoryboard *)storyboardToPresent
{
    if ([self.formViewController respondsToSelector:@selector(storyboardForRow:)]){
        return [self.formViewController storyboardForRow:self.rowDescriptor];
    }
    if (self.formViewController.storyboard){
        return self.formViewController.storyboard;
    }
    return nil;
}


+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor
{
    return 180;
}

@end

