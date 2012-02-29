//
//  EmotishAppDelegate.m
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmotishAppDelegate.h"
#import <Parse/Parse.h>
#import "PushConstants.h"

@implementation EmotishAppDelegate

@synthesize coreDataManager=_coreDataManager;
@synthesize rootNavController=_rootNavController, galleryViewController = _galleryViewController;
@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize notificationAlertView=_notificationAlertView, notificationPhotoServerID=_notificationPhotoServerID;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Parse setApplicationId:@"8VoQU9OtiIDLKAtVhUFEhfa4mnnEbNcLgl3BeOYC" 
                  clientKey:@"j06nZDbhyjKesivCFrTgciBfxuPVVwoQCxV95I9P"];
    [Parse setFacebookApplicationId:@"247509625333388"];

    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
    
    if ([PFUser currentUser] == nil) {
        [self.coreDataManager deleteAllLikes];
        [self.coreDataManager saveCoreData];
    }

    // For server database QA...
//    PFQuery * specialQuery = [PFQuery queryWithClassName:@"Photo"];
//    PFObject * photo = [specialQuery getObjectWithId:@"t4Y2eS153G"];
//    NSData * imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"happy-bob-1329529876.jpeg"], 1.0);
//    PFFile * imageFile = [PFFile fileWithName:@"happy-bob-1329529876.jpeg" data:imageData];
//    [imageFile save];
//    [photo setObject:imageFile forKey:@"image"];
//    [photo save];
    
//    BOOL shouldLogOut = !([[NSUserDefaults standardUserDefaults] boolForKey:@"OneTimeLogOutComplete2"]);
//    if (shouldLogOut) {
//        NSLog(@"Forcibly logging current user out");
//        PFUser * currentUser = [PFUser currentUser];
//        if (currentUser != nil) {
//            [PFPush unsubscribeFromChannelInBackground:currentUser.objectId];
//        }
//        [PFUser logOut];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"OneTimeLogOutComplete2"];
//    }
    
    self.coreDataManager = [[CoreDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
//    NSArray * allFeelings = [self.coreDataManager getAllObjectsForEntityName:@"Feeling" predicate:nil sortDescriptors:nil];
//    BOOL shouldFlush = !([[NSUserDefaults standardUserDefaults] boolForKey:@"OneTimeDatabaseFlushComplete-CleaningUpPulledInData3"]);
//    if (shouldFlush && allFeelings != nil && allFeelings.count > 0) {
//        NSLog(@"Flushing database");
//        for (Feeling * feeling in [self.coreDataManager getAllObjectsForEntityName:@"Feeling" predicate:nil sortDescriptors:nil]) {
//            [self.coreDataManager.managedObjectContext deleteObject:feeling];
//        }
////        for (User * user in [self.coreDataManager getAllObjectsForEntityName:@"User" predicate:nil sortDescriptors:nil]) {
////            [self.coreDataManager.managedObjectContext deleteObject:user];
////        }
//        for (Photo * photo in [self.coreDataManager getAllObjectsForEntityName:@"Photo" predicate:nil sortDescriptors:nil]) {
//            [self.coreDataManager.managedObjectContext deleteObject:photo];
//        }
//        [self.coreDataManager saveCoreData];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"OneTimeDatabaseFlushComplete-CleaningUpPulledInData3"];
//    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.galleryViewController = [[GalleryViewController alloc] initWithNibName:@"GalleryViewController" bundle:[NSBundle mainBundle]];
    self.galleryViewController.coreDataManager = self.coreDataManager;
    
    self.rootNavController = [[UINavigationController alloc] initWithRootViewController:self.galleryViewController];
    self.rootNavController.navigationBarHidden = YES;

    self.window.rootViewController = self.rootNavController;
    [self.window makeKeyAndVisible];
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self saveContext];
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[PFUser facebook] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[PFUser facebook] handleOpenURL:url]; 
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    NSLog(@"application:didRegisterForRemoteNotificationsWithDeviceToken:");
    // Tell Parse about the device token.
    [PFPush storeDeviceToken:newDeviceToken];
    // Subscribe to the global broadcast channel.
    NSLog(@"Subscribing to channel \"\"");
    [PFPush subscribeToChannelInBackground:@"" block:^(BOOL succeeded, NSError * error){
        if (succeeded) {
            NSLog(  @"Successfully subscribed to channel \"\"");
        } else {
            NSLog(  @"Failed to subscribe to channel \"\"");
        }
    }];
    PFUser * currentUser = [PFUser currentUser];
    if (currentUser != nil) {
        NSLog(@"Subscribing to channel %@", currentUser.objectId);
        [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"%@%@", PUSH_USER_CHANNEL_PREFIX, currentUser.objectId] block:^(BOOL succeeded, NSError * error){
            if (succeeded) {
                NSLog(  @"Successfully subscribed to channel %@", currentUser.objectId);
            } else {
                NSLog(  @"Failed to subscribe to channel %@", currentUser.objectId);
            }
        }];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"EmotishAppDelegate application didReceiveRemoteNotification %@", userInfo);
    self.notificationPhotoServerID = [userInfo objectForKey:PUSH_LIKED_PHOTO_SERVER_ID];
    if (self.notificationPhotoServerID == nil) {
        [PFPush handlePush:userInfo];
    } else {
        if (application.applicationState == UIApplicationStateActive) {
            NSLog(@"Application is active");
            self.notificationAlertView = [[UIAlertView alloc] initWithTitle:@"Emotish" message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Show Me", nil];
            self.notificationAlertView.delegate = self;
            [self.notificationAlertView show];
        } else {
            NSLog(@"Application was inactive");
            // Should navigate user to photo...
            [self attemptNavigateToPhotoWithServerID:self.notificationPhotoServerID];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.notificationAlertView && buttonIndex != self.notificationAlertView.cancelButtonIndex) {
        // Should navigate user to photo...
        [self attemptNavigateToPhotoWithServerID:self.notificationPhotoServerID];
    }
    self.notificationAlertView = nil;
}

- (void)attemptNavigateToPhotoWithServerID:(NSString *)photoServerID {
    // Currently either...
    // - In Gallery
    // - In Feeling or User PhotosStrip
    // - In Camera View or Photo Submission Screen
    // - In Settings
    UIAlertView * inDevelopmentAlertView = [[UIAlertView alloc] initWithTitle:@"In Development..." message:@"Sorry, we can't yet navigate you to the photo that was liked - we're working on this feature!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [inDevelopmentAlertView show];
//    [self.rootNavController popToRootViewControllerAnimated:NO];
//    [self.galleryViewController 
//    if (self.rootNavController.visibleViewController == self.galleryViewController) {
//        
//    } else {
//        
//    }
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Emotish" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Emotish.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES], 
                              NSMigratePersistentStoresAutomaticallyOption, 
                              [NSNumber numberWithBool:YES], 
                              NSInferMappingModelAutomaticallyOption, 
                              nil];
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
