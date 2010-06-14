@import <AppKit/CPView.j>
@import "MKMapItem.j"
@import "MKMapView.j"
@import "MKLocation.j"

@implementation MKMarker : MKMapItem
{
    Marker      _gMarker    @accessors(property=gMarker);
    CPDictionary     _gInfoWindowTabs    @accessors(property=gInfoWindowTabs);
    MKMapView   _mapView;
    MKLocation  _location   @accessors(property=location);
    BOOL        _draggable;//  @accessors(property=draggable);
    BOOL        _withShadow  @accessors(property=withShadow);
    CPString    _iconUrl    @accessors(property=iconUrl);
    GIcon       _gIcon     @accessors(property=customIconObject);
    GIcon       _gShadow   @accessors(property=customIconShadowObject);
    CPString    _shadowUrl  @accessors(property=shadowUrl);
    id          _delegate  @accessors(property=delegate);
    CPString    _infoWindowHTML;
    CPDictionary _eventHandlers;
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
    var gm = [MKMapView gmNamespace],
        id = [_gInfoWindowTabs count],
        tab = new gm.InfoWindowTab(label, contents);

    [_gInfoWindowTabs setObject:tab forKey:""+id];

    return id;
}

- (void)removeInfoWindowTab:(int)id
{
    [_gInfoWindowTabs removeObjectForKey:""+id];
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
       [MKMapView gmNamespace].Event.addListener(_gMarker, anEvent, aFunction);
    }
}


- (void)addToMapView:(MKMapView)mapView
{
    var googleMap = [mapView gMap],
        gm = [mapView gmNamespace],
        icon = nil, 
        shadow = nil;

    _mapView = mapView;

    // set a different icon if the _iconUrl is set
    if (_iconUrl)
    {
        icon = new gm.MarkerImage({'url':_iconUrl, 'size':new gm.Size(32, 32), 'anchor':new gm.Point(16, 32)});
        shadow = new gm.MarkerImage({'url':_shadowUrl, 'size':new gm.Size(59, 32)}); 
    }
    else if (_gIcon)
    {
        icon = _gIcon;
        shadow = _gShadow;
    }

    // set the shadow
    /*if (_withShadow && _shadowUrl)
    {
        shadow = new gm.MarkerImage({'url':_shadowUrl, 'size':new gm.Size(59, 32)}); 
    }*/
    _gMarker = new gm.Marker({  position:[_location googleLatLng],
                                map:googleMap,
                                icon:icon
                                });
    if (_withShadow)
    {
        _gMarker.setShadow(shadow);
    } 
    _gMarker.setClickable(true);
    _gMarker.setDraggable(false);

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
            gm.event.addListener(_gMarker, key, func);
        }
    }

    gm.event.addListener(_gMarker, 'dragend', function() { [self updateLocation]; });
    _gMarker.setMap(googleMap);
}

- (void)remove
{
    if (_gMarker && _mapView)
    {
        _gMarker.setMap(null);
        _gMarker = null;
    }
}

- (void)show
{
    if (_gMarker)
        _gMarker.setMap([_mapView gMap]);//_gMarker.show();
}

- (void)hide
{
    if (_gMarker)
        _gMarker.setMap(null);//_gMarker.show();
}

- (void)encodeWithCoder:(CPCoder)coder
{
    [coder encodeObject:[[_location latitude], [_location longitude]] forKey:@"location"];
}

@end

