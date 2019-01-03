//
//  ReceiptViewController.m
//  mobileFP
//
//  Created by Ashot Navasardyan on 2017-03-23.
//  Copyright © 2017 FirstOnSite. All rights reserved.
//

#import "ReceiptViewController.h"

@interface ReceiptViewController (){
    UIDocumentPickerViewController *docPicker;
    UIImagePickerController *imgPicker;
    UIImageView *attachmentImageNew;
}

@end

@implementation ReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Pop up photo library request message.
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        //Print status message
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                NSLog(@"PHAuthorizationStatusAuthorized");
                break;
                
            case PHAuthorizationStatusDenied:
                NSLog(@"PHAuthorizationStatusDenied");
                break;
            case PHAuthorizationStatusNotDetermined:
                NSLog(@"PHAuthorizationStatusNotDetermined");
                break;
            case PHAuthorizationStatusRestricted:
                NSLog(@"PHAuthorizationStatusRestricted");
                break;
        }
        
    }];
    
    [self setTitle:@"Receipt"];
    if (_expenseId > 0) {
        [UTIL showActivity:@""];
        
        [self loadExpenseReceipt];
    }
    
    imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // webview
//    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [_expenseImage loadRequest:request];
    //_expenseImage.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadExpenseReceipt {
    [API getExpenseReceipt:USER.sessionId expenseId:_expenseId completion:^(NSMutableArray *result) {
        [UTIL hideActivity];
        
        NSString *expenseReceiptId = [result valueForKey:@"getExpenseReceiptResult"];
        if (![expenseReceiptId isEqual: @"0"]) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@", RECEIPT_URL, USER.sessionId, expenseReceiptId]];
            [self->_expenseImage loadRequest:[NSURLRequest requestWithURL:url]];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [attachmentImageNew removeFromSuperview];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// if camera is pressed then do sth
- (IBAction)cameraPressed:(id)sender {
    NSLog(@"cameraPressed");
    [self receiptShowSources];
}


- (void) receiptShowSources{
    //create alert actionsheet
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"choose_action", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionItem;
    
    // create actionItem
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"add_from_library", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        // access current status
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        if (status == kCLAuthorizationStatusNotDetermined){
            NSLog(@"will ask for authorization");
        } else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted){
            NSLog(@"not allowed");
        } else {
            NSLog(@"authorized");
            [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
            [self performSelector:@selector(hideAct) withObject:nil afterDelay:0.5f];
            [self presentViewController:self->imgPicker animated:YES completion:nil];
        }
        NSLog(@"try to access photo library");
    }];
    // add action
    [actionSheet addAction:actionItem];
    
    // create using camera action
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"add_using_camera", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self addPhoto];
    }];
    [actionSheet addAction:actionItem];
    
    // create using document action
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"documents", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self accessDocument];
    }];
    [actionSheet addAction:actionItem];
    
    
    ///
    ////******
    //////
    
    // create cancel action
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionItem setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    [actionSheet addAction:actionItem];
    
    
    // present action sheet
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

// called when using camera action
- (void) addPhoto {
    // if it does not have camera
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
    }else{
        _sourcePicker = [[UIImagePickerController alloc] init];
        _sourcePicker.delegate = self;

        [_sourcePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [_sourcePicker setAllowsEditing:YES];

        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusAuthorized) { // authorized
            [self presentViewController:_sourcePicker animated:YES completion:^ {
                NSLog(@"here");
                //[self.tabBarController.tabBar setHidden:YES];
                
            }];
        } else if (status == AVAuthorizationStatusDenied) { // denied
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"image_source_denied", [UTIL getLanguage], @"")];
        } else if (status == AVAuthorizationStatusRestricted) { // restricted
            [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"image_source_denied", [UTIL getLanguage], @"")];
        } else if (status == AVAuthorizationStatusNotDetermined) { // not determined
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) { // Access has been granted
                    [self presentViewController:self->_sourcePicker animated:YES completion:^ {
                        [self.tabBarController.tabBar setHidden:YES];
                    }];
                } else { // Access denied
                    [ALERT alertWithTitle:NSLocalizedStringFromTable(@"warning", [UTIL getLanguage], @"") message:NSLocalizedStringFromTable(@"image_source_denied", [UTIL getLanguage], @"")];
                }
            }];
        }
    }
}

