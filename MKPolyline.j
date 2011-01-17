@import <AppKit/CPView.j>
@import "MKMapItem.j"
@import "MKMapView.j"
@import "MKLocation.j"

@implementation MKPolyline : MKMapItem
{
    CPArray     _locations     @accessors(property=locations);
    CPString    _colorCode     @accessors(property=colorCode);
    int         _strokeWeight   @accessors(property=strokeWeight);
    float       _strokeOpacity @accessors(property=strokeOpacity);
}

+ (MKPolyline)polyline
{
    return [[MKPolyline alloc] init];
}

- (id)init {
    return [self initWithLocations:nil];
}

- (id)initWithLocations:(CPArray)someLocations
{
    if (self = [super init]) {
        _locations = someLocations;
        _colorCode = @"#ff0000";
        _strokeWeight = 5;
        _strokeOpacity = 1.0;
    }
    return self;
}

- (void)addLocation:(MKLocation)aLocation {
    if (!_locations) {
        _locations = [[CPArray alloc] init];
    }
    
    [_locations addObject:aLocation];
}

- (Polyline)googlePolyline {
    if (_locations) {
        var gm = [MKMapView gmNamespace];
        var locEnum = [_locations objectEnumerator];
        var loc = nil
        var lineCoordinates = [];
        while (loc = [locEnum nextObject]) {
            lineCoordinates.push([loc googleLatLng]);
        }
        
        return new gm.Polyline({ path: lineCoordinates, strokeColor: _colorCode, strokeWeight: _strokeWeight, strokeOpacity: _strokeOpacity });
    }
    
    return nil;
}

- (void)addToMapView:(MKMapView)mapView
{
    var googleMap = [mapView gMap];
    [self googlePolyline].setMap(googleMap);
}



@end

