//
//  EmotishAppDelegate.m
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmotishAppDelegate.h"
#import "UIImage+LocalStore.h"
#import <Parse/Parse.h>

@implementation EmotishAppDelegate

@synthesize coreDataManager=_coreDataManager;
@synthesize galleryViewController = _galleryViewController;
@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize tempSeedFeelings=_tempSeedFeelings;
@synthesize tempSeedUsernames=_tempSeedUsernames;
@synthesize tempSeedImageFilenames=_tempSeedImageFilenames;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Parse setApplicationId:@"8VoQU9OtiIDLKAtVhUFEhfa4mnnEbNcLgl3BeOYC" 
                  clientKey:@"j06nZDbhyjKesivCFrTgciBfxuPVVwoQCxV95I9P"];
    
    self.coreDataManager = [[CoreDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
    NSArray * allFeelings = [self.coreDataManager getAllObjectsForEntityName:@"Feeling" predicate:nil sortDescriptors:nil];
    BOOL shouldFlush = !([[NSUserDefaults standardUserDefaults] boolForKey:@"OneTimeDatabaseFlushComplete-MovingToRemoteData"]);
    if (shouldFlush && allFeelings != nil && allFeelings.count > 0) {
        NSLog(@"Flushing database");
        for (Feeling * feeling in [self.coreDataManager getAllObjectsForEntityName:@"Feeling" predicate:nil sortDescriptors:nil]) {
            [self.coreDataManager.managedObjectContext deleteObject:feeling];
        }
        for (User * user in [self.coreDataManager getAllObjectsForEntityName:@"User" predicate:nil sortDescriptors:nil]) {
            [self.coreDataManager.managedObjectContext deleteObject:user];
        }
        [self.coreDataManager saveCoreData];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"OneTimeDatabaseFlushComplete-MovingToRemoteData"];
    }
//    allFeelings = [self.coreDataManager getAllObjectsForEntityName:@"Feeling" predicate:nil sortDescriptors:nil];
//    BOOL onlyAllowFeelingsWithAppropriateImages = YES;
//    if (allFeelings == nil || allFeelings.count == 0) {
//        NSLog(@"Starting to seed database");
//        for (NSString * feelingWord in self.tempSeedFeelings) {
//            NSLog(@"  Adding %@", feelingWord);
//            NSSet * imageFilenamesToChooseFrom = [self tempSeedImageFilenamesForFeelingWord:feelingWord];
//            BOOL appropriateFilenamesAvailable = imageFilenamesToChooseFrom.count > 0;
//            if (onlyAllowFeelingsWithAppropriateImages && !appropriateFilenamesAvailable) {
//                NSLog(@"    No photos available, skipping.");
//                continue;
//            }
//            int photosCount = 0;
//            if (appropriateFilenamesAvailable) {
//                photosCount = imageFilenamesToChooseFrom.count;
//            } else {
//                imageFilenamesToChooseFrom = self.tempSeedImageFilenames;
//                photosCount = (arc4random() % 10) + 1;
//            }
//            NSArray * filenamesArray = [imageFilenamesToChooseFrom allObjects];
//            NSLog(@"    Adding photos");
//            for (int i=0; i<photosCount; i++) {
//                int imageIndex = appropriateFilenamesAvailable ? i : (arc4random() % filenamesArray.count);
//                NSString * imageFilename = [filenamesArray objectAtIndex:imageIndex];
//                NSRange hyphenRange = [imageFilename rangeOfString:@"-"];
//                NSString * userIndicatorString = [[imageFilename substringFromIndex:hyphenRange.location + 1] stringByReplacingOccurrencesOfString:@".jpg" withString:@""];
//                int suggestedUserIndex = userIndicatorString.intValue - 1;
//                int userIndex = suggestedUserIndex < self.tempSeedUsernames.count ? suggestedUserIndex : (arc4random() % self.tempSeedUsernames.count);
//                NSString * username = [self.tempSeedUsernames objectAtIndex:userIndex];
//                NSLog(@"      Adding %@ for user %@", imageFilename, username);
//                [self.coreDataManager addPhotoWithFilename:imageFilename forFeelingWord:feelingWord fromUsername:username];
//            }
//            NSLog(@"    Added %d %@ %@ photos", photosCount, appropriateFilenamesAvailable ? @"fitting" : @"random", feelingWord);
//        }
//        NSLog(@"Finished seeding database");
//    } else {
//        NSLog(@"Reporting on existing data");
//        for (Feeling * feeling in allFeelings) {
//            NSLog(@"%@", feeling.word);
//            for (Photo * photo in feeling.photos) {
//                NSLog(@"  %@ photo", photo.user.name);
//            }
//        }
//    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.galleryViewController = [[GalleryViewController alloc] initWithNibName:@"GalleryViewController" bundle:[NSBundle mainBundle]];
    self.galleryViewController.coreDataManager = self.coreDataManager;
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:self.galleryViewController];
    navigationController.navigationBarHidden = YES;

    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
