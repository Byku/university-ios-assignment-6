#import "RecordsManager.h"
#import "Preferences.h"

static NSString *const kPasswordsArray = @"PasswordsArray";

@interface RecordsManager ()

@property (nonatomic, strong) NSMutableArray *mutableRecords;
@property (nonatomic, strong) NSURL *url;

@end

@implementation RecordsManager

#pragma mark - Initialization

- (id)init
{
    NSLog(@"Please use -initWithURL: instead.");
    [self doesNotRecognizeSelector:_cmd];

    return nil;
}

- (instancetype)initWithURL:(NSURL *)url
{
    if ((self = [super init])) {
        _url = url;
    }

    return self;
}

#pragma mark - Management of records

- (void)registerRecord:(NSDictionary *)record atIndex:(NSUInteger)index
{
    if ([record count] > 0) {
        if(index == NSIntegerMax) {
            [self.mutableRecords addObject:record];
        } else {
            self.mutableRecords[index] = record;
        }
    }
}

- (void)deleteRecordAtIndex:(NSUInteger)index
{
    [self.mutableRecords removeObjectAtIndex:index];
}

- (void)eraseStorage:(NSInteger)storageType
{
    switch (storageType)
    {
        case StorageTypeFilesOnDevice:
        {
            [@[] writeToURL:self.url atomically:YES];
        } break;
        case StorageTypeUserDefaults:
        {
            [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:kPasswordsArray];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (NSMutableArray *)mutableRecords
{
    if (!_mutableRecords) {
        switch ([[Preferences standardPreferences] storageType])
        {
            case StorageTypeFilesOnDevice:
            {
                _mutableRecords = [NSMutableArray arrayWithContentsOfURL:self.url];
            }
                break;
            case StorageTypeUserDefaults:
            {
                _mutableRecords = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:kPasswordsArray];
            }
        }
        if (![_mutableRecords count]) {
            _mutableRecords = [NSMutableArray array];
        }

    }

    return _mutableRecords;
}

- (NSArray *)records
{
    return [self.mutableRecords copy];
}

#pragma mark - Synchronisation

- (BOOL)synchronize
{
    switch ([[Preferences standardPreferences] storageType])
    {
        case StorageTypeFilesOnDevice:
        {
            return [self.mutableRecords writeToURL:self.url atomically:YES];
        }
        case StorageTypeUserDefaults:
        {
            [[NSUserDefaults standardUserDefaults] setObject:[self records] forKey:kPasswordsArray];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return YES;
        }
    }
    return NO;
}

@end
