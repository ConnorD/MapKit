// MKLocation.j
// MapKit
//
// Created by Johannes Fahrenkrug, Stephen Ierodiaconou
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

@import <Foundation/CPObject.j>
@import "MKGeometry.j"

@implementation MKLocation : CPObject
{
    CLLocationCoordinate2D      _location;
}

+ (MKLocation)location
{
    return [[MKLocation alloc] init];
}

+ (MKLocation)locationWithLatitude:(float)aLat andLongitude:(float)aLng {
    return [[MKLocation alloc] initWithLatitude:aLat andLongitude:aLng];
}

+ (MKLocation)locationFromString:(CPString)aString
{
    return [MKLocation locationWithCLLocationCoordinate2D:CLLocationCoordinate2DFromString(aString)];
}

+ (MKLocation)locationWithCLLocationCoordinate2D:(CLLocationCoordinate2D)aCLLocation
{
    return [[MKLocation alloc] initWithCLLocationCoordinate2D:aCLLocation];
}

- (id)initWithCLLocationCoordinate2D:(CLLocationCoordinate2D)aCLLocation
{
    if (self = [super init]) {
        _location = aCLLocation;
    }
    return self;
}

- (id)initWithLatLng:(LatLng)aLatLng {
    return [self initWithLatitude:aLatLng.lat() andLongitude:aLatLng.lng()];
}

- (id)initWithLatitude:(float)aLatitude andLongitude:(float)aLongitude
{
    if (self = [super init]) {
        _location = CLLocationCoordinate2D(aLatitude, aLongitude);
    }
    return self;
}

- (LatLng)googleLatLng {
    return new google.maps.LatLng(_location.latitude, _location.longitude);
}

- (void)encodeWithCoder:(CPCoder)coder
{
    [coder encodeObject:_location forKey:@"location"];
}

@end

