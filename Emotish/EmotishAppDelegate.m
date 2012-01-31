//
//  EmotishAppDelegate.m
//  Emotish
//
//  Created by Dan Bretl on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmotishAppDelegate.h"

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
    
    self.coreDataManager = [[CoreDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
    NSArray * allFeelings = [self.coreDataManager getAllObjectsForEntityName:@"Feeling" predicate:nil sortDescriptors:nil];
    BOOL onlyAllowFeelingsWithAppropriateImages = YES;
    if (allFeelings == nil || allFeelings.count == 0) {
        NSLog(@"Starting to seed database");
        for (NSString * feelingWord in self.tempSeedFeelings) {
            NSLog(@"  Adding %@", feelingWord);
            NSSet * imageFilenamesToChooseFrom = [self tempSeedImageFilenamesForFeelingWord:feelingWord];
            BOOL appropriateFilenamesAvailable = imageFilenamesToChooseFrom.count > 0;
            if (onlyAllowFeelingsWithAppropriateImages && !appropriateFilenamesAvailable) {
                NSLog(@"    No photos available, skipping.");
                continue;
            }
            int photosCount = 0;
            if (appropriateFilenamesAvailable) {
                photosCount = imageFilenamesToChooseFrom.count;
            } else {
                imageFilenamesToChooseFrom = self.tempSeedImageFilenames;
                photosCount = (arc4random() % 10) + 1;
            }
            NSArray * filenamesArray = [imageFilenamesToChooseFrom allObjects];
            NSLog(@"    Adding photos");
            for (int i=0; i<photosCount; i++) {
                int imageIndex = appropriateFilenamesAvailable ? i : (arc4random() % filenamesArray.count);
                NSString * imageFilename = [filenamesArray objectAtIndex:imageIndex];
                NSRange hyphenRange = [imageFilename rangeOfString:@"-"];
                NSString * userIndicatorString = [[imageFilename substringFromIndex:hyphenRange.location + 1] stringByReplacingOccurrencesOfString:@".jpg" withString:@""];
                int suggestedUserIndex = userIndicatorString.intValue - 1;
                int userIndex = suggestedUserIndex < self.tempSeedUsernames.count ? suggestedUserIndex : (arc4random() % self.tempSeedUsernames.count);
                NSString * username = [self.tempSeedUsernames objectAtIndex:userIndex];
                NSLog(@"      Adding %@ for user %@", imageFilename, username);
                [self.coreDataManager addPhotoWithFilename:imageFilename forFeelingWord:feelingWord fromUsername:username];
            }
            NSLog(@"    Added %d %@ %@ photos", photosCount, appropriateFilenamesAvailable ? @"fitting" : @"random", feelingWord);
        }
        NSLog(@"Finished seeding database");
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.galleryViewController = [[GalleryViewController alloc] initWithNibName:@"GalleryViewController" bundle:[NSBundle mainBundle]];
    self.galleryViewController.coreDataManager = self.coreDataManager;

    self.window.rootViewController = self.galleryViewController;
    [self.window makeKeyAndVisible];
    
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
        _tempSeedImageFilenames = [NSSet setWithObjects:@"aggressive-1.jpg", @"aggressive-2.jpg", @"aggressive-3.jpg", @"aggressive-4.jpg", @"aggressive-5.jpg", @"aggressive-6.jpg", @"aggressive-7.jpg", @"aggressive-8.jpg", @"aggressive-9.jpg", @"aggressive-10.jpg", @"aggressive-11.jpg", @"bored-1.jpg", @"bored-2.jpg", @"bored-3.jpg", @"bored-4.jpg", @"bored-5.jpg", @"bored-6.jpg", @"bored-7.jpg", @"bored-8.jpg", @"bored-9.jpg", @"bored-10.jpg", @"bored-11.jpg", @"bored-12.jpg", @"clever-1.jpg", @"clever-2.jpg", @"clever-3.jpg", @"clever-4.jpg", @"content-1.jpg", @"content-2.jpg", @"content-3.jpg", @"content-4.jpg", @"euphoric-1.jpg", @"euphoric-2.jpg", @"euphoric-3.jpg", @"euphoric-4.jpg", @"frantic-1.jpg", @"frantic-2.jpg", @"frantic-3.jpg", @"frantic-4.jpg", @"frustrated-1.jpg", @"frustrated-2.jpg", @"frustrated-4.jpg", @"lucky-1.jpg", @"lucky-2.jpg", @"lucky-3.jpg", @"lucky-4.jpg", @"pissedoff-1.jpg", @"pissedoff-2.jpg", @"pissedoff-3.jpg", @"pissedoff-4.jpg", @"pouting-1.jpg", @"pouting-2.jpg", @"pouting-3.jpg", @"pouting-4.jpg", @"silly-1.jpg", @"silly-2.jpg", @"silly-3.jpg", @"silly-4.jpg", @"sneaky-1.jpg", @"sneaky-2.jpg", @"sneaky-3.jpg", @"sneaky-4.jpg", @"sointense-1.jpg", @"sointense-2.jpg", @"sointense-3.jpg", @"sointense-4.jpg", @"toocool-1.jpg", @"toocool-2.jpg", @"toocool-3.jpg", @"toocool-4.jpg", @"unicorn-1.jpg", @"unicorn-2.jpg", @"unicorn-3.jpg", @"unicorn-4.jpg", @"unlucky-1.jpg", @"unlucky-3.jpg", @"unlucky-4.jpg", @"utterdespair-1.jpg", @"utterdespair-2.jpg", @"utterdespair-3.jpg", @"utterdespair-4.jpg", @"vindictive-1.jpg", @"vindictive-2.jpg", @"vindictive-3.jpg", @"vindictive-4.jpg", nil];
    }
    return _tempSeedImageFilenames;
}

- (NSSet *)tempSeedImageFilenamesForFeelingWord:(NSString *)feelingWord {
    NSString * feelingWordFormatted = [feelingWord.lowercaseString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSSet * filteredSet = [self.tempSeedImageFilenames filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary * bindings){
        NSString * evaluatedString = (NSString *)evaluatedObject;
        return evaluatedString.length >= feelingWordFormatted.length && [[evaluatedObject substringToIndex:feelingWordFormatted.length] isEqualToString:feelingWordFormatted];
    }]];
    return filteredSet;
}

@end
