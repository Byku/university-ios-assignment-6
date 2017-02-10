#import "RecordViewController.h"
#import "PasswordGenerator.h"
#import "Preferences.h"
#import "Record.h"

static const NSUInteger PasswordLengthShort = 5;
static const NSUInteger PasswordLengthMedium = 10;
static const NSUInteger PasswordLengthLong = 15;

static NSString *const LowercaseLetterAlphabet = @"abcdefghijklmnopqrstuvwxyz";
static NSString *const UppercaseLetterAlphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
static NSString *const DecimalDigitAlphabet = @"1234567890";

@interface RecordViewController ()
    <UITextFieldDelegate>

@property (nonatomic) IBOutlet UITextField *serviceNameTextField;
@property (nonatomic) IBOutlet UILabel *passwordLabel;
@property (nonatomic) IBOutlet UIButton *deleteButton;

- (void)refreshPassword;
- (void)saveRecord;

- (void)didTouchCancelBarButtonItem:(UIBarButtonItem *)sender;

- (void)didTouchSaveBarButtonItem:(UIBarButtonItem *)sender;

- (IBAction)didTouchRefreshButton:(UIButton *)sender;
- (IBAction)didTouchDeleteButton:(UIButton *)sender;

@end

@implementation RecordViewController

#pragma mark - Auxiliaries

- (void)refreshPassword
{
    NSUInteger passwordLength = 0;
    NSString *alphabet = LowercaseLetterAlphabet;
    switch ([[Preferences standardPreferences] passwordStrength]) {
        case PasswordStrengthStrong: {
            passwordLength = PasswordLengthLong;
            alphabet = [alphabet stringByAppendingString:UppercaseLetterAlphabet];
            alphabet = [alphabet stringByAppendingString:DecimalDigitAlphabet];
            break;
        }
        case PasswordStrengthMedium: {
            passwordLength = PasswordLengthMedium;
            alphabet = [alphabet stringByAppendingString:UppercaseLetterAlphabet];
            break;
        }
        case PasswordStrengthWeak:
        default: {
            passwordLength = PasswordLengthShort;
            break;
        }
    }
    self.passwordLabel.text =
        [PasswordGenerator generatePasswordOfLength:passwordLength
                                      usingAlphabet:alphabet];
}

- (void)saveRecord
{
    if ([self.serviceNameTextField.text length] > 0) {
        NSDictionary *const record =
            @{kServiceName: self.serviceNameTextField.text,
              kPassword: self.passwordLabel.text};
        [self.delegate recordViewController:self didFinishWithRecord:record index:self.serviceIndex];
    }
}

#pragma mark - View's lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!!self.navigationItem) {
        self.deleteButton.hidden = !self.record;

        UIBarButtonItem *const cancelBarButtonItem =
            [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                     target:self
                                     action:@selector(didTouchCancelBarButtonItem:)];
        [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem];

        UIBarButtonItem *const saveBarButtonItem =
            [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                     target:self
                                     action:@selector(didTouchSaveBarButtonItem:)];
        [self.navigationItem setRightBarButtonItem:saveBarButtonItem];
    }

    if(!!self.record){
        self.serviceNameTextField.text = self.record[kServiceName];
        self.passwordLabel.text = self.record[kPassword];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if(!self.record){
        [self refreshPassword];
    }
}

#pragma mark - Actions

- (void)didTouchCancelBarButtonItem:(UIBarButtonItem *)sender
{
    [self.delegate recordViewController:self didFinishWithRecord:nil index:NSIntegerMax];
}

- (void)didTouchSaveBarButtonItem:(UIBarButtonItem *)sender
{
    [self saveRecord];
}

- (IBAction)didTouchRefreshButton:(UIButton *)sender
{
    [self refreshPassword];
}

- (IBAction)didTouchDeleteButton:(UIButton *)sender {
    [self.delegate recordViewController:self didFinishWithDeleteRecordAtIndex:self.serviceIndex];
}

#pragma mark - UITextFieldDelegate implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self saveRecord];
    return YES;
}

@end
