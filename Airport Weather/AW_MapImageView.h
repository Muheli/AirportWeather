#import "AW_CompilerFlags.h"
#import <UIKit/UIKit.h>
#import "QuartzView.h"


#define DotWidth            (  20.0)
#define DotHeight           (  20.0)
#define MapWidth            ( 760.0)
#define MapHeight           ( 400.0)
#define MapCenter_X         ( MapWidth / 2 )
#define MapCenter_Y         ( MapHeight / 2 )
#define LonW                (-180.0)
#define LonE                ( 180.0)
#define LatN                (  90.0)
#define LatS                (- 90.0)
#define PlotW               (   0.0)
#define PlotE               ( MapWidth - DotWidth )
#define PlotN               (   0.0)
#define PlotS               ( MapHeight - DotHeight )
#define PlotCenter_X        ( PlotE / 2 )
#define PlotCenter_Y        ( PlotS / 2 )
#define LonXPlotScale       ( PlotCenter_X / LonE )
#define LatYPlotScale       ( PlotCenter_Y / LatS )
#define LocIdx_Unknown      ( -1 )



@interface AW_MapImageView : QuartzView

@property (readwrite, nonatomic)           CGPoint    MapDotPos;
@property (readwrite, nonatomic)           BOOL       MapDotIsVisible;

-(void)SetDotPos:(CGPoint) point;
-(void)HideDot;


@end