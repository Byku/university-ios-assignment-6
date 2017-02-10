//
//  RecordsManager.h
//  PasswordManager
//
//  Created by Maxim Zabelin on 20/02/14.
//  Copyright (c) 2014 Noveo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordsManager : NSObject

/**
 *  Performs no initialization; please use @c -initWithURL: instead.
 */
- (id)init;

/**
 *  Initializes a newly created instance with the specifed URL.
 */
- (instancetype)initWithURL:(NSURL *)url;

/**
 *  Registers the specified record.
 */
- (void)registerRecord:(NSDictionary *)record atIndex:(NSUInteger)index;

/**
 *  Delete the specified record.
 */
- (void)deleteRecordAtIndex:(NSUInteger)index;

/**
 *  Returns the records the receiver manages.
 */
- (NSArray *)records;

/**
 *  Writes any modifications to the persistent domains to disk.
 *
 *  @return @c YES if the records were saved successfully to disk.
 */
- (BOOL)synchronize;

/**
 * Erase unused storage
 * @param storageType
 */
- (void)eraseStorage:(NSInteger)storageType;

@end
