//
//  AW_MainViewController.m
//  Airport Weather
//
//  Created by Joseph Sandmeyer on 5/21/13.
//  Copyright (c) 2013 Joseph Sandmeyer. All rights reserved.
//

#import "AW_MainViewController.h"
#import "Flurry.h"
#import "FlurryAds.h"
#import "FlurryAdDelegate.h"


//@interface AW_MainViewController ()
//@property (nonatomic, weak) IBOutlet AW_MapImageView *mapImageView;
//@end


@implementation AW_MainViewController

@synthesize singlePicker;
@synthesize pickerList;

@synthesize Label_StationName;
@synthesize Label_TimeStamp;
@synthesize Label_Clouds;

@synthesize Label_IcaoCode;
@synthesize Label_Wind;
@synthesize Label_Temperature;

@synthesize Label_Humidity;
@synthesize Label_DewPoint;
@synthesize Label_SeaLevelPressure;

@synthesize Label_UnknownCode;
@synthesize Btn_Test1;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Load AirportLoc array.
    [self LoadLocations];
    
    // Load Recent Loc for picker
    [self LoadPickerList];

    // Initialize location selection.
    self.curLocationIdx = LocIdx_Unknown;
    
    // Set initial position of Map Dot.
    [self.mapImageView SetDotPos: CGPointMake(MapCenter_X, MapCenter_Y)];

    // Set or clear map dot and weather report based on first picker item if any.
    [self SelectFromPickerRow: 0];
    
    // Seed the randomizer for the "random" button.
    srandomdev();
    
    // Set up search bar with autocorrection disabled
    if (self.searchBar) {
        self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    
    // Unknown code warning hidden until needed.
    self.Label_UnknownCode.hidden = YES;
    
    // Hide test buttons except when needed for diagnostics.
    #if (! CF_UseDiagnostics)
        self.Btn_Test1.hidden = YES;
    #endif
    
    // Apply Ads
    #if CF_UseFlurryAds
        // Register yourself as a delegate for ad callbacks.
        [FlurryAds setAdDelegate:self];
        
        // Fetch and display banner ads.
        [FlurryAds fetchAndDisplayAdForSpace:@"BANNER_MAIN_VC" view:self.view size:BANNER_BOTTOM];
    #endif
} // viewDidLoad


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Remove Banner Ads and reset delegate
    [FlurryAds removeAdFromSpace:@"BANNER_MAIN_VC"];
    [FlurryAds setAdDelegate:nil];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self SavePickerList];
    NSLog(@"viewDidDisappear");
}


#pragma mark -
#pragma mark Location Selection


- (void)LoadPickerList{
    do { //once through
        NSString *errorDesc = nil;
        NSString *plistPath;
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [rootPath stringByAppendingPathComponent:@"PickerList.plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            plistPath = [[NSBundle mainBundle] pathForResource:@"PickerList" ofType:@"plist"];
        }
        
        self.pickerList = [NSMutableArray arrayWithContentsOfFile: plistPath];
        if (self.pickerList ) {
            NSLog(@"pickerList: %d", [self.pickerList count]);
        }else{
            NSLog(@"Error reading pickerList: %@", errorDesc);
        }
    } while (false); //once through
} // LoadLocations


- (void)SavePickerList{
    NSString *errorDesc = nil;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"PickerList.plist"];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:self.pickerList
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&errorDesc];
    // Write to file.
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
    }else {
        #if CF_UseDiagnostics
            NSLog(errorDesc);
        #endif
    }

    
    // >< Implement
} // LoadLocations


