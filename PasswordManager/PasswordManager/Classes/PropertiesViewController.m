#import "PropertiesViewController.h"
#import "Preferences.h"

@interface PropertiesViewController ()
    <UITableViewDataSource,
    UITableViewDelegate>

@property (nonatomic) IBOutlet UITableView *propertiesTableView;
@property (nonatomic) NSDictionary *tableSections;
@property (nonatomic) NSArray *propertySectionsTitles;


@end

@implementation PropertiesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *const backBarButtonItem =
            [[UIBarButtonItem alloc]
                    initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                         target:self
                                         action:@selector(didTouchBackBarButtonItem)];
    [self.navigationItem setLeftBarButtonItem:backBarButtonItem];

    self.tableSections = @{
            @"Difficulty of password": @[@"Weak", @"Medium", @"Strong"],
            @"Type of password storage": @[@"UserDefaults", @"File on Device"]
    };
    self.propertySectionsTitles = [self.tableSections allKeys];
  }

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableSections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.propertySectionsTitles[(NSUInteger)section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableSections[self.propertySectionsTitles[(NSUInteger) section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];

    NSString *sectionName = self.propertySectionsTitles[(NSUInteger)indexPath.section];
    NSString *cellTitle = self.tableSections[sectionName][(NSUInteger)indexPath.row];
    cell.textLabel.text = cellTitle;
    
    if ([[Preferences standardPreferences] storageType] == indexPath.row && indexPath.section == 1) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    NSInteger passStrength = [[Preferences standardPreferences] passwordStrength];
    NSIndexPath *ip;
    switch (passStrength)
    {
        case PasswordStrengthWeak:
        {
            ip = [NSIndexPath indexPathForRow:0 inSection:0];
        }
            break;
        case PasswordStrengthMedium:
        {
            ip = [NSIndexPath indexPathForRow:1 inSection:0];
        }
            break;
        case PasswordStrengthStrong:
        {
            ip = [NSIndexPath indexPathForRow:2 inSection:0];
        }
    }

    if (ip == indexPath){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        return;
    }

    for (UITableViewCell *cell in tableView.visibleCells) {
        if ([[tableView indexPathForCell:cell] section] == [indexPath section]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;

    if (indexPath.section == 0) {
        NSInteger passStrength = PasswordStrengthDefault;
        switch (indexPath.row) {
            case 0: {
                passStrength = PasswordStrengthWeak;
            }
                break;
            case 1: {
                passStrength = PasswordStrengthMedium;
            }
                break;
            case 2: {
                passStrength = PasswordStrengthStrong;
            }
        }
        [[Preferences standardPreferences] setPasswordStrength:passStrength];
    } else if (indexPath.section == 1) {
        NSInteger storType = StorageTypeDefault;
        switch (indexPath.row) {
            case 0: {
                storType = StorageTypeUserDefaults;
            }
                break;
            case 1: {
                storType = StorageTypeFilesOnDevice;
            }
        }
        [[Preferences standardPreferences] setStorageType:storType];
    }
}

#pragma mark - Actions
- (void)didTouchBackBarButtonItem
{
    if(self.callback != nil){
        self.callback();
    }
}
@end
