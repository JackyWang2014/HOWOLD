//
//  ViewController.m
//  HOWOLD
//
//  Created by WangQitai on 15/11/20.
//  Copyright (c) 2015年 WangQitai. All rights reserved.
//

#import "ViewController.h"
#import "DBCameraViewController.h"
#import "DBCameraLibraryViewController.h"
#import "CustomCamera.h"
#import "DemoNavigationController.h"
#import "DBCameraContainerViewController.h"

@interface DetailViewController : UIViewController {
    UIImageView *_imageView;
}
@property (nonatomic, strong) UIImage *detailImage;
@end

@implementation DetailViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
#endif
    
    [self.navigationItem setTitle:@"Detail"];
    
    _imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:_imageView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_imageView setImage:_detailImage];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _detailImage = nil;
    [_imageView setImage:nil];
}

@end

#define kCELLIDENTIFIER @"CellIdentifier"
#define kCAMERATITLES @[@"Open Custom Camera",@"Open Photo Library"]
typedef void (^TableRowBlock)();
@interface ViewController () <DBCameraViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>{
    UITableView * _tableView;
    NSDictionary * _actionDic;
}

@end

@implementation ViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _actionDic = @{@0:^{[self openCustomCamera];},@1:^{[self openLibrary];}};
    }
    return self;
}

- (void)openCamera {
    /*
     //If you want to customize the camera view, use initWithDelegate:cameraSettingsBlock:
     
     DBCameraContainerViewController *cameraContainer = [[DBCameraContainerViewController alloc] initWithDelegate:self cameraSettingsBlock:^(DBCameraView *cameraView, DBCameraContainerViewController *container) {
     [cameraView.photoLibraryButton setHidden:YES]; //Hide Library button
     
     //Override the camera grid
     DBCameraGridView *cameraGridView = [[DBCameraGridView alloc] initWithFrame:cameraView.previewLayer.frame];
     [cameraGridView setNumberOfColumns:4];
     [cameraGridView setNumberOfRows:4];
     [cameraGridView setAlpha:0];
     [container.cameraViewController setCameraGridView:cameraGridView];
     [container.cameraViewController setUseCameraSegue:NO];
     }];
     
     //Set the Tint Color and the Selected Color
     [cameraContainer setTintColor:[UIColor redColor]];
     [cameraContainer setSelectedTintColor:[UIColor yellowColor]];
     */
    
    DBCameraContainerViewController *cameraContainer = [[DBCameraContainerViewController alloc] initWithDelegate:self];
    [cameraContainer setFullScreenMode];
    
    DemoNavigationController *nav = [[DemoNavigationController alloc] initWithRootViewController:cameraContainer];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)openCustomCamera {
    NSLog(@"open custom");
    CustomCamera * camera = [[CustomCamera alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [camera buildInterface];
    
    DemoNavigationController * nav = [[DemoNavigationController alloc] initWithRootViewController:[[DBCameraViewController alloc] initWithDelegate:self cameraView:camera]];
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (void)openLibrary {
    NSLog(@"open library");
    DBCameraLibraryViewController *vc = [[DBCameraLibraryViewController alloc] init];
    [vc setDelegate:self]; //DBCameraLibraryViewController must have a DBCameraViewControllerDelegate object
    //    [vc setForceQuadCrop:YES]; //Optional
    //    [vc setUseCameraSegue:YES]; //Optional
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kCAMERATITLES.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TableRowBlock block = _actionDic[@(indexPath.row)];
    block();
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCELLIDENTIFIER];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCELLIDENTIFIER];
        
    }
    cell.textLabel.text = kCAMERATITLES[indexPath.row];
    return cell;
}

- (IBAction)photoLibraryClick:(id)sender {
    
    
}
- (IBAction)takingPhotoClick:(id)sender {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:_tableView];
    
    
    
}

#pragma mark - DBCameraViewControllerDelegate

- (void) dismissCamera:(id)cameraViewController{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [cameraViewController restoreFullScreenMode];
}

- (void) camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
    DetailViewController *detail = [[DetailViewController alloc] init];
    [detail setDetailImage:image];
    [self.navigationController pushViewController:detail animated:NO];
    [cameraViewController restoreFullScreenMode];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
