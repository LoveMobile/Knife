//
//  KNIAppDelegate.m
//  The Knife
//
//  Created by Brian Drell on 9/16/14.
//  Copyright (c) 2014 Brian Drell. All rights reserved.
//

#import "KNIAppDelegate.h"
@import CloudKit;

// Don't mind this stuff. Just testing some things.

void reverse_(char *string)
{
    char *begin = string;
    char *end = begin;
    while (end && *end) {
        end++;
    }
    // Don't reverse the null at the end.
    end--;
    
    while (end > begin) {
        char temp = *end;
        *end = *begin;
        *begin = temp;
        end--;
        begin++;
    }
}

void reverse(char *string)
{
    size_t length = strlen(string) - 1;
    for (size_t ndx = 0; ndx < length/2; ndx++) {
        char temp = string[ndx];
        string[ndx] = string[length - ndx];
        string[length - ndx] = temp;
    }
}

char* provideReverse(char *string)
{
    char *newBuffer = malloc(strlen(string)*sizeof(char));
    char *pointer = string;
    while (pointer && *pointer) {
        pointer++;
    }
    pointer--;
    
    for (int ndx = 0; ndx < strlen(string); ndx++) {
        newBuffer[ndx] = *pointer--;
        if (ndx == strlen(string) - 1) {
            newBuffer[ndx + 1] = '\0';
        }
    }
    return newBuffer;
}

#define MIXPANEL_TOKEN @"bd2c71c254664e8b2bdeed578f1ab0bc"

@interface KNIAppDelegate ()

@end

@implementation KNIAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    char string[] = "Hey, that's a C string.";
//    reverse(string);
//    printf("%s\n", string);
    
    [self.window setTintColor:[UIColor colorWithWhite:0.6 alpha:1]];
    
    // Register for push notifications
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications];
    
    [self setupAnalyticsWithLaunchOptions:launchOptions];
    [self setupGlobalAppearances];
    
    return YES;
}

- (void)setupAnalyticsWithLaunchOptions:(NSDictionary *)launchOptions
{
    if (launchOptions) {
        [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN launchOptions:launchOptions];
    } else {
        [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    }
}

- (void)setupGlobalAppearances
{
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    self.pushToken = deviceToken;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    CKNotification *cloudKitNotification = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
    if (cloudKitNotification.notificationType == CKNotificationTypeQuery) {
        CKRecordID *recordID = [(CKQueryNotification *)cloudKitNotification recordID];
        NSLog(@"issue now available: %@", recordID);
    }
}

@end