- (void)LoadLocations{
    do { //once through
        NSString *plistPath;
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [rootPath stringByAppendingPathComponent:@"AirportLoc.plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            plistPath = [[NSBundle mainBundle] pathForResource:@"AirportLoc" ofType:@"plist"];
        }
        
        self.locations = [NSArray arrayWithContentsOfFile: plistPath];
        self.locationCt = 0;

        if (self.locations ) {
            self.locationCt = [self.locations  count];
        }

#if 0
        // Diagnostics.
        NSString *errorDesc = nil;

        if (self.locationCt > 0) {
            NSArray *aRecFeilds = [self.locations  objectAtIndex: 0];
            NSInteger aRecFieldCt = [aRecFeilds  count];
            NSString *aCode = [aRecFeilds objectAtIndex: 0];
            NSString *aDesc = [aRecFeilds objectAtIndex: 1];
            NSNumber *aLat = [aRecFeilds objectAtIndex: 2];
            NSNumber *aLon = [aRecFeilds objectAtIndex: 3];
            
            NSLog(@"aLocCt: %d", self.locationCt);
        }else{
            NSLog(@"Error reading plist: %@", errorDesc);
        }
#endif
        
    } while (false); //once through
} // LoadLocations


- (NSArray *)LocationRecFromIdx:(NSInteger)in_Idx{
    NSArray *aRec = nil;
    if ( (self.locations) && (0 <= in_Idx) && (in_Idx < self.locationCt) ){
        aRec = [self.locations  objectAtIndex: in_Idx];
        if ( (!aRec) || ([aRec  count] != 4) ){
            aRec = nil;
        }
    }
    return aRec;
}


- (NSString *)CodeFromLocationRec:(NSArray *)in_Rec{
    NSString *aCode = nil;
    if ( (in_Rec) && ([in_Rec  count] == 4) ){
        aCode = [in_Rec  objectAtIndex: 0];
    }
    return aCode;
}


- (NSString *)DescFromLocationRec:(NSArray *)in_Rec{
    NSString *aDesc = nil;
    if ( (in_Rec) && ([in_Rec  count] == 4) ){
        aDesc = [in_Rec  objectAtIndex: 1];
    }
    return aDesc;
}


- (NSNumber *)LatFromLocationRec:(NSArray *)in_Rec{
    NSNumber *aLat = nil;
    if ( (in_Rec) && ([in_Rec  count] == 4) ){
        aLat = [in_Rec  objectAtIndex: 2];
    }
    return aLat;
}


- (NSNumber *)LonFromLocationRec:(NSArray *)in_Rec{
    NSNumber *aLon = nil;
    if ( (in_Rec) && ([in_Rec  count] == 4) ){
        aLon = [in_Rec  objectAtIndex: 3];
    }
    return aLon;
}


- (NSInteger)LocationIdxFromCode:(NSString *)in_Code{
    NSInteger aRetIdx = LocIdx_Unknown;
    NSInteger aTestIdx;
    NSArray *aRec = nil;
    
    for (aTestIdx = 0; aTestIdx < self.locationCt; aTestIdx++){
        aRec = [self LocationRecFromIdx: aTestIdx];
        if ( [in_Code caseInsensitiveCompare:[self CodeFromLocationRec:aRec]] == NSOrderedSame ) {
            aRetIdx = aTestIdx;
            break;
        }
    }

    return aRetIdx;
}


#pragma mark Location Selection


- (void)SelectFromLocationIdx:(NSInteger)in_Idx{
    NSArray *aRec = [self LocationRecFromIdx: in_Idx];
    bool aStepComplete = false;

    do { //once through
        if (! aRec) break;
        NSNumber *aLatObj = [self LatFromLocationRec: aRec];
        if (! aLatObj) break;
        NSNumber *aLonObj = [self LonFromLocationRec: aRec];
        if (! aLonObj) break;
        
        self.curLocationIdx = in_Idx;
        
        float aLatVal = [aLatObj floatValue];
        float aLonVal = [aLonObj floatValue];
        CGPoint aPlotPos = CGPointMake(
            PlotCenter_X + (aLonVal * LonXPlotScale),
            PlotCenter_Y + (aLatVal * LatYPlotScale)
        );

        if (self.mapImageView){
            [self.mapImageView SetDotPos: aPlotPos];
        }
        
        [self DoWeatherReport: [self CodeFromLocationRec: aRec]
            withLocationDescription: [self DescFromLocationRec: aRec]
        ];

        aStepComplete = true;
    } while (false); //once through
    
    if (! aStepComplete) {
        if (self.mapImageView){
            [self.mapImageView HideDot];
        }
        
        [self renderWeatherReportUnavailableAtStation: nil withLocationDescription: nil];
    }
    
#if 0
    if (aRec){
        NSNumber *aLatObj = [self LatFromLocationRec: aRec];
        NSNumber *aLonObj = [self LonFromLocationRec: aRec];

        if (aLatObj && aLonObj){
            self.curLocationIdx = in_Idx;
            
            float aLatVal = [aLatObj floatValue];
            float aLonVal = [aLonObj floatValue];
            CGPoint aPlotPos = CGPointMake(
                                           PlotCenter_X + (aLonVal * LonXPlotScale),
                                           PlotCenter_Y + (aLatVal * LatYPlotScale)
                                           );
            if (self.mapImageView){
                [self.mapImageView SetDotPos: aPlotPos];
            }
            
            [self DoWeatherReport: [self CodeFromLocationRec: aRec]
            withLocationDescription: [self DescFromLocationRec: aRec]];
        }
    }
#endif
} // SelectFromLocationIdx


