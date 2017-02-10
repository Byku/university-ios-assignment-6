//
//  Preferences.h
//  PasswordManager
//
//  Created by Maxim Zabelin on 19/02/14.
//  Copyright (c) 2014 Noveo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PasswordStrength) {
    PasswordStrengthWeak    = 5,
    PasswordStrengthMedium  = 10,
    PasswordStrengthDefault = PasswordStrengthMedium,
    PasswordStrengthStrong  = 15
};


typedef NS_ENUM (NSInteger, StorageType) {
    StorageTypeUserDefaults = 0,
    StorageTypeFilesOnDevice = 1,
//    StorageTypeSQL = 2,
    StorageTypeDefault = StorageTypeFilesOnDevice,
};


@interface Preferences : NSObject

/**
 *  Returns the strength rate of the passwords the applications generates.
 */
@property (nonatomic, readwrite) NSInteger passwordStrength;

/**
 *  Returns the type of the passwords storage.
 */
@property (nonatomic, readwrite) NSInteger storageType;

/**
 *  Returns the shared preferences object.
 */
+ (instancetype)standardPreferences;

@end
