//
//  PhotographersTableViewController.m
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "PhotographersTableViewController.h"
#import "FlickrFetcher.h"
#import "Photographer.h"
#import "Photo+Flickr.h"
#import "ImageViewController.h"
#import "AFNetworking.h"

@interface PhotographersTableViewController ()
@property (nonatomic, weak) UIImage *myImage;
@end

@implementation PhotographersTableViewController

@synthesize photoDatabase = _photoDatabase;
@synthesize imagePicker = _imagePicker;
@synthesize myImage = _myImage;

- (IBAction)takePhoto:(UIBarButtonItem *)sender {
    //    NSLog(@"I am taking a photo,fuck off");
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"打开图片" delegate:self cancelButtonTitle:@"关闭" destructiveButtonTitle:nil otherButtonTitles:@"相册",@"照相机", nil];//关闭按钮在最后
    
    sheet.delegate = self;
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;//样式
    [sheet showInView:self.view];//显示样式
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        //        NSString *string = [[NSBundle mainBundle] pathForResource:@"1110" ofType:@"JPEG"];
        //        currentImage = [UIImage imageWithContentsOfFile:string];
        //        rootImageView.image = currentImage;
        //        seg.userInteractionEnabled = YES;
        //        [self.view addSubview:rootImageView];
        
        self.imagePicker = [[UIImagePickerController alloc] init];//图像选取器
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//打开相册
        self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//过渡类型,有四种
        //        imagePicker.allowsEditing = NO;//禁止对图片进行编辑
        
        [self presentModalViewController:self.imagePicker animated:YES];//打开模态视图控制器选择图像
        
    }
    if(buttonIndex == 1)
    {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            self.imagePicker = [[UIImagePickerController alloc] init];
            self.imagePicker.delegate = self;
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;//照片来源为相机
            self.imagePicker.allowsEditing = YES;
            self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            
            [self presentModalViewController:self.imagePicker animated:YES];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该设备没有照相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *myImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    imageView.image = myImage;
    self.myImage = myImage;
    [self.view addSubview:imageView];
    
    [self dismissModalViewControllerAnimated:YES];
    [self uploadImage];
}

- (void)uploadImage {
//    NSString *urlstring=@"http://lingwu.herokuapp.com/upload_wanke";
//    
//    NSString *boundary = @"----WebKitFormBoundaryvzRIBTTrYiG79Y8f";
//    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary, nil];
//    
//    NSURL *url=[NSURL URLWithString:urlstring];
//    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
//    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPMethod:@"POST"];
//    NSMutableData *body = [NSMutableData data];
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"ios.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[NSData dataWithData:UIImageJPEGRepresentation(self.myImage, 90)]];
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//
//    // set body with request.
//    [request setHTTPBody:body];
//    [request addValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
//    
//    NSOperationQueue *queue=[[NSOperationQueue alloc] init];
//    [NSURLConnection sendAsynchronousRequest:request queue:queue
//                           completionHandler:^(NSURLResponse *respone,
//                                               NSData *data,
//                                               NSError *error)
//     {
//         if ([data length]>0 && error==nil) {
//             NSString *jsonstring=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//             NSLog(@"data:%@",jsonstring);
//         }
//     }
//     ];
    
//    using AFN
    NSURL *url = [NSURL URLWithString:@"http://lingwu.etao.com:5000"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSData *imageData = UIImageJPEGRepresentation(self.myImage, 0.5);
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/upload_wanke" parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:@"ios.jpg" mimeType:@"image/jpeg"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
//    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSDictionary *dico = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        
        NSLog(@"%@", [dico valueForKey:@"specie"]);
        NSLog(@"%@", dico);
        
    }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"something nasty happened: %@", error);
    }];
    [httpClient enqueueHTTPRequestOperation:operation];
}

// 4. Stub this out (we didn't implement it at first)
// 13. Create an NSFetchRequest to get all Photographers and hook it up to our table via an NSFetchedResultsController
// (we inherited the code to integrate with NSFRC from CoreDataTableViewController)

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    // no predicate because we want ALL the Photographers
                             
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.photoDatabase.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

// 5. Create a Q to fetch Flickr photo information to seed the database
// 6. Take a timeout from this and go create the database model (Photomania.xcdatamodeld)
// 7. Create custom subclasses for Photo and Photographer
// 8. Create a category on Photo (Photo+Flickr) to add a "factory" method to create a Photo
// (go to Photo+Flickr for next step)
// 12. Use the Photo+Flickr category method to add Photos to the database (table will auto update due to NSFRC)

