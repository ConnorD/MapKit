// MKCircle.j
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

@import "MKOverlay.j"

@implementation MKCircle : MKOverlay
{
    float   m_radius;
    CPColor m_fillColor;
    CPColor m_strokeColor;
}

// Radius in meters
- (void)setRadius:(float)radius
{
    m_radius = radius;
    
    // RESIZE CONTENT RECT
    
}

- (void)setFillColor:(CPColor)color
{
    m_fillColor = color;
}

- (void)setStrokeColor:(CPColor)color
{
    m_strokeColor = color;
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

    var circle = [CPBezierPath bezierPathWithOvalInRect:rect];
    [circle fill];
    [circle stroke];
}

@end
