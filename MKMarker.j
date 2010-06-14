// MKMarker.j
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

@implementation MKMarker : CPView
{
    MKMapView   m_map;
    CPImageView m_icon;
    CLLocationCoordinate2D m_location;
}

- (void)setCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    m_location = aCoordinate;
}

- (void)setIcon:(CPImage)anImage width:aWidth height:aHeight
{
    m_icon = [[CPImageView alloc] initWithFrame:CGRectMake(0,0,aWidth,aHeight)];
    [m_icon setImage:anImage];
    [self addSubview:m_icon];
}

// set map to nil if you want to remove from any view.
- (void)setMap:map
{
    if (m_map)
        [self removeFromSuperview];

    m_map = map;
    var point = [m_map convertCoordinate:m_location toPointToView:m_map];
    [self setFrameOrigin:point];
    [m_map addSubview:self];
}

@end