//    BOOL seedAnonymousUserComplete = ([[NSUserDefaults standardUserDefaults] boolForKey:@"specialSeedComplete-01"]);
//    if (!seedAnonymousUserComplete) {
//        PFUser * user = [PFUser user];
//        user.username = @"anonymous";
//        user.password = @"anonymous";
//        user.email = @"danbretl@gmail.com";
//        BOOL success = [user signUp];
//        NSLog(@"Signed up anonymous user, success? %d", success);
//        [[NSUserDefaults standardUserDefaults] setBool:success forKey:@"specialSeedComplete-01"];
//    }
    
//    BOOL seedAnonymousImagesComplete = ([[NSUserDefaults standardUserDefaults] boolForKey:@"seedAnonymousImagesComplete3"]);
//    if (!seedAnonymousImagesComplete) {
//        // Log in as anonymous user
//        PFUser * currentUser = [PFUser logInWithUsername:@"anonymous" password:@"anonymous"];
//        NSLog(@"Retrieved currentUser as %@", currentUser.username);
//        NSLog(@"Starting to seed database");
//        for (NSString * feelingWord in self.tempSeedFeelings) {
//            PFQuery * query = [PFQuery queryWithClassName:@"Feeling"];
//            [query whereKey:@"word" equalTo:feelingWord.lowercaseString];
//            PFObject * feeling = [query getFirstObject];
//            NSLog(@"  Adding %@", feelingWord);
//            NSSet * imageFilenamesToChooseFrom = [self tempSeedImageFilenamesForFeelingWord:feelingWord];
//            BOOL appropriateFilenamesAvailable = imageFilenamesToChooseFrom.count > 0;
//            if (onlyAllowFeelingsWithAppropriateImages && !appropriateFilenamesAvailable) {
//                NSLog(@"    No photos available, skipping.");
//                continue;
//            }
//            int photosCount = 0;
//            if (appropriateFilenamesAvailable) {
//                photosCount = imageFilenamesToChooseFrom.count;
//            } else {
//                imageFilenamesToChooseFrom = self.tempSeedImageFilenames;
//                photosCount = (arc4random() % 10) + 1;
//            }
//            if (photosCount > 0) {
//                if (feeling == nil) {
//                    feeling = [PFObject objectWithClassName:@"Feeling"];
//                    [feeling setObject:feelingWord.lowercaseString forKey:@"word"];
//                    [feeling save];
//                }
//                NSLog(@"Retrieved feeling %@", [feeling objectForKey:@"word"]);
//            }
//            NSArray * filenamesArray = [imageFilenamesToChooseFrom allObjects];
//            NSLog(@"    Adding photos");
//            for (int i=0; i<photosCount; i++) {
//                int imageIndex = appropriateFilenamesAvailable ? i : (arc4random() % filenamesArray.count);
//                NSString * imageFilename = [filenamesArray objectAtIndex:imageIndex];
////                NSRange hyphenRange = [imageFilename rangeOfString:@"-"];
////                NSString * userIndicatorString = [[imageFilename substringFromIndex:hyphenRange.location + 1] stringByReplacingOccurrencesOfString:@".jpg" withString:@""];
////                int suggestedUserIndex = userIndicatorString.intValue - 1;
////                int userIndex = suggestedUserIndex < self.tempSeedUsernames.count ? suggestedUserIndex : (arc4random() % self.tempSeedUsernames.count);
////                NSString * username = [self.tempSeedUsernames objectAtIndex:userIndex];
//                NSString * username = @"anonymous";
//                NSLog(@"      Adding %@ for user %@", imageFilename, username);
////                [self.coreDataManager addPhotoWithFilename:imageFilename forFeelingWord:feelingWord fromUsername:username];
//                NSData * imageData = UIImageJPEGRepresentation([UIImage imageNamed:imageFilename], 1.0);
//                NSDate * now = [NSDate date];
//                //    NSString * todayFormatted = [dateFormatter stringFromDate:now];
//                NSString * nowString = [NSString stringWithFormat:@"%d", abs([now timeIntervalSince1970])];
//                NSString * filename = [NSString stringWithFormat:@"%@-%@-%@.jpg", [feelingWord.lowercaseString  stringByReplacingOccurrencesOfString:@" " withString:@""], username, nowString];
//                PFFile * imageFile = [PFFile fileWithName:filename data:imageData];
//                [imageFile save];
//                PFObject * photo = [PFObject objectWithClassName:@"Photo"];
//                [photo setObject:imageFile forKey:@"image"];
//                [photo setObject:currentUser forKey:@"user"];
//                [photo setObject:feeling forKey:@"feeling"];
//                BOOL success = [photo save];
//                NSLog(@"PFObject photo saved successfully? %d", success);
//            }
//            NSLog(@"    Added %d %@ %@ photos", photosCount, appropriateFilenamesAvailable ? @"fitting" : @"random", feelingWord);
//        }
//        NSLog(@"Finished seeding database");
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"seedAnonymousImagesComplete3"];
//    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
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

