#import <UIKit/UIKit.h>

@class RecordViewController;

/**
 *  The protocol describing the duties the instance of @c NewRecordViewController
 *  are able to delegate.
 */
@protocol RecordViewControllerDelegate <NSObject>

/**
 *  Notifies the receiver that the sender has finished its job.
 *
 *  @param[in]  record  The record the user wants to register.
 *                      If the user has pressed 'Cancel',
 *                      the @c record is @b nil.
 */
- (void)recordViewController:(RecordViewController *)sender
         didFinishWithRecord:(NSDictionary *)record
                       index:(NSUInteger)index;

- (void)    recordViewController:(RecordViewController *)sender
didFinishWithDeleteRecordAtIndex:(NSUInteger)index;

@end

@interface RecordViewController : UIViewController

/**
 *  Returns the object that handles the delegated duties.
 */
@property (nonatomic, weak) id<RecordViewControllerDelegate> delegate;
@property (nonatomic, weak) NSDictionary *record;
@property (nonatomic) NSUInteger serviceIndex;


@end
