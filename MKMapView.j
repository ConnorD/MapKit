
@import <AppKit/CPView.j>

@import "MKGeometry.j"
@import "MKTypes.j"


@implementation MKMapView : CPControl
{
    CLLocationCoordinate2D  m_centerCoordinate;
    int                     m_zoomLevel;
    MKMapType               m_mapType;

    BOOL                    m_scrollWheelZoomEnabled;

    // Google Maps v2 DOM Support
    DOMElement              m_DOMMapElement;
    DOMElement              m_DOMGuardElement;
    Object                  m_map;
}

+ (CPSet)keyPathsForValuesAffectingCenterCoordinateLatitude
{
    return [CPSet setWithObjects:@"centerCoordinate"];
}

+ (CPSet)keyPathsForValuesAffectingCenterCoordinateLongitude
{
    return [CPSet setWithObjects:@"centerCoordinate"];
}

+ (int)_mapTypeIdForMapType:(MKMapType)aMapType
{
    return  [
                google.maps.G_NORMAL_MAP,
                google.maps.G_HYBRID_MAP,
                google.maps.G_SATELLITE_MAP,
                google.maps.G_PHYSICAL_MAP
            ][aMapType];
}

- (id)initWithFrame:(CGRect)aFrame
{
    return [self initWithFrame:aFrame centerCoordinate:nil];
}

- (id)initWithFrame:(CGRect)aFrame centerCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        [self setBackgroundColor:[CPColor colorWithRed:229.0 / 255.0 green:227.0 / 255.0 blue:223.0 / 255.0 alpha:1.0]];
        [self setCenterCoordinate:aCoordinate || new CLLocationCoordinate2D(52, -1)];
        [self setZoomLevel:6];
        [self setMapType:MKMapTypeStandard];
        [self setScrollWheelZoomEnabled:YES];

        [self _buildDOM];
    }

    return self;
}

- (void)_buildDOM
{
    performWhenGoogleMapsScriptLoaded(function()
    {
        m_DOMMapElement = document.createElement("div");
        m_DOMMapElement.id = "MKMapView" + [self UID];

        var style = m_DOMMapElement.style,
            bounds = [self bounds],
            width = CGRectGetWidth(bounds),
            height = CGRectGetHeight(bounds);

        style.overflow = "hidden";
        style.position = "absolute";
        style.visibility = "visible";
        style.zIndex = 0;
        style.left = -width + "px";
        style.top = -height + "px";
        style.width = width + "px";
        style.height = height + "px";

        // Google Maps can't figure out the size of the div if it's not in the DOM tree,
        // so we have to temporarily place it somewhere on the screen to appropriately size it.
        document.body.appendChild(m_DOMMapElement);

        m_map = new google.maps.Map2(m_DOMMapElement);

        m_map.setCenter(LatLngFromCLLocationCoordinate2D(m_centerCoordinate));
        m_map.setZoom(m_zoomLevel);
        m_map.setMapType([[self class] _mapTypeIdForMapType:m_mapType]);

        google.maps.Event.trigger(m_map, "resize");

        style.left = "0px";
        style.top = "0px";

        // Important: we had to remove this dom element before appending it somewhere else
        // or you will get WRONG_DOCUMENT_ERRs (4)
        document.body.removeChild(m_DOMMapElement);

        _DOMElement.appendChild(m_DOMMapElement);

        m_DOMGuardElement = document.createElement("div");

        var style = m_DOMGuardElement.style;

        style.overflow = "hidden";
        style.position = "absolute";
        style.visibility = "visible";
        style.zIndex = 0;
        style.left = "0px";
        style.top = "0px";
        style.width = "100%";
        style.height = "100%";

        _DOMElement.appendChild(m_DOMGuardElement);
    });
}