// called when using document action
- (void)accessDocument{
    // these types are allowed to open
    NSArray *documentTypes = @[@"public.content", @"public.text", @"public.source-code ", @"public.image", @"public.audiovisual-content", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt"];
    docPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeImport];
    docPicker.delegate = self;
    docPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    // loading
    [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
    [self performSelector:@selector(hideAct) withObject:nil afterDelay:0.5f];
    [self presentViewController:docPicker animated:YES completion:nil];
}

// do something after picking a file
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    // ask client whether or not they want to upload files
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"are_you_sure_you_want_to_upload_this_photo", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionItem;
    // yes if they want to upload
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"yes", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if(controller.documentPickerMode == UIDocumentPickerModeImport){
            //docPicker = [UIDocumentInteractionController interactionControllerWithURL:url];
            NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
            [self.expenseImage setUserInteractionEnabled:YES];
            [self.expenseImage setDelegate:self];
            self.expenseImage.scalesPageToFit = YES;
            [self.expenseImage loadRequest:requestObj];
            [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
            [self performSelector:@selector(hideAct) withObject:nil afterDelay:0.5f];
        }
    }];
    // set text color
    [actionItem setValue:[UTIL blueColor] forKey:@"titleTextColor"];
    [actionSheet addAction:actionItem];
    
    // no if they do not want to upload
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"choose_another_one", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self accessDocument];
    }];
    //set text color
    [actionItem setValue:[UIColor grayColor] forKey:@"titleTextColor"];
    [actionSheet addAction:actionItem];
    
    // cancel buttom
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionItem setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    [actionSheet addAction:actionItem];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

// hideActivity
-(void) hideAct{
    [UTIL hideActivity];
}


- (CGSize) createNewSizeImgView:(UIImage *)image{
    CGFloat originRatio = image.size.width / image.size.height;
    CGSize tempSize = CGSizeMake(0, 0);
    
    if (originRatio > 1){
        tempSize.width = [[UIScreen mainScreen] bounds].size.width;
        tempSize.height = image.size.height * (tempSize.width / image.size.width);
        return tempSize;
    }else{
        tempSize.width = [[UIScreen mainScreen] bounds].size.width;
        tempSize.height = image.size.height * (tempSize.width / image.size.width);
        return tempSize;
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    
    // ask client whether or not they want to upload files
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"are_you_sure_you_want_to_upload_this_photo", [UTIL getLanguage], @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionItem;
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"yes", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        
        NSURL *urlPath = [info valueForKey:UIImagePickerControllerImageURL];
        // if no one pick files on local then must using camera
        if (urlPath == NULL){
            self->_expenseImage.scrollView.scrollEnabled = NO;
            // get image
            UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            //save to photo library
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            // get the new size
            CGSize tempSize = [self createNewSizeImgView:image];
            // create imageview (not a good solution, will change later)
            self->attachmentImageNew = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, tempSize.width, tempSize.height)];
            self->attachmentImageNew.image = image;
            self->attachmentImageNew.backgroundColor = [UIColor blackColor];
            self->attachmentImageNew.contentMode = UIViewContentModeScaleToFill;
            [self.view addSubview:self->attachmentImageNew];
            // dismiss webview content
            [self->_expenseImage loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
        }else{
            // someone PICK files or images
            NSLog(@"go to doc");
            // set layout of files or images
            NSString *imageHTML = [[NSString alloc] initWithFormat:@"%@%@%@", @"<!DOCTYPE html>"
                                   "<html lang=\"ja\">"
                                   "<head>"
                                   "<meta charset=\"UTF-8\">"
                                   "<style type=\"text/css\">"
                                   "html{margin:0;padding:0;}"
                                   "body {"
                                   "margin: 0;"
                                   "padding: 0;"
                                   "color: #363636;"
                                   "font-size: 90%;"
                                   "line-height: 1.6;"
                                   "background: black;"
                                   "}"
                                   "img{"
                                   "position: absolute;"
                                   "top: 0;"
                                   "bottom: 0;"
                                   "left: 0;"
                                   "right: 0;"
                                   "margin: auto;"
                                   "max-width: 100%;"
                                   "max-height: 100%;"
                                   "}"
                                   "</style>"
                                   "</head>"
                                   "<body id=\"page\">"
                                   "<img src='",urlPath,@"'/> </body></html>"];
            // load
            [self->_expenseImage loadHTMLString:imageHTML baseURL:nil];
            // loading
            [picker dismissViewControllerAnimated:YES completion:nil];
            [UTIL showActivity:NSLocalizedStringFromTable(@"loading", [UTIL getLanguage], @"")];
            [self performSelector:@selector(hideAct) withObject:nil afterDelay:0.5f];
        }
    }];
    // text color
    [actionItem setValue:[UTIL blueColor] forKey:@"titleTextColor"];
    [actionSheet addAction:actionItem];
    
    
    // no if they do not want to upload
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"choose_another_one", [UTIL getLanguage], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self presentViewController:self->imgPicker animated:YES completion:nil];
    }];
    [actionItem setValue:[UIColor grayColor] forKey:@"titleTextColor"];
    [actionSheet addAction:actionItem];
    
    actionItem = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", [UTIL getLanguage], @"") style:UIAlertActionStyleCancel handler:nil];
    [actionItem setValue:[UTIL darkRedColor] forKey:@"titleTextColor"];
    [actionSheet addAction:actionItem];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^ {
        [self.tabBarController.tabBar setHidden:NO];
    }];
}


- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error) {
        NSLog(@"fail");
    }else{
        NSLog(@"success");
    }
}




@end