- (NSArray *)tempSeedFeelings {
    if (_tempSeedFeelings == nil) {
        _tempSeedFeelings = [NSArray arrayWithObjects:@"Abridged", @"Absent", @"Accomplished", @"Aggressive", @"Amateurish", @"Ambiguous", @"Ambitious", @"Amused", @"Angry", @"Anguish", @"Anticipatory", @"Anxious", @"Apathetic", @"Apologetic", @"Arctic", @"Arrrggressive", @"Astonished", @"Attacked", @"Awake", @"Awesome", @"Bad Sport", @"Baffled", @"Bangladesh", @"Bedraggled", @"Befogged", @"Befuddled", @"Behind", @"Bemused", @"Better", @"Bewildered", @"Blessed", @"Blocked", @"Bologna", @"Bored", @"Bouncy", @"British", @"Broke", @"Businesslike", @"Busy", @"Caffeinated", @"Calculating", @"Calm", @"Cantankerous", @"Captivated", @"Catching Up", @"Challenged", @"Chaos", @"Cheerful", @"Cheesy", @"Chilly", @"Chipper", @"Clever", @"Clueless", @"Cocky", @"Comfortable", @"Competitive", @"Complex", @"Concerned", @"Confident", @"Conflicted", @"Confused", @"Confuzzled", @"Congested", @"Contemplative", @"Content", @"Cooperative", @"Corny", @"Counterclockwise", @"Cozy", @"Crampy", @"Crushed", @"Curious", @"Daring", @"Defeated", @"Defensive", @"Deflated", @"Delighted", @"Delirious", @"Demoralized", @"Depressed", @"Desperate", @"Determined", @"Devastated", @"Disappointed", @"Disgruntled", @"Disgusted", @"Disinterested", @"Dismal", @"Dismayed", @"Dissatisfied", @"Distracted", @"Distraught", @"Doubtful", @"Dreamy", @"Driven", @"Drunk", @"Dry", @"Dumb", @"Dumbfounded", @"Dunderhead", @"Eager", @"Ebullient", @"Ecstatic", @"Edgy", @"Elated", @"Embarassed", @"Emboldened", @"Entertained", @"Enthusiastic", @"Entranced", @"Envious", @"Epic", @"Euphoric", @"Excitable", @"Excited", @"Exhausted", @"Exhilarated", @"Exuberant", @"Exultant", @"Fair", @"Fallow", @"Fantastic", @"Fatigued", @"Flabbergasted", @"Flauty", @"Flighty", @"Fluctuating", @"Fluid", @"Flummoxed", @"Flustered", @"Focused", @"Foiled", @"Foolish", @"Fortunate", @"Frantic", @"Fried", @"Frustrated", @"Full", @"Fumbling", @"Funky", @"Futile", @"Fuzzy Muzzle", @"Gassy", @"German", @"Giggly", @"Glorious", @"Good", @"Grumpy", @"Happy", @"Happyful", @"Heartbroken", @"Hesitant", @"Hobbit-Like", @"Homicidal", @"Hoodwinked", @"Hopeful", @"Hopeless", @"Horrified", @"Hot", @"Hungry", @"Hypnotized", @"Icky", @"Idiotic", @"Ill", @"Impatient", @"Impressed", @"Incredulous", @"Indifferent", @"Indomitable", @"Inept", @"Intellectual", @"Interested", @"Intrigued", @"Inventive", @"Jittery", @"Joyous", @"Jumpy", @"Kissy", @"Lackluster", @"Learned", @"Lighthearted", @"Limited", @"Lively", @"Lost", @"Lounging", @"Lovely", @"Lucky", @"Lugubrious", @"Malaise", @"Maple Candy", @"Martyred", @"Meeple", @"Mellisugent", @"Mellow", @"Merlot", @"Merry", @"Miffed", @"Mischievous", @"Mystified", @"Nervous", @"No Regrets", @"No Regrets", @"Nonchalant", @"Nostalgic", @"Numb", @"Observant", @"On Edge", @"Oppressed", @"Optimistic", @"Oriental", @"Out of Sorts", @"Overwhelmed", @"Panicky", @"Parental", @"Pathetic", @"Pensive", @"Perfectly Happy", @"Peripatetic", @"Perplexed", @"Persevering", @"Persistent", @"Pessimistic", @"Pissed Off", @"Pizza", @"Playful", @"Pleased", @"Plintzy", @"Positive", @"Postlapsarian", @"Pouting", @"Power Hungry", @"Pumpkinhead", @"Puzzled", @"Quick", @"Quirky", @"Quixotic", @"Quizzical", @"Reborn", @"Reinvigorated", @"Relaxed", @"Relieved", @"Resigned", @"Robotic", @"Roller Coaster", @"Rushed", @"Sad", @"Salty", @"Sarcastic", @"Satisfied", @"Scatterbrained", @"Scattered", @"Schoolboy", @"Sensitive", @"Shifty", @"Shmoosh", @"Sick", @"Silly", @"Skeptical", @"Sleepy", @"Small Ball", @"Smart", @"Smitten", @"Snarky", @"Sneaky", @"So Close", @"So Intense", @"Somnambulant", @"Sonorous", @"Speedy", @"Spirited", @"Spunky", @"Sputtering", @"Stalled", @"Steady", @"Stellar", @"Stoked", @"Stomach Ache", @"Stratified", @"Stressed", @"Stroagish", @"Struggling", @"Studious", @"Stumped", @"Stunted", @"Stupefied", @"Stupid", @"Stymied", @"Sublime", @"Subtle", @"Suffering", @"Sulky", @"Surgical", @"Surprised", @"Sweaty", @"Sweet", @"Swindled", @"Taken Aback", @"Tense", @"Thoughtful", @"Thrilled", @"Tired", @"Toasted", @"Too Cool", @"Tranquil", @"Transcendent", @"Triumphant", @"Trudging", @"Trusting", @"Umtagati", @"Uncertain", @"Uncomfortable", @"Unfocused", @"Unforgiving", @"Unicorn", @"Unlucky", @"Unmotivated", @"Unsettled", @"Unsophisticated", @"Unstoppable", @"Unwavering", @"Upset", @"Utter Despair", @"Vengeful", @"Victimized", @"Victorious", @"Vindictive", @"Wanderlust", @"Warm & Fuzzy", @"Wary", @"Weary", @"Western", @"Whimsical", @"Whingeing", @"Witch", @"Witch Doctor", @"Withdrawn", @"Woggly", @"Worried", @"Zen", nil];
    }
    return _tempSeedFeelings;
}
             