- (void)SelectFromLocationIdx_WithPickerUpdate:(NSInteger)in_Idx{
    // Update picker if in_Idx has a valid match.
    if ( (0 <= in_Idx) && (in_Idx < self.locationCt) ){
        // Create object to be added.
        NSNumber *aNumberToAdd = [NSNumber numberWithInt:in_Idx];

        // Remove any existing copy of this item if already in list.
        [self.pickerList removeObject: aNumberToAdd];
        
        // Add new to top of List.
        [self.pickerList insertObject:aNumberToAdd atIndex:0];
        
        // Serialize change to file.
        [self SavePickerList];
        
        // Redraw picker.
        if (self.singlePicker){
            [self.singlePicker reloadAllComponents];
            [self.singlePicker selectRow:0 inComponent:0 animated:YES];
        }else{
            NSLog(@"SelectFromLocationIdx_WithPickerUpdate FAIL to reloadAllComponents");
        }    
    }
    
    // Update map dot and weather report.
    [self SelectFromLocationIdx:in_Idx];
} // SelectFromLocationIdx_WithPickerUpdate


- (NSInteger)LocationIdxFromPickerRow:(NSInteger)in_PickerRow{
    NSNumber *aNumFromList = nil;
    NSInteger aLocIdx = LocIdx_Unknown;
    bool aStepComplete = false;

    do{ // Once through.
        aStepComplete = false;
        if( ! self.pickerList ) break;
        if( (in_PickerRow < 0) || ([self.pickerList count] <= in_PickerRow) ) break;

        aNumFromList = [self.pickerList  objectAtIndex: in_PickerRow];
        if ( ! aNumFromList ) break;
        
        aLocIdx = [aNumFromList integerValue];
    } while (false); // Once through.

    if (LocIdx_Unknown == aLocIdx){
        //NSAssert(false, @"LocationIdxFromPickerRow Failure");
        NSLog(@"LocationIdxFromPickerRow Failure");
    }
   return aLocIdx;
} // LocationIdxFromPickerRow


- (void)SelectFromPickerRow:(NSInteger)in_Row{
    [self SelectFromLocationIdx: [self LocationIdxFromPickerRow:in_Row]];
    
    NSLog(@"SelectFromPickerRow: %d", in_Row);
}


#pragma mark Picker Data Source Methods


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger aRowCt = 0;
    
    if (pickerList){
        aRowCt = [pickerList count];        
    }
    
#if CF_UseKludgeForEmptyPickerIosBug
    if (aRowCt <= 0){
        aRowCt = 1;
    }
#endif
    
    return aRowCt;
}


#pragma mark Picker Delegate Methods


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
#if CF_UseKludgeForEmptyPickerIosBug
    // <# CF_UseKludgeForEmptyPickerIosBug #>
    if ( (! pickerList) || (0 == [pickerList count]) ){
        return @" "; // Phantom item title to pacify iOS 6 picker bug.
    }
