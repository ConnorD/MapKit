// MKMarker.j
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

@import <AppKit/CPView.j>
@import "MKMapView.j"
@import "MKLocation.j"

@implementation MKMarker : CPObject
{
    Marker          _gMarker            @accessors(property=gMarker);
    CPDictionary    _gInfoWindowTabs    @accessors(property=gInfoWindowTabs);
    MKMapView       _mapView;
    MKLocation      _location           @accessors(property=location);
    BOOL            _draggable;         //  @accessors(property=draggable);
    BOOL            _withShadow         @accessors(property=withShadow);
    CPString        _iconUrl            @accessors(property=iconUrl);
    GIcon           _gIcon              @accessors(property=customIconObject);
    CPString        _shadowUrl          @accessors(property=shadowUrl);
    id              _delegate           @accessors(property=delegate);
    CPString        _infoWindowHTML;
    CPDictionary    _eventHandlers;
}

+ (MKMarker)marker
{
    return [[MKMarker alloc] init];
}

- (id)initAtLocation:(MKLocation)aLocation
{
    if (self = [super init]) {
        _location = aLocation;
        _withShadow = YES;
        _draggable = YES;
        _gInfoWindowTabs = [CPDictionary dictionary];
    }
    return self;
}

- (id)initAtLocation:(MKLocation)aLocation withCustomIconObject:(GIcon)gicon
{
    if (self = [self initAtLocation:aLocation]) {
        _gIcon = gicon;
    }
    return self;
}

- (void)updateLocation
{
    _location = [[MKLocation alloc] initWithLatLng:_gMarker.getLatLng()];

    if (_delegate && [_delegate respondsToSelector:@selector(mapMarker:didMoveToLocation:)]) {
        [_delegate mapMarker:self didMoveToLocation:_location];
    }
}

- (void)setDraggable:drag
{
    _draggable = drag;
    if (_draggable && _gMarker)
        _gMarker.enableDragging()
    else if (!_draggable && _gMarker)
        _gMarker.disableDragging()
}

- (void)draggable
{
    return _draggable;
}

/*!
    Sets the icon URL based on this url pattern:
    http://maps.google.com/mapfiles/ms/micons/<anIconName>.png

    Some examples:

    POI
    arts
    bar
    blue-dot
    blue-pushpin
    blue
    bus
    cabs
    camera
    campfire
    campground
    caution
    coffeehouse
    convienancestore
    cycling
    dollar
    drinking_water
    earthquake
    electronics
    euro
    fallingrocks
    ferry
    firedept
    fishing
    flag
    gas
    golfer
    green-dot
    green
    grn-pushpin
    grocerystore
    groecerystore
    helicopter
    hiker
    homegardenbusiness
    horsebackriding
    hospitals
    hotsprings
    info
    info_circle
    landmarks-jp
    lightblue
    lodging
    ltblu-pushpin
    ltblue-dot
    man
    marina
    mechanic
    motorcycling
    movies
    orange-dot
    orange
    parkinglot
    partly_cloudy
    pharmacy-us
    phone
    picnic
    pink-dot
    pink-pushpin
    pink
    plane
    police
    postoffice-jp
    postoffice-us
    purple-dot
    purple-pushpin
    purple
    question
    rail
    rainy
    rangerstation
    realestate
    recycle
    red-dot
    red-pushpin
    red
    restaurant
    sailing
    salon
    shopping
    ski
    ski
    snack_bar
    snowflake_simple
    sportvenue
    subway
    sunny
    swimming
    toilets
    trail
    tram
    tree
    truck
    volcano
    water
    waterfalls
    webcam
    wheel_chair_accessible
    woman
    yellow-dot
    yellow
    yen
    ylw-pushpin

    You can find a list of official google maps icons here:
    http://www.visual-case.it/cgi-bin/vc/GMapsIcons.pl
*/
- (void)setGoogleIcon:(CPString)anIconName withShadow:(BOOL)withShadow
{
    _withShadow = withShadow;

    if (anIconName) {
        _iconUrl = "http://maps.google.com/mapfiles/ms/micons/" + anIconName + ".png"

        if (withShadow) {
            if (anIconName.match(/dot/) || anIconName.match(/(blue|green|lightblue|orange|pink|purple|red|yellow)$/)) {
                _shadowUrl = "http://maps.google.com/mapfiles/ms/micons/msmarker.shadow.png";
            } else if (anIconName.match(/pushpin/)) {
                _shadowUrl = "http://maps.google.com/mapfiles/ms/micons/pushpin_shadow.png";
            } else {
                _shadowUrl = "http://maps.google.com/mapfiles/ms/micons/" + anIconName + ".shadow.png";
            }
        }
    } else {
        _iconUrl = nil;
        _shadowUrl = "http://maps.google.com/mapfiles/ms/micons/msmarker.shadow.png"; //default shadow
    }
}