- (void)fetchFlickrDataIntoDocument:(UIManagedDocument *)document
{
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSArray *photos = [FlickrFetcher recentGeoreferencedPhotos];
        [document.managedObjectContext performBlock:^{ // perform in the NSMOC's safe thread (main thread)
            for (NSDictionary *flickrInfo in photos) {
                [Photo photoWithFlickrInfo:flickrInfo inManagedObjectContext:document.managedObjectContext];
                // table will automatically update due to NSFetchedResultsController's observing of the NSMOC
            }
            // should probably saveToURL:forSaveOperation:(UIDocumentSaveForOverwriting)completionHandler: here!
            // we could decide to rely on UIManagedDocument's autosaving, but explicit saving would be better
            // because if we quit the app before autosave happens, then it'll come up blank next time we run
            // this is what it would look like (ADDED AFTER LECTURE) ...
            [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
            // note that we don't do anything in the completion handler this time
        }];
    });
    dispatch_release(fetchQ);
}

// 3. Open or create the document here and call setupFetchedResultsController

- (void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.photoDatabase.fileURL path]]) {
        // does not exist on disk, so create it
        [self.photoDatabase saveToURL:self.photoDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
            [self fetchFlickrDataIntoDocument:self.photoDatabase];
            
        }];
    } else if (self.photoDatabase.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.photoDatabase openWithCompletionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
        }];
    } else if (self.photoDatabase.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        [self setupFetchedResultsController];
    }
}

// 2. Make the photoDatabase's setter start using it

- (void)setPhotoDatabase:(UIManagedDocument *)photoDatabase
{
    if (_photoDatabase != photoDatabase) {
        _photoDatabase = photoDatabase;
        [self useDocument];
    }
}

// 0. Create full storyboard and drag in CDTVC.[mh], FlickrFetcher.[mh] and ImageViewController.[mh]
// (0.5 would probably be "add a UIManagedDocument, photoDatabase, as this Controller's Model)
// 1. Add code to viewWillAppear: to create a default document (for demo purposes)

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.photoDatabase) {  // for demo purposes, we'll create a default database if none is set
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Default Photo Database"];
        // url is now "<Documents Directory>/Default Photo Database"
        self.photoDatabase = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
    }
}

// 14. Load up our cell using the NSManagedObject retrieved using NSFRC's objectAtIndexPath:
// (go to PhotosByPhotographerViewController.h (header file) for next step)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photographer Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // ask NSFetchedResultsController for the NSMO at the row in question
    Photographer *photographer = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // Then configure the cell using it ...
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:200];
    [titleLabel setText:photographer.name];

    UILabel *detailLabel = (UILabel *)[cell viewWithTag:300];
    [detailLabel setText:[NSString stringWithFormat:@"%d photos", [photographer.photos count]]];
    
    UIImageView *thumbnailView = (UIImageView *)[cell viewWithTag:100];
    UIImage *thumbnail = [ [ UIImage alloc]initWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://img3.douban.com/mpic/s3778935.jpg"]] ]; 
    [thumbnailView setFrame:CGRectMake(0, 0, thumbnail.size.width, thumbnail.size.height)];
    thumbnailView.image = thumbnail;
//    cell.textLabel.text = photographer.name;
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", [photographer.photos count]];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 125;
}

// 19. Support segueing from this table to any view controller that has a photographer @property.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
//    Photographer *photographer = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // be somewhat generic here (slightly advanced usage)
    // we'll segue to ANY view controller that has a photographer @property
//    if ([segue.destinationViewController respondsToSelector:@selector(setPhotographer:)]) {
//        // use performSelector:withObject: to send without compiler checking
//        // (which is acceptable here because we used introspection to be sure this is okay)
//        [segue.destinationViewController performSelector:@selector(setPhotographer:) withObject:photographer];
//    }
    if ([segue.identifier isEqualToString:@"Show Photo"]) {
        [segue.destinationViewController setImageURL:[NSURL URLWithString:@"http://img.xiami.com/images/artist/11969076104205_2.jpg"]];
        [segue.destinationViewController setTitle:@"巴奈"];
        [segue.destinationViewController setContentString:@"Panai（巴奈），在阿美族语中代表“稻穗”，汉名柯美黛。父亲卑南族、母亲阿美族。阿美族的神话故事里,巴奈是一个非常美丽却红颜薄命的女子 ,以她为主人公的传说正如能倾国倾城引发十年大战的海伦. 台湾著名音乐制作人郑捷任让编曲和录音烘托巴奈的作品，民谣的基调下，又赋予每首完整的音乐风景，有时像是场电影，有时让Pub Live的气氛忠实呈现。不追求音效的甜美，而忠于歌的精神"];
    }
}

@end
