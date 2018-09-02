//
//  ViewController.m
//  indoorAtlasV1
//
//  Created by interns on 25/06/18.
//  Copyright © 2018 CommScope Inc. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#define kApp ((AppDelegate *)[[UIApplication sharedApplication]delegate])

API_AVAILABLE(ios(11.0))
@interface ViewController () <ARSCNViewDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set the view's delegate
    //////////////////////////////ARKIT///////////////////////////////
    NSLog(@"viewDidLoad\n");
    self.navigationController.delegate = self;
    self.sceneView.delegate = self;
    
    // Show statistics such as fps and timing information
    self.sceneView.showsStatistics = YES;
    
    SCNScene *scene = [SCNScene sceneNamed:@"arrow9.dae"];
    SCNNode *node1 = [scene.rootNode childNodeWithName:@"arrow1" recursively:true];
    node1.transform = [self transformRotation:GLKMathDegreesToRadians(90+90) distance:0];
    node1.position = SCNVector3Make( 0 ,-1, -0.6);
    
    SCNNode *node2 = [scene.rootNode childNodeWithName:@"arrow2" recursively:true];
    node2.transform = [self transformRotation:GLKMathDegreesToRadians(0+90) distance:0];
    node2.position = SCNVector3Make( 0 ,-1, -1);
    
    SCNNode *node3 = [scene.rootNode childNodeWithName:@"arrow3" recursively:true];
    node3.transform = [self transformRotation:GLKMathDegreesToRadians(0+90) distance:0];
    node3.position = SCNVector3Make( 0 ,-1, -1.4);
    
    self.sceneView.scene = scene;
    
    //////////////////////////////ARKIT END///////////////////////////////
    
    //[self updateRoute:kApp.updatedRoute];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"view did appear\n");
    [super viewDidAppear:YES];
    [self addObservers];
    
}

//////////////////arkit/////////////////////
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"View will appear called\n");
    [super viewWillAppear:animated];
    
    // Create a session configuration
    if (@available(iOS 11.0, *)) {
        AROrientationTrackingConfiguration *configuration = [AROrientationTrackingConfiguration new];
        
        configuration.worldAlignment = ARWorldAlignmentGravityAndHeading;
        // Run the view's session
        [self.sceneView.session runWithConfiguration:configuration];
    } else {
        // Fallback on earlier versions
    }if (@available(iOS 11.0, *)) {
        AROrientationTrackingConfiguration *configuration = [AROrientationTrackingConfiguration new];
    } else {
        // Fallback on earlier versions
    }
}
//////////////////arkit end/////////////////////


-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"View will disappear called\n");
    [super viewDidDisappear:YES];
    [self removeObservers];
}


//////////////////arkit/////////////////////
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
}
//////////////////arkit end/////////////////////

-(void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabels:) name:@"LocationUpdated" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRegions:) name:@"RegionUpdated" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDirection:) name:@"DirectionUpdated" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRoute2:) name:@"RouteUpdated" object:nil];
    
    
}

// the route has been updated in the appdelegate
-(void) updateRoute2:(NSNotification*)notification
{
    NSString *updatedRoute = @"hohohoohoholaaa!!!";
    updatedRoute = [Utils setRouteStringFromRoute:kApp.routingPath];
    //NSLog(@"after utils call: %@", updatedRoute);
    _lblRoute.text = updatedRoute;
}



-(void) updateDirection:(NSNotification*)notification
{
    NSString *direction = notification.object;
    _lblDirection.text = direction;
}

-(void) updateRoute:(NSString*)routeStringVal
{
    NSString *routeString = routeStringVal;
    
    [self.lblRoute performSelectorOnMainThread:@selector(setText:) withObject:routeString waitUntilDone:YES];
    
    _lblRoute.text = routeString;
}

-(void)removeObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"LocationUpdated" object:nil];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"LocationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"RouteUpdated" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DirectionUpdated" object:nil];
}

-(void)updateRegions:(NSNotification*) notification
{
    NSString *stringData = [notification object];
    _lblFloorPlan.text = stringData;
}

-(void)updateLabels:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification object];
    NSLog(@"userInfo :%@", userInfo);
    _lblLatitude.text = [userInfo objectForKey:@"latitude"];
    _lblLongitude.text = [userInfo objectForKey:@"longitude"];
    //_lblLongitude.text = [NSString stringWithFormat:@"%f", [userInfo objectForKey:@"longitude"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//////////////////////////////ARKIT///////////////////////////////

-(SCNMatrix4)transformRotation:(float)rotationY distance:(float)distance
{
    SCNMatrix4 translation = SCNMatrix4MakeTranslation(1, 1, -0.3);
    SCNMatrix4 rotation = SCNMatrix4MakeRotation(-1 * rotationY, 0, 1, 0);
    SCNMatrix4 transform = SCNMatrix4Mult(translation,rotation);
    
    return transform;
}

#pragma mark - ARSCNViewDelegate
- (void)session:(ARSession *)session didFailWithError:(NSError *)error  API_AVAILABLE(ios(11.0)){
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session  API_AVAILABLE(ios(11.0)){
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session  API_AVAILABLE(ios(11.0)){
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}
//////////////////////////////ARKIT END///////////////////////////////

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (_lastViewController) {
        [_lastViewController viewWillDisappear:animated];
    }
    
    [viewController viewWillAppear:animated];
    _lastViewController = viewController;
}

@end
