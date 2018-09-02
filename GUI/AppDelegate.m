//
//  AppDelegate.m
//  indoorAtlasV1
//
//  Created by interns on 25/06/18.
//  Copyright © 2018 CommScope Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "Utils.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

bool flagLocationUpdated = false;
int initRouteUpdateFlag = 1;

// initializes the important properties defined in the header!
-(void) initProperties
{
    
    [self initLocationUpdateApi];   //starts updating the locaiton of the device
    
    [self initWayFinding];
    
    self.legUpdateVal = 0.01;
    
    // improve the location accuracy.... :P :P :P
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self initProperties];
    
    [self setBeginEndLocations];
    
    //self.routingPath = [self.wayfinding getRoute];
    
    
    
    NSString *routeString = @"";
    
    // NSLog the initial routing direction
    for (IARoutingLeg *leg in self.routingPath)
    {
        // do something with object1   Q
        routeString = [routeString stringByAppendingString:[NSString stringWithFormat:@"begin latitude: %f longitude: %f\n end latitude: %f longitude: %f\n direction: %f\ndistance: %f\n\n",leg.begin.latitude, leg.begin.longitude, leg.end.latitude, leg.end.longitude,leg.direction,leg.length]];
        
        //NSLog(@"begin latitude: %f longitude: %f\n end latitude: %f longitude: %f\n direction: %f",leg.begin.latitude, leg.begin.longitude, leg.end.latitude, leg.end.longitude, leg.direction);
    }
    
    
    [self printRoute:self.routingPath];
    self.updatedRoute = routeString;
    
     
    return YES;
}

// UPDATE LOCATION CALL BACK
- (void)indoorLocationManager:(IALocationManager *)manager didUpdateLocations:(NSArray *)locations
{

    // sets the current location in the properties.
    self.currentLocation = (IALocation *)locations.lastObject;
    NSLog(@"current location object updated  %@ %f", self.currentLocation, self.currentLocation.location.coordinate.latitude);
    
    /////////////////////////////////////////////////////////////////////////////////
    CLLocation *l = [(IALocation *)locations.lastObject location];
    
    _latitude = [NSString stringWithFormat:@"%f",l.coordinate.latitude];
    _longitude = [NSString stringWithFormat:@"%f",l.coordinate.longitude];
    
    NSDictionary *dict = [[NSDictionary alloc]  initWithObjects:@[_latitude,_longitude] forKeys:@[@"latitude",@"longitude"]];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"LocationUpdated" object:dict];
    
    NSLog(@"position changed to coordinate: %fx%f",
          l.coordinate.latitude, l.coordinate.longitude);
    /////////////////////////////////////////////////////////////////////////////////
    
    
    NSLog(@"THRESHOLD %f", [Utils getDistanceFormula:self.currentLocation pointB:_currentRoutingLeg.end]);
    NSLog(@"current location: %fx%f\tcurrent routing destination: %fx%f", self.currentLocation.location.coordinate.latitude, self.currentLocation.location.coordinate.longitude, _currentRoutingLeg.end.latitude, _currentRoutingLeg.end.longitude);

    // code to choose the routing leg
    if([Utils getDistanceFormula:self.currentLocation pointB:_currentRoutingLeg.end] <= _legUpdateVal || initRouteUpdateFlag==1)
    {
        initRouteUpdateFlag = 0;
        NSLog(@"Route leg changed");
        [self getRouteAndSetDirection];
    }
    
    
}

// decides whether the current leg should be updated or not
-(BOOL) shouldUpdateLeg:(IALocation *) currentLocation
{
    double srcLatitude = currentLocation.location.coordinate.latitude;
    double srcLongitude = currentLocation.location.coordinate.longitude;
    
    double dstLatitude = self.currentRoutingLeg.end.latitude;
    double dstLongitude = self.currentRoutingLeg.end.longitude;
    
    
    
    return false;
}

     // sets locationManager delegate to self
     // sets distance filter
     // starts updating locations.
-(void)initLocationUpdateApi
{
    NSString *kAPIKey = @"e525eede-5d1e-4b08-a8eb-6c453728f5c0";
    //NSString *kAPIKey = @"4c163b66-9277-4ddc-9290-f59aa67a9ac2";
    
    NSString *kAPISecret =
    @"1C94gN1kVj/CjZ0xVeRlDf4+2adwK42qNMsMX9b91TKeT0tXkxGbXBpeM+bVWciBFqqy9k4I603Hfr8cjGzJKSmilzA0pkjuVBj4XyT71PRZZQ1g5fb3FoqvJdfDCA==";
    //NSString *kAPISecret =
    @"wJNbGRMTLS0CxB/tN0a0Yu23LIBnANyCd3vPS79gjXZ+lek9PgGQJ9QpxCxK9LWtjwP/eMz7n1jQKwcIbKqe15I0h4WPBowcMP/X5H2BXPYIG6jLOVdiEd7WPvmf+A==";
    
    
    // Get IALocationManager shared instance and point delegate to receiver

 self.locationManager = [IALocationManager sharedInstance];
    self.locationManager.location = [IALocation locationWithFloorPlanId:@"a6778905-0dcb-4deb-b74c-51bd8d81796b"];
    self.locationManager.delegate = self;
    
    // Set IndoorAtlas API key and secret
    [self.locationManager setApiKey:kAPIKey andSecret:kAPISecret];
    
    // Set distance filter
    CLLocationDistance location = 0.5;
    self.locationManager.distanceFilter = location;
    
    
    // Request location updates
    [self.locationManager startUpdatingLocation];

}

