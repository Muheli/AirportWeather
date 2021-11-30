// Note: The images are actually drawn upside down because Quartz image drawing expects
// the coordinate system to have the origin in the lower-left corner, but a UIView
// puts the origin in the upper-left corner. For the sake of brevity (and because
// it likely would go unnoticed for the image used) this is not addressed here.
// For the demonstration of PDF drawing however, it is addressed, as it would definately
// be noticed, and one method of addressing it is shown there.

#import "AW_MapImageView.h"


@implementation AW_MapImageView
{
    CGImageRef _MapImage;
    CGImageRef _DotImage;
}


@synthesize MapDotPos;
@synthesize MapDotIsVisible;


-(void)SetDotPos:(CGPoint) point{
    MapDotPos = point;
    MapDotIsVisible = YES;
    [self setNeedsDisplay];
}


-(void)HideDot{
    MapDotIsVisible = NO;
    [self setNeedsDisplay];
}


-(void)drawInContext:(CGContextRef)context
{
	CGRect aMapRect;
	aMapRect.origin = CGPointMake(0.0, 0.0);
	aMapRect.size = CGSizeMake(MapWidth, MapHeight);
	CGContextDrawImage(context, aMapRect, self.MapImage);
    
    if ( MapDotIsVisible ){
        CGRect aDotRect;
        aDotRect.origin = MapDotPos; //CGPointMake(200.0, 100.0);
        aDotRect.size = CGSizeMake(DotWidth, DotHeight);
        CGContextDrawImage(context, aDotRect, self.DotImage);
    }
}


- (CGImageRef)MapImage
{
	if (_MapImage == NULL)
	{
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"WorldMap-760x400-VFlip" ofType:@"png"];
		UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
		_MapImage = CGImageRetain(img.CGImage);
	}
	return _MapImage;
    
}


- (CGImageRef)DotImage
{
	if (_DotImage == NULL)
	{
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"MapDot-20x20" ofType:@"png"];
		UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
		_DotImage = CGImageRetain(img.CGImage);
	}
	return _DotImage;
    
}


-(void)dealloc
{
	CGImageRelease(_MapImage);
	CGImageRelease(_DotImage);
}


@end