- (void)setFrameSize:(CGSize)aSize
{
    [super setFrameSize:aSize];

    var bounds = [self bounds];

    if (m_DOMMapElement)
    {
        var style = m_DOMMapElement.style;

        style.width = CGRectGetWidth(bounds) + "px";
        style.height = CGRectGetHeight(bounds) + "px";

        google.maps.event.trigger(m_map, "resize");
    }
}

- (MKCoordinateRegion)region
{
    if (m_map)
        return MKCoordinateRegionFromLatLngBounds(m_map.getBounds());

    return nil;
}

- (void)setRegion:(MKCoordinateRegion)aRegion
{
    m_region = aRegion;

    if (m_map)
    {
        [self setZoomLevel:m_map.getBoundsZoomLevel(LatLngBoundsFromMKCoordinateRegion(aRegion))];
        [self setCenterCoordinate:aRegion.center];
    }
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    m_centerCoordinate = new CLLocationCoordinate2D(aCoordinate);

    if (m_map)
        m_map.setCenter(LatLngFromCLLocationCoordinate2D(aCoordinate));
}

- (CLLocationCoordinate2D)centerCoordinate
{
    return new CLLocationCoordinate2D(m_centerCoordinate);
}

- (void)setCenterCoordinateLatitude:(float)aLatitude
{
    [self setCenterCoordinate:new CLLocationCoordinate2D(aLatitude, [self centerCoordinateLongitude])];
}

- (float)centerCoordinateLatitude
{
    return [self centerCoordinate].latitude;
}

- (void)setCenterCoordinateLongitude:(float)aLongitude
{
    [self setCenterCoordinate:new CLLocationCoordinate2D([self centerCoordinateLatitude], aLongitude)];
}

- (float)centerCoordinateLongitude
{
    return [self centerCoordinate].longitude;
}

- (void)setZoomLevel:(float)aZoomLevel
{
    m_zoomLevel = +aZoomLevel || 0;

    if (m_map)
        m_map.setZoom(m_zoomLevel);
}

- (int)zoomLevel
{
    return m_zoomLevel;
}

- (void)setMapType:(MKMapType)aMapType
{
    m_mapType = aMapType;

    if (m_map)
        m_map.setMapType([[self class] _mapTypeIdForMapType:m_mapType]);
}

- (MKMapType)mapType
{
    return m_mapType;
}

- (void)setScrollWheelZoomEnabled:(BOOL)shouldBeEnabled
{
    m_scrollWheelZoomEnabled = shouldBeEnabled;

    if (m_map)
        m_map.setScrollWheelZoomEnabled(m_scrollWheelZoomEnabled);
}

- (BOOL)scrollWheelZoomEnabled
{
    return m_scrollWheelZoomEnabled;
}

- (void)takeStringAddressFrom:(id)aSender
{
    var geocoder = new google.maps.ClientGeocoder();

    geocoder.getLatLng([aSender stringValue], function(aLatLng)
    {
        if (!aLatLng)
            return;

        [self setCenterCoordinate:CLLocationCoordinate2DFromLatLng(aLatLng)];
        [self setZoomLevel:7];
    });
}

- (void)mouseDown:(CPEvent)anEvent
{
    if ([anEvent clickCount] === 2)
    {
        m_map.zoomIn(LatLngFromCLLocationCoordinate2D([self convertPoint:[anEvent locationInWindow] toCoordinateFromView:nil]), YES, YES);
        return;
    }

    [super mouseDown:anEvent];
}

- (BOOL)tracksMouseOutsideOfFrame
{
    return YES;
}

- (BOOL)startTrackingAt:(CGPoint)aPoint
{
    return YES;
}

- (BOOL)continueTracking:(CGPoint)lastPoint at:(CGPoint)aPoint
{
    var centerCoordinate = [self centerCoordinate],
        lastCoordinate = [self convertPoint:lastPoint toCoordinateFromView:self],
        currentCoordinate = [self convertPoint:aPoint toCoordinateFromView:self],
        delta = new CLLocationCoordinate2D(
            currentCoordinate.latitude - lastCoordinate.latitude,
            currentCoordinate.longitude - lastCoordinate.longitude);

    centerCoordinate.latitude -= delta.latitude;
    centerCoordinate.longitude -= delta.longitude;

    [self setCenterCoordinate:centerCoordinate];

    return YES;
}