- (NSArray *)tempSeedUsernames {
    if (_tempSeedUsernames == nil) {
        _tempSeedUsernames = [NSArray arrayWithObjects:@"beccaschall", @"catiealaska", @"danbretl", @"mitchellbrooks", @"lockett", @"nishita", @"mattyh", @"ryguy", @"prudiemcgucken", @"adriane", @"feierabend", @"tilatequila", nil];
    }
    return _tempSeedUsernames;
}

- (NSSet *)tempSeedImageFilenames {
    if (_tempSeedImageFilenames == nil) {
        _tempSeedImageFilenames = [NSSet setWithObjects:@"emotish_seed_data_aggressive-1.jpg", @"emotish_seed_data_aggressive-2.jpg", @"emotish_seed_data_aggressive-3.jpg", @"emotish_seed_data_aggressive-4.jpg", @"emotish_seed_data_aggressive-5.jpg", @"emotish_seed_data_aggressive-6.jpg", @"emotish_seed_data_aggressive-7.jpg", @"emotish_seed_data_aggressive-8.jpg", @"emotish_seed_data_aggressive-9.jpg", @"emotish_seed_data_aggressive-10.jpg", @"emotish_seed_data_aggressive-11.jpg", @"emotish_seed_data_bored-1.jpg", @"emotish_seed_data_bored-2.jpg", @"emotish_seed_data_bored-3.jpg", @"emotish_seed_data_bored-4.jpg", @"emotish_seed_data_bored-5.jpg", @"emotish_seed_data_bored-6.jpg", @"emotish_seed_data_bored-7.jpg", @"emotish_seed_data_bored-8.jpg", @"emotish_seed_data_bored-9.jpg", @"emotish_seed_data_bored-10.jpg", @"emotish_seed_data_bored-11.jpg", @"emotish_seed_data_bored-12.jpg", @"emotish_seed_data_clever-1.jpg", @"emotish_seed_data_clever-2.jpg", @"emotish_seed_data_clever-3.jpg", @"emotish_seed_data_clever-4.jpg", @"emotish_seed_data_content-1.jpg", @"emotish_seed_data_content-2.jpg", @"emotish_seed_data_content-3.jpg", @"emotish_seed_data_content-4.jpg", @"emotish_seed_data_euphoric-1.jpg", @"emotish_seed_data_euphoric-2.jpg", @"emotish_seed_data_euphoric-3.jpg", @"emotish_seed_data_euphoric-4.jpg", @"emotish_seed_data_frantic-1.jpg", @"emotish_seed_data_frantic-2.jpg", @"emotish_seed_data_frantic-3.jpg", @"emotish_seed_data_frantic-4.jpg", @"emotish_seed_data_frustrated-1.jpg", @"emotish_seed_data_frustrated-2.jpg", @"emotish_seed_data_frustrated-4.jpg", @"emotish_seed_data_lucky-1.jpg", @"emotish_seed_data_lucky-2.jpg", @"emotish_seed_data_lucky-3.jpg", @"emotish_seed_data_lucky-4.jpg", @"emotish_seed_data_pissedoff-1.jpg", @"emotish_seed_data_pissedoff-2.jpg", @"emotish_seed_data_pissedoff-3.jpg", @"emotish_seed_data_pissedoff-4.jpg", @"emotish_seed_data_pouting-1.jpg", @"emotish_seed_data_pouting-2.jpg", @"emotish_seed_data_pouting-3.jpg", @"emotish_seed_data_pouting-4.jpg", @"emotish_seed_data_silly-1.jpg", @"emotish_seed_data_silly-2.jpg", @"emotish_seed_data_silly-3.jpg", @"emotish_seed_data_silly-4.jpg", @"emotish_seed_data_sneaky-1.jpg", @"emotish_seed_data_sneaky-2.jpg", @"emotish_seed_data_sneaky-3.jpg", @"emotish_seed_data_sneaky-4.jpg", @"emotish_seed_data_sointense-1.jpg", @"emotish_seed_data_sointense-2.jpg", @"emotish_seed_data_sointense-3.jpg", @"emotish_seed_data_sointense-4.jpg", @"emotish_seed_data_toocool-1.jpg", @"emotish_seed_data_toocool-2.jpg", @"emotish_seed_data_toocool-3.jpg", @"emotish_seed_data_toocool-4.jpg", @"emotish_seed_data_unicorn-1.jpg", @"emotish_seed_data_unicorn-2.jpg", @"emotish_seed_data_unicorn-3.jpg", @"emotish_seed_data_unicorn-4.jpg", @"emotish_seed_data_unlucky-1.jpg", @"emotish_seed_data_unlucky-3.jpg", @"emotish_seed_data_unlucky-4.jpg", @"emotish_seed_data_utterdespair-1.jpg", @"emotish_seed_data_utterdespair-2.jpg", @"emotish_seed_data_utterdespair-3.jpg", @"emotish_seed_data_utterdespair-4.jpg", @"emotish_seed_data_vindictive-1.jpg", @"emotish_seed_data_vindictive-2.jpg", @"emotish_seed_data_vindictive-3.jpg", @"emotish_seed_data_vindictive-4.jpg", nil];
    }
    return _tempSeedImageFilenames;
}

- (NSSet *)tempSeedImageFilenamesForFeelingWord:(NSString *)feelingWord {
    NSString * feelingWordFormatted = [feelingWord.lowercaseString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSSet * filteredSet = [self.tempSeedImageFilenames filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary * bindings){
        NSString * evaluatedString = (NSString *)evaluatedObject;
        evaluatedString = [evaluatedString stringByReplacingOccurrencesOfString:LOCAL_IMAGE_SEED_PREFIX withString:@""];
        return evaluatedString.length >= feelingWordFormatted.length && [[evaluatedString substringToIndex:feelingWordFormatted.length] isEqualToString:feelingWordFormatted];
    }]];
    return filteredSet;
}

@end
