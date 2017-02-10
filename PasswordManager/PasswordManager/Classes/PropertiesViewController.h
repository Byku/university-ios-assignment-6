#import <UIKit/UIKit.h>

typedef void(^PropertiesVCCallback)(void);

@interface PropertiesViewController : UIViewController

@property (nonatomic, copy) PropertiesVCCallback callback;

@end
