// MKOverlay.j
// MapKit
//
// Created by Stephen Ierodiaconou
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

@implementation MKOverlay : CPView
{
    MKMapView   m_map;
    CLLocationCoordinate2D m_location;
    CGPoint     m_anchor;
}

- (void)setCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    m_location = aCoordinate;
}

- (void)setAnchor:(CGPoint)anAnchor
{
    m_anchor = anAnchor;
}

// set map to nil if you want to remove from any view.
- (void)setMap:map
{
    if (m_map)
        [self removeFromSuperview];

    m_map = map;
    
    if (m_map)
    {
        [self _updateOrigin];
        
        [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(zoomDidChange:) name:MKMapViewZoomDidChangeNotification object:m_map];
        [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(mapCenterCoordinateDidChange:) name:MKMapViewCenterCoordinateDidChangeNotification object:m_map];
        [m_map addSubview:self];
    }
}

- (void)zoomDidChange:sender
{
    [self _updateOrigin];
}

- (void)mapCenterCoordinateDidChange:sender
{
    [self _updateOrigin];
}

- (void)_updateOrigin
{   
    var point = [m_map convertCoordinate:m_location toPointToView:m_map];
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
}

@end