#endif
    
    NSString *aRowText = @"unknown";
    NSArray *aRec = [self LocationRecFromIdx: [self LocationIdxFromPickerRow: row]];
    NSString *aDesc = [self DescFromLocationRec: aRec];
    if (aDesc){
        aRowText = aDesc;
    }
    return aRowText;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    // Clear search text, possible code warning, and dismiss keyboard.
    [self ClearSearchTextMsgAndKbd];
    
    // Select location from picke and display report.
    [self SelectFromPickerRow: row];
    NSLog(@"Selected row: %d", row);
}


#pragma mark - Buttons


- (IBAction)RandomAirportBtnHit:(id)sender
{
    NSInteger aRandIdx = ( random() % self.locationCt );
    [self SelectFromLocationIdx_WithPickerUpdate: aRandIdx];
}


- (IBAction)TestBtnHit:(id)sender
{
    // <# test #>
    self.Label_UnknownCode.hidden = NO;
 } // TestBtnHit


- (IBAction)ClearListBtnHit:(id)sender
{
    NSLog(@"Clearing List");
    [self.pickerList removeAllObjects];
    [self SavePickerList];
    
    // Clear search text, possible code warning, and dismiss keyboard.
    [self ClearSearchTextMsgAndKbd];
   
    // Redraw picker.
    if (self.singlePicker){
        [self.singlePicker reloadAllComponents];
    }else{
        NSLog(@"ClearListBtnHit FAIL to reloadAllComponents");
    }
    
    // Clear map dot and weather report.
    [self SelectFromLocationIdx: LocIdx_Unknown];
}


// Summon Alert
// NSString *title = [[NSString alloc] initWithFormat:@"You selected %@!", @"something"];
// UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:@"Thank you for choosing." delegate:nil cancelButtonTitle:@"You're Welcome" otherButtonTitles:nil];
// [alert show];


#pragma mark -
#pragma mark - Weather Display


- (void) DoWeatherReport: (NSString *) in_IcaoCode withLocationDescription: (NSString *) in_LocDesc {
    BOOL aHaveObservation = NO;
    NSString * aStationName = nil;
    NSString * aTimeStamp = nil;
    NSString * aClouds = nil;
    NSString * aWindDirection = nil;
    NSString * aWindSpeed = nil;
    NSString * aTemperature = nil;
    NSString * aHumidity = nil;
    NSString * aDewPoint = nil;
    NSString * aSeaLevelPressure = nil;
    
    NSLog(@"Test 1");
    do{ //once through
        if (! in_IcaoCode) break;
        NSString *urlString = [@"http://ws.geonames.org/weatherIcaoJSON?ICAO="
            stringByAppendingString: in_IcaoCode];
        
        // create the URL we'd like to query
        //NSURL *myURL = [[NSURL alloc]initWithString:@"http://ws.geonames.org/weatherIcaoJSON?ICAO=KSFO"];
        NSURL *myURL = [[NSURL alloc]initWithString: urlString];
        if (! myURL) break;
        
        // we'll receive raw data so we'll create an NSData Object with it
        NSData *myData = [[NSData alloc]initWithContentsOfURL:myURL];
        if (! myData) break;
        
        // now we'll parse our data using NSJSONSerialization
        //id wholeJsonObj = [NSJSONSerialization JSONObjectWithData:myData options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *wholeJsonObj = [NSJSONSerialization JSONObjectWithData:myData options:kNilOptions error:nil];
        if (! wholeJsonObj) break;
        
        // Crack open the outer JSON package.
        NSDictionary *topJsonObj = [wholeJsonObj objectForKey:@"weatherObservation"];
        if (! topJsonObj) break;
        
        // Get elements.
        aStationName = [self StringFromDictionaryElement: topJsonObj atKey:@"stationName"];
        if (! aStationName) break;
        aTimeStamp = [self StringFromDictionaryElement: topJsonObj atKey:@"datetime"];
        if (! aTimeStamp) break;
        aClouds = [self StringFromDictionaryElement: topJsonObj atKey:@"clouds"];
        if (! aClouds) break;
        aWindDirection = [self StringFromDictionaryElement: topJsonObj atKey:@"windDirection"];
        if (! aWindDirection) break;
        aWindSpeed = [self StringFromDictionaryElement: topJsonObj atKey:@"windSpeed"];
        if (! aWindSpeed) break;
        aTemperature = [self StringFromDictionaryElement: topJsonObj atKey:@"temperature"];
        if (! aTemperature) break;
        aHumidity = [self StringFromDictionaryElement: topJsonObj atKey:@"humidity"];
        if (! aHumidity) break;
        aDewPoint = [self StringFromDictionaryElement: topJsonObj atKey:@"dewPoint"];
        if (! aDewPoint) break;
        aSeaLevelPressure = [self StringFromDictionaryElement: topJsonObj atKey:@"seaLevelPressure"];
        //if (! aSeaLevelPressure){ aSeaLevelPressure = @"pressure unknown"; };
        
        // Give the report.
        [self renderWeatherReportAtStation: in_IcaoCode
                   withLocationDescription: in_LocDesc
                                 timeStamp: aTimeStamp
                                    clouds: aClouds
         //
                             windDirection: aWindDirection
                                 windSpeed: aWindSpeed
                               temperature: aTemperature
         //
                                  humidity: aHumidity
                                  dewPoint: aDewPoint
                          seaLevelPressure: aSeaLevelPressure
         ];
        NSLog(@"Weather posted for this location.");
        aHaveObservation = YES;
    } while (false); //once through
    
    if (! aHaveObservation) {
        [self renderWeatherReportUnavailableAtStation: in_IcaoCode withLocationDescription: in_LocDesc];
        NSLog(@"No weather available for this location.");
    }
    
#if 0
    // take a look at all elements in the array
    for (id element in wholeJsonArray) {
        NSLog(@"Element: %@", [element description]);
    }
#endif
} // DoWeatherReport


