//
//  ViewController.h
//  indoorAtlasV1
//
//  Created by interns on 25/06/18.
//  Copyright © 2018 CommScope Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IndoorAtlasWayfinding/wayfinding.h>
//////
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
//////

@interface ViewController : UIViewController
/////////
//@end
//API_AVAILABLE(ios(11.0))
//@interface ARViewController : UIViewController
//@property (strong, nonatomic) IBOutlet ARSCNView *sceneView;
/////////
<UINavigationControllerDelegate> {
    UIViewController *_lastViewController;
}
@property (strong, nonatomic) IBOutlet UILabel *lblLatitude;
@property (strong, nonatomic) IBOutlet UILabel *lblLongitude;



@property (strong, nonatomic) IBOutlet UILabel *lblFloorPlan;

@property (strong, nonatomic) IBOutlet UILabel *lblRoute;
@property (strong, nonatomic) IBOutlet UILabel *lblDirection;


@end