- (void)stopTracking:(CGPoint)lastPoint at:(CGPoint)aPoint mouseIsUp:(BOOL)mouseIsUp
{
}

- (CGPoint)convertCoordinate:(CLLocationCoordinate2D)aCoordinate toPointToView:(CPView)aView
{
    if (!m_map)
        return CGPointMakeZero();

    var location = m_map.fromLatLngToContainerPixel(LatLngFromCLLocationCoordinate2D(aCoordinate));

    return [self convertPoint:CGPointMake(location.x, location.y) toView:aView];
}

- (CLLocationCoordinate2D)convertPoint:(CGPoint)aPoint toCoordinateFromView:(CPView)aView
{
    if (!m_map)
        return new CLLocationCoordinate2D();

    var location = [self convertPoint:aPoint fromView:aView],
        latlng = m_map.fromContainerPixelToLatLng(new google.maps.Point(location.x, location.y));

    return CLLocationCoordinate2DFromLatLng(latlng);
}

@end

var GoogleMapsScriptQueue   = [];

var performWhenGoogleMapsScriptLoaded = function(/*Function*/ aFunction)
{
    GoogleMapsScriptQueue.push(aFunction);

    performWhenGoogleMapsScriptLoaded = function()
    {
        GoogleMapsScriptQueue.push(aFunction);
    }

    // Maps is already loaded
    if (window.google && google.maps && google.maps.Map2)
        _MKMapViewMapsLoaded();

    else
    {
        var DOMScriptElement = document.createElement("script");

        DOMScriptElement.src = "http://www.google.com/jsapi?callback=_MKMapViewGoogleAjaxLoaderLoaded";
//        DOMScriptElement.src = "http://maps.google.com/maps/api/js?sensor=false&callback=_MKMapViewMapsLoaded";
        DOMScriptElement.type = "text/javascript";

        document.getElementsByTagName("head")[0].appendChild(DOMScriptElement);
    }
}

function _MKMapViewGoogleAjaxLoaderLoaded()
{
    google.load("maps", "2", { "callback": _MKMapViewMapsLoaded });

    window.setTimeout(function()
    {
        [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
    }, 500);
}

function _MKMapViewMapsLoaded()
{
    performWhenGoogleMapsScriptLoaded = function(/*Function*/ aFunction)
    {
        aFunction();
    }

    var index = 0,
        count = GoogleMapsScriptQueue.length;

    for (; index < count; ++index)
        GoogleMapsScriptQueue[index]();

    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
}

var MKMapViewCenterCoordinateKey    = @"MKMapViewCenterCoordinateKey",
    MKMapViewZoomLevelKey           = @"MKMapViewZoomLevelKey",
    MKMapViewMapTypeKey             = @"MKMapViewMapTypeKey";

@implementation MKMapView (CPCoding)

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super initWithCoder:aCoder];

    if (self)
    {
        [self setCenterCoordinate:CLLocationCoordinate2DFromString([aCoder decodeObjectForKey:MKMapViewCenterCoordinateKey])];
        [self setZoomLevel:[aCoder decodeObjectForKey:MKMapViewZoomLevelKey]];
        [self setMapType:[aCoder decodeObjectForKey:MKMapViewMapTypeKey]];

        [self _buildDOM];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:CPStringFromCLLocationCoordinate2D([self centerCoordinate]) forKey:MKMapViewCenterCoordinateKey];
    [aCoder encodeObject:[self zoomLevel] forKey:MKMapViewZoomLevelKey];
    [aCoder encodeObject:[self mapType] forKey:MKMapViewMapTypeKey];
}

@end