- (NSString *) StringFromDictionaryElement:(NSDictionary *) in_Dict atKey:(NSString *) in_Key {
    NSString *aRetStr = nil;
    
    do{ //once through
        if ( (! in_Dict) || (! in_Key) ) break;
        
        id elemObj = [in_Dict objectForKey:in_Key];
        if (! elemObj) break;
       
        if ([elemObj isKindOfClass: [NSString class]]){
            aRetStr = (NSString *)elemObj;
            break;
        }
        
        if([elemObj isKindOfClass: [NSNumber class]]){
            NSNumber *aNumToConvert = (NSNumber *)elemObj;
            aRetStr = [aNumToConvert stringValue];
            break;
        }
    } while (false); //once through
    
    return aRetStr;
}


- (void)renderWeatherReportAtStation: (NSString *) in_IcaoCode
             withLocationDescription: (NSString *) in_StationName
                           timeStamp: (NSString *) in_TimeStamp
                              clouds: (NSString *) in_Clouds
    // -----------------------------
                       windDirection: (NSString *) in_WindDirection
                           windSpeed: (NSString *) in_WindSpeed
                         temperature: (NSString *) in_Temperature
    // -----------------------------
                            humidity: (NSString *) in_Humidity
                            dewPoint: (NSString *) in_DewPoint
                    seaLevelPressure: (NSString *) in_SeaLevelPressure
    // total of 9 string parameters
{
    if (in_IcaoCode){
        self.Label_IcaoCode.text = [NSString stringWithFormat:
                                    @"ICAO Airport Code: %@", in_IcaoCode];
    }else{
        self.Label_IcaoCode.text = @"";
    }
        // -----------------------------
    if (in_StationName){
        self.Label_StationName.text = in_StationName;
    }else{
        self.Label_StationName.text = @"";
    }
    // -----------------------------
    if (in_TimeStamp){
        self.Label_TimeStamp.text = [NSString stringWithFormat:
            @"Reported at: %@ GMT", in_TimeStamp];
    }else{
        self.Label_TimeStamp.text = @"";
    }
    // -----------------------------
    if (in_Clouds){
        self.Label_Clouds.text = [NSString stringWithFormat:
            @"Cloud cover: %@", in_Clouds];
    }else if(in_IcaoCode){
        self.Label_Clouds.text = @"Weather report unavailable.";
    }else{
        self.Label_Clouds.text = @"Please select an airport for a weather report.";
    }
    // -----------------------------
    if (in_WindSpeed && in_WindDirection){
        self.Label_Wind.text = [NSString stringWithFormat:
            @"Wind: %@ knots at %@°", in_WindSpeed, in_WindDirection];
    }else{
        self.Label_Wind.text = @"";
    }
    // -----------------------------
    if (in_Temperature){
        self.Label_Temperature.text = [NSString stringWithFormat:
            @"Temperature: %@° C", in_Temperature];
    }else{
        self.Label_Temperature.text = @"";
    }
    // -----------------------------
    if (in_Humidity){
        self.Label_Humidity.text = [NSString stringWithFormat:
            @"Humidity: %@ percent", in_Humidity];
    }else{
        self.Label_Humidity.text = @"";
    }
    // -----------------------------
    if (in_DewPoint){
        self.Label_DewPoint.text = [NSString stringWithFormat:
            @"Dew Point: %@° C", in_DewPoint];
    }else{
        self.Label_DewPoint.text = @"";
    }
    // -----------------------------
    if (in_SeaLevelPressure){
        self.Label_SeaLevelPressure.text = [NSString stringWithFormat:
            @"Air Pressure: %@mb at sea level", in_SeaLevelPressure];
    }else{
        self.Label_SeaLevelPressure.text = @"";
    }
    // -----------------------------
    NSLog(@"renderWeatherReport");
}


