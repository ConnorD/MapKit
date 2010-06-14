// MKCircle.j
// MapKit
//
// Created by Stephen Ierodiaconou, 2010
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

@import "MKOverlay.j"

@implementation MKCircle : MKOverlay
{
    float   m_radius        @accessors(property=radius); // in meters
    CPColor m_fillColor     @accessors(property=fillColor);
    CPColor m_strokeColor   @accessors(property=strokeColor);
    float   m_strokeWidth   @accessors(property=strokeWidth);
}

- (void)drawRect:(CGRect)rect
{   
    if (m_fillColor)
        [m_fillColor setFill];
    else
        [[CPColor colorWithWhite:1.0 alpha:0.0] setFill]; // transparent by default

    if (m_strokeColor)
        [m_strokeColor setStroke];
    else
        [[CPColor blackColor] setStroke];

    // FIXME: does the rect need padding for the border? Is his Cocoa behaviour?
    var circle = [CPBezierPath bezierPathWithOvalInRect:rect];

    if (m_strokeWidth !== nil)
        [circle setLineWidth:m_strokeWidth];

    [circle fill];
    [circle stroke];
}

- (void)_updateOverlay
{
    //[super _updateOverlay];
    var point = [m_map convertCoordinate:m_location toPointToView:m_map];
    
    // http://www.movable-type.co.uk/scripts/latlong.html - Calculate distance, bearing and more between Latitude/Longitude points
    var R = 6371000,
        brng = 3*Math.PI/4,
        nd = m_radius/R,
        lat1 = m_location.latitude * Math.PI/180,
        lon1 = m_location.longitude * Math.PI/180,
        lat2 = Math.asin( Math.sin(lat1)*Math.cos(nd) + 
                          Math.cos(lat1)*Math.sin(nd)*Math.cos(brng) ),
        lon2 = lon1 + Math.atan2(Math.sin(brng)*Math.sin(nd)*Math.cos(lat1), 
                                 Math.cos(nd)-Math.sin(lat1)*Math.sin(lat2));
    
    var endpoint = [m_map convertCoordinate:CLLocationCoordinate2DMake(lat2 * 180/Math.PI, lon2 * 180/Math.PI) toPointToView:m_map];

    [self setFrameSize:CGSizeMake(endpoint.x - point.x, endpoint.y - point.y)];
    
    if (m_anchor)
    {
        point.x -= m_anchor.x;
        point.y -= m_anchor.y;
    } 
    else
    {
        // default anchor center
        point.x -= FLOOR([self frameSize].width/2);
        point.y -= FLOOR([self frameSize].height/2);
    }
    [self setFrameOrigin:point];
    
    [self setNeedsDisplay:YES];
}

@end
