//
//  AW_MainViewController.h
//  Airport Weather
//
//  Created by Joseph Sandmeyer on 5/21/13.
//  Copyright (c) 2013 Joseph Sandmeyer. All rights reserved.
//

#import "AW_CompilerFlags.h"
#import "AW_FlipsideViewController.h"
#import "AW_MapImageView.h"


#define CF_UseKludgeForEmptyPickerIosBug    (  1 )
#define PickerIdx_Unknown                   ( -1 )


@interface AW_MainViewController : UIViewController <
    AW_FlipsideViewControllerDelegate,
    UIPopoverControllerDelegate,
    UIPickerViewDelegate,
    UIPickerViewDataSource,
    UISearchBarDelegate
>{
    IBOutlet UIPickerView   *singlePicker;
    NSMutableArray          *pickerList;
    // -----------------------------    
    IBOutlet UILabel *Label_StationName;
    IBOutlet UILabel *Label_TimeStamp;
    IBOutlet UILabel *Label_Clouds;
    // -----------------------------
    IBOutlet UILabel *Label_IcaoCode;
    IBOutlet UILabel *Label_Wind;
    IBOutlet UILabel *Label_Temperature;
    // -----------------------------
    IBOutlet UILabel *Label_Humidity;
    IBOutlet UILabel *Label_DewPoint;
    IBOutlet UILabel *Label_SeaLevelPressure;
    // -----------------------------
    IBOutlet UILabel *Label_UnknownCode;
    IBOutlet UIButton *Btn_Test1;
}


@property (strong, nonatomic)   NSArray     *locations;
@property (nonatomic)           NSInteger    locationCt;
@property (nonatomic)           NSInteger    curLocationIdx;

@property (strong, nonatomic)   UIPopoverController *flipsidePopoverController;

@property (nonatomic, strong)   UIPickerView    *singlePicker;
@property (nonatomic, strong)   NSMutableArray  *pickerList;

@property (nonatomic, strong)   UILabel *Label_StationName;
@property (nonatomic, strong)   UILabel *Label_TimeStamp;
@property (nonatomic, strong)   UILabel *Label_Clouds;

@property (nonatomic, strong)   UILabel *Label_IcaoCode;
@property (nonatomic, strong)   UILabel *Label_Wind;
@property (nonatomic, strong)   UILabel *Label_Temperature;

@property (nonatomic, strong)   UILabel *Label_Humidity;
@property (nonatomic, strong)   UILabel *Label_DewPoint;
@property (nonatomic, strong)   UILabel *Label_SeaLevelPressure;

@property (nonatomic, weak)     IBOutlet AW_MapImageView *mapImageView; // Weak since not owned here.
@property (nonatomic, strong)   IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong)   UILabel *Label_UnknownCode;
@property (nonatomic, strong)   UIButton *Btn_Test1;

- (IBAction)RandomAirportBtnHit:(id)sender;
- (IBAction)ClearListBtnHit:(id)sender;
- (IBAction)TestBtnHit:(id)sender;

@end
