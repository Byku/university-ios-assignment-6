#import "RecordViewController.h"
#import "Record.h"
#import "RecordsManager.h"
#import "RecordsViewController.h"
#import "PropertiesViewController.h"
#import "Preferences.h"

static NSString *const DefaultFileNameForLocalStore = @"AwesomeFileName.dat";

@interface RecordsViewController ()
    <UITableViewDataSource,
     UITableViewDelegate,
     RecordViewControllerDelegate>

@property (nonatomic, readonly) RecordsManager *recordsManager;

@property (nonatomic) IBOutlet UITableView *tableView;

- (IBAction)didTouchAddBarButtonItem;
- (IBAction)didTouchPropertiesBarButtonItem;
@end

@implementation RecordsViewController

@synthesize recordsManager = recordsManager_;
//
//@synthesize tableView = tableView_;

#pragma mark - Getters

- (RecordsManager *)recordsManager
{
    if (!recordsManager_) {
        NSURL *const documentDirectoryURL =
            [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                    inDomains:NSUserDomainMask] lastObject];
        NSURL *const fileURLForLocalStore =
            [documentDirectoryURL URLByAppendingPathComponent:DefaultFileNameForLocalStore];

        recordsManager_ = [[RecordsManager alloc] initWithURL:fileURLForLocalStore];
    }

    return recordsManager_;
}

#pragma mark - Actions

- (IBAction)didTouchAddBarButtonItem
{
    [self showRecordVCWithRecord:nil index:NSIntegerMax];
}

- (IBAction)didTouchPropertiesBarButtonItem
{
    PropertiesViewController *rootViewController = [PropertiesViewController new];
    NSInteger oldStorageType = [[Preferences standardPreferences] storageType];

    rootViewController.callback = ^(){
        [self dismissViewControllerAnimated:YES completion:NULL];
        if (oldStorageType != [[Preferences standardPreferences] storageType]){
            [self.recordsManager synchronize];
            [self.recordsManager eraseStorage:oldStorageType];
        }
    };

    UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:rootViewController];
    navigationController.title = @"Properties";
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.recordsManager records] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#define REUSABLE_CELL_ID @"ReusableCellID"

    UITableViewCell *tableViewCell =
        [tableView dequeueReusableCellWithIdentifier:REUSABLE_CELL_ID];
    if (!tableViewCell) {
        tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                               reuseIdentifier:REUSABLE_CELL_ID];
    }
    NSDictionary *const record = [[self.recordsManager records] objectAtIndex:indexPath.row];
    tableViewCell.textLabel.text = [record valueForKey:kServiceName];
    tableViewCell.detailTextLabel.text = [record valueForKey:kPassword];

    return tableViewCell;

#undef REUSABLE_CELL_ID
}

#pragma mark - UITableViewDelegate implementation

-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *currentRecord = [self.recordsManager records][indexPath.row];
    [self showRecordVCWithRecord:currentRecord index:indexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *editButton =
            [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                               title:@"Edit"
                                             handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                                                 [self editCellAtIndex:(NSUInteger)indexPath.row];
                                             }];
    editButton.backgroundColor = [UIColor lightGrayColor];

    UITableViewRowAction *deleteButton =
            [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                               title:@"Delete"
                                             handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                                                 [self deleteCellAtIndex:(NSUInteger) indexPath.row];
                                             }];
    deleteButton.backgroundColor = [UIColor redColor];

    return @[deleteButton, editButton];
}

#pragma mark - Auxiliary functions

- (void)deleteCellAtIndex: (NSUInteger)index
{
    [self.recordsManager deleteRecordAtIndex:index];
    [self.recordsManager synchronize];
    [self.tableView reloadData];
}

- (void) editCellAtIndex: (NSUInteger)index
{
    NSDictionary *currentRecord = [self.recordsManager records][index];
    [self showRecordVCWithRecord:currentRecord index:index];
}

- (void)showRecordVCWithRecord:(NSDictionary *)record
                         index:(NSUInteger)index
{
    RecordViewController *const rootViewController = [[RecordViewController alloc] init];
    rootViewController.delegate = self;

    UINavigationController *const navigationController =
            [[UINavigationController alloc] initWithRootViewController:rootViewController];
    rootViewController.record = record;
    rootViewController.serviceIndex = index;
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - NewRecordViewControllerDelegate implementation

- (void)recordViewController:(RecordViewController *)sender
         didFinishWithRecord:(NSDictionary *)record
                       index:(NSUInteger)index
{
    if (record) {
        [self.recordsManager registerRecord:record atIndex:index];
        [self.recordsManager synchronize];
        [self.tableView reloadData];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)    recordViewController:(RecordViewController *)sender
didFinishWithDeleteRecordAtIndex:(NSUInteger)index
{
    [self.recordsManager deleteRecordAtIndex:index];
    [self.recordsManager synchronize];
    [self.tableView reloadData];

    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