- (void)setGoogleIcon:(CPString)anIconName
{
    [self setGoogleIcon:anIconName withShadow:YES];
}

- (void)openInfoWindow
{
    [self openInfoWindowWithOptions:{}];
}

- (void)openInfoWindowWithOptions:options
{
    if (_gMarker)
    {
        _gMarker.closeInfoWindow();

        if (![_gInfoWindowTabs count])
            _gMarker.openInfoWindowHtml(_infoWindowHTML, options);
        else
            _gMarker.openInfoWindowTabsHtml([_gInfoWindowTabs allValues], _infoWindowHTML, options);
    }
}

- (void)closeInfoWindow
{
    if (_gMarker)
    {
        _gMarker.closeInfoWindow();
    }
}

- (void)setInfoWindowHTML:(CPString)someHTML
{
   [self setInfoWindowHTML:someHTML openOnClick:NO];
}

- (void)setInfoWindowHTML:(CPString)someHTML openOnClick:(BOOL)shouldOpenOnClick
{
    _infoWindowHTML = someHTML;

    if (shouldOpenOnClick)
    {
        [self shouldOpenInfoWindowOnClick];
    }
}

- (void)shouldOpenInfoWindowOnClickWithOptions:options
{
    [self addEventForName:@"click" withFunction:function() {[self openInfoWindowWithOptions:options];}];
}

- (void)shouldOpenInfoWindowOnClick
{
    [self addEventForName:@"click" withFunction:function() {[self openInfoWindow];}];
}

- (int)addInfoWindowTab:(CPString)label
{
    return [self addInfoWindowTab:label withHTML:""];
}

- (int)addInfoWindowTab:(CPString)label withHTML:contents
{
    var tid = [_gInfoWindowTabs count],
        tab = new google.maps.InfoWindowTab(label, contents);

    [_gInfoWindowTabs setObject:tab forKey:""+tid];

    return tid;
}

- (void)removeInfoWindowTab:(int)tid
{
    [_gInfoWindowTabs removeObjectForKey:""+tid];
}

- (CPString)infoWindowHTML
{
    return _infoWindowHTML;
}

- (void)addEventForName:(CPString)anEvent withFunction:(JSObject)aFunction
{
    if (!_eventHandlers)
    {
        _eventHandlers = {};
    }

    // remember the event handler
    _eventHandlers[anEvent] = aFunction;

    // if we have a marker, we can add it right away...
    if (_gMarker)
    {
       google.maps.Event.addListener(_gMarker, anEvent, aFunction);
    }
}


- (void)addToMapView:(MKMapView)mapView
{
    var icon = new google.maps.Icon(google.maps.DEFAULT_ICON);

    _mapView = mapView;

    // set a different icon if the _iconUrl is set
    if (_iconUrl)
    {
        icon.image = _iconUrl;
        icon.iconSize = new google.maps.Size(32, 32);
        icon.iconAnchor = new google.maps.Point(16, 32);
    }
    else if (_gIcon)
    {
        icon = _gIcon;
    }

    // set the shadow
    if (_withShadow && _shadowUrl)
    {
        icon.shadow = _shadowUrl;
        icon.shadowSize = new google.maps.Size(59, 32);
    }

    var markerOptions = { "icon":icon, "clickable":false, "draggable":_draggable };
    _gMarker = new google.maps.Marker([_location googleLatLng], markerOptions);

    // add the infowindow html
    if (_infoWindowHTML)
    {
        _gMarker.openInfoWindowHtml(_infoWindowHTML);
    }

    // are there events that should be added?
    if (_eventHandlers)
    {
        for (var key in _eventHandlers)
        {
            var func = _eventHandlers[key];
            google.maps.Event.addListener(_gMarker, key, func);
        }
    }

    google.maps.Event.addListener(_gMarker, 'dragend', function() { [self updateLocation]; });
    [mapView googleMap].addOverlay(_gMarker);
}

- (void)remove
{
    if (_gMarker && _mapView)
    {
        google.maps.removeOverlay(_gMarker);
    }
}

- (void)show
{
    if (_gMarker)
        _gMarker.show();
}

- (void)hide
{
    if (_gMarker)
        _gMarker.show();
}

- (void)encodeWithCoder:(CPCoder)coder
{
    [coder encodeObject:[[_location latitude], [_location longitude]] forKey:@"location"];
}

@end