// initializes the wayfinding object with the json graph
-(void) initWayFinding
{
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"wayfinding-graph" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filepath];
    NSString* string = [[NSString alloc] initWithBytes:[data bytes]
                                                length:[data length]
                                              encoding:NSUTF8StringEncoding];
    
    //NSLog(@"TDSK!!!!!\n\n\n %@", string);
    _wayfinding = [[IAWayfinding alloc] initWithGraph:string];
}


// set the routing path with src--> current location, destination--> parameter
-(void) getRouteAndSetDirection
{
    // set the source as the current location
    [_wayfinding setLocationWithLatitude: self.currentLocation.location.coordinate.latitude Longitude:self.currentLocation.location.coordinate.longitude Floor:2];

    [_wayfinding setDestinationWithLatitude:self.currentDestinationLatitude Longitude:self.currentDestinationLongitude Floor:2];
    
    self.routingPath = [_wayfinding getRoute];
    
    // checks the validity of the obtained routing path
    if([self.routingPath count]>1)
    {
        NSLog(@"routing path valid\n");
        self.currentRoutingLeg = self.routingPath[1];
        [self sendDirectionNotification: self.currentRoutingLeg.direction];
        [self sendRouteNotification];
        
    }
    else{
        NSLog(@"\n\n\n\n\n\nNONSENSE ROUTING LEG, leg count is 1!!!!\n\n\n");
    }
    
}
// sets the source (begin) and end (destination) locations of wayfinding.
-(void) setBeginEndLocations
{
//    self.currentDestinationLatitude = 17.44825568;
//    self.currentDestinationLongitude = 78.38314542;

    self.currentDestinationLatitude = 17.448193;
    self.currentDestinationLongitude = 78.383049;
    
    // destination
    [self.wayfinding setDestinationWithLatitude:self.currentDestinationLatitude Longitude:self.currentDestinationLongitude Floor:2];
    
    // source
//    [self.wayfinding setLocationWithLatitude:17.44845567 Longitude:78.38297546 Floor:2];
    
    [self.wayfinding setLocationWithLatitude:17.44841253 Longitude:78.38306902 Floor:2];
}


// has to be called after the route property is assigned
// tells the receiver that the route is updated.
-(void) sendRouteNotification
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"RouteUpdated" object:nil];
}

-(void) sendDirectionNotification: (double) direction
{
    NSString *strDirection = [NSString stringWithFormat: @"%f", direction];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DirectionUpdated" object:strDirection];
}

//-(void)updateRoutingLeg:(CLLocation *) location
//{
//    NSString *direction = @"";
//    if([self.currentRoutingLeg isEqual:self.routingPath.lastObject])
//    {
//        NSLog(@"Destination Reached");
//        direction = @"Destination Reached";
//        return;
//    }
//    if(![Utils getDistance:_currentRoutingLeg.begin pointB:_currentRoutingLeg.end pointC:location])
//    {
//        self.currentRoutingLeg = self.routingPath[++_routingLegIndex];
//        NSLog(@"%f",self.currentRoutingLeg.direction);
//        direction = [NSString stringWithFormat:@"%f",self.currentRoutingLeg.direction];
//    }
//    else{
//        NSLog(@"%f",self.currentRoutingLeg.direction);
//        direction = [NSString stringWithFormat:@"%f",self.currentRoutingLeg.direction];
//    }
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"DirectionUpdated" object:direction];
//
//}

////////////////////////////////////// MAP OVERLAY ////////////////////////////
-(void) initMapOverlay{
    
}
// Handling region enter events
- (void)indoorLocationManager:(IALocationManager *)manager didEnterRegion:(IARegion *)region
{
    NSString *stringData;
    
    switch (region.type) {
            
        case kIARegionTypeVenue:
            NSLog(@"Entered venue %@", region.identifier);
            
            stringData = [NSString stringWithFormat:@"enter VENUE:\n %@", region.identifier];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"RegionUpdated" object:stringData];
            break;
            
        case kIARegionTypeFloorPlan:
            NSLog(@"Entered floor plan %@", region.identifier);
            stringData = [NSString stringWithFormat:@"enter REGION:\n %@", region.name];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"RegionUpdated" object:stringData];
            break;
    }
}

// Handling region exit events
- (void)indoorLocationManager:(IALocationManager *)manager didExitRegion:(IARegion *)region
{
    NSString *stringData;
    switch (region.type) {
        case kIARegionTypeVenue:
            NSLog(@"Exit venue %@", region.identifier);
            
            stringData = [NSString stringWithFormat:@"exit VENUE:\n %@", region.identifier];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"RegionUpdated" object:stringData];
            break;
            
        case kIARegionTypeFloorPlan:
            NSLog(@"Exit floor plan %@", region.identifier);
            
            stringData = [NSString stringWithFormat:@"exit REGION:\n %@", region.identifier];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"RegionUpdated" object:stringData];
            break;
    }
}

//////// utils //////////

-(void) printRoute:(NSArray *) route
{
    NSLog(@"\n\n\nROUTE IS \n\n\n");
    
    for (IARoutingLeg *leg in route) {
        // do something with object
        NSLog(@"begin latitude: %f longitude: %f\n end latitude: %f longitude: %f\n direction: %f",leg.begin.latitude, leg.begin.longitude, leg.end.latitude, leg.end.longitude, leg.direction);
    }
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