- (void)renderWeatherReportUnavailableAtStation: (NSString *) in_IcaoCode
                        withLocationDescription: (NSString *) in_LocDesc {
    [self renderWeatherReportAtStation: in_IcaoCode
               withLocationDescription: in_LocDesc
                             timeStamp: nil
                                clouds: nil
     //
                         windDirection: nil
                             windSpeed: nil
                           temperature: nil
     //
                              humidity: nil
                              dewPoint: nil
                      seaLevelPressure: nil
     ];
    NSLog(@"renderWeatherReportUnavailableAtStation");
}


#pragma mark -
#pragma mark - Search Bar


- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar {
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // Unknown code warning on new search text is hidden until a search is attempted and fails.
    self.Label_UnknownCode.hidden = YES;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    NSString *aSearchKey = [aSearchBar text];

    // Use search key to find an airport in our DB of known airports.
    NSInteger aLocIdx = [self LocationIdxFromCode: aSearchKey];
    
    // If search failed try possible 3 letter code for USA.
    if ( LocIdx_Unknown == aLocIdx){
        if ( 3 == [aSearchKey length] ) {
            aLocIdx = [self LocationIdxFromCode: [@"K" stringByAppendingString:aSearchKey]];
        }
    }
    
    // Set map dot and report for reqested location or clear them if no such airport is found.
    [self SelectFromLocationIdx_WithPickerUpdate: aLocIdx];
    
    // Show unknown code warning if search failed.
    if (LocIdx_Unknown == aLocIdx){
        self.Label_UnknownCode.hidden = NO;
    }
    
    // Dismiss keyboard.
    [aSearchBar resignFirstResponder]; 

    NSLog(@"searchBarSearchButtonClicked %d", aLocIdx);
}


- (void)ClearSearchTextMsgAndKbd {
    // Clear search text.
    self.searchBar.text = @"";
    
    // Clear unknown code warning.
    self.Label_UnknownCode.hidden = YES;
    
    // Dismiss keyboard.
    [self.searchBar resignFirstResponder];
} // ClearSearchTextMsgAndKbd


#pragma mark -
#pragma mark - Flipside View Controller


- (void)flipsideViewControllerDidFinish:(AW_FlipsideViewController *)controller
{
    [self.flipsidePopoverController dismissPopoverAnimated:YES];
    self.flipsidePopoverController = nil;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
        self.flipsidePopoverController = popoverController;
        popoverController.delegate = self;
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

@end
