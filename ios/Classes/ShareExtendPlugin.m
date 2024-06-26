#import "ShareExtendPlugin.h"

@implementation ShareExtendPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* shareChannel = [FlutterMethodChannel
                                          methodChannelWithName:@"com.zt.shareextend/share_extend"
                                          binaryMessenger:[registrar messenger]];
    
    [shareChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        if ([@"share" isEqualToString:call.method]) {
            NSDictionary *arguments = [call arguments];
            NSArray *array = arguments[@"list"];
            NSString *shareType = arguments[@"type"];
            NSString *subject = arguments[@"subject"];
            
            if (array.count == 0) {
                result(
                       [FlutterError errorWithCode:@"error" message:@"Non-empty list expected" details:nil]);
                return;
            }
            
            NSNumber *originX = arguments[@"originX"];
            NSNumber *originY = arguments[@"originY"];
            NSNumber *originWidth = arguments[@"originWidth"];
            NSNumber *originHeight = arguments[@"originHeight"];
            
            CGRect originRect = CGRectZero;
            if (originX != nil && originY != nil && originWidth != nil && originHeight != nil) {
                originRect = CGRectMake([originX doubleValue], [originY doubleValue],
                                        [originWidth doubleValue], [originHeight doubleValue]);
            }
        
            if ([shareType isEqualToString:@"text"]) {
                [self share:array atSource:originRect withSubject:subject];
                result(nil);
            }  else if ([shareType isEqualToString:@"image"]) {
                NSMutableArray * imageArray = [[NSMutableArray alloc] init];
                for (NSString * path in array) {
                    UIImage *image = [UIImage imageWithContentsOfFile:path];
                    [imageArray addObject:image];
                }
                [self share:imageArray atSource:originRect withSubject:subject];
            }else if ([shareType isEqualToString:@"textAndUrl"]) {
                NSMutableArray * textAndUrlArray = [[NSMutableArray alloc] init];
                for (NSString * path in array) {
                    NSURL *url = [NSURL URLWithString:path];
                    [textAndUrlArray addObject:url];
                }
                [textAndUrlArray insertObject:subject atIndex:0];
                [self share:textAndUrlArray atSource:originRect withSubject:subject];
            } else if ([shareType isEqualToString:@"imageAndUrl"]) {
                NSMutableArray * imageAndUrlArray = [[NSMutableArray alloc] init];
                NSString *texts = array.firstObject;
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",texts]];
                NSData  *data1 = UIImagePNGRepresentation([self imageWithImageSimple:[[UIImage alloc]initWithData:[[NSData alloc] initWithContentsOfURL:url]] scaledToSize:CGSizeMake(150, 150)]);
                [imageAndUrlArray addObject:data1];
                [imageAndUrlArray insertObject:subject atIndex:0];
                [self share:imageAndUrlArray atSource:originRect withSubject:subject];
            } else if ([shareType isEqualToString:@"textAndUrl2"]) {
                NSMutableArray * imageAndUrlArray = [[NSMutableArray alloc] init];
                NSString *texts = array.firstObject;
                [imageAndUrlArray insertObject:subject atIndex:0];
                [self share:imageAndUrlArray atSource:originRect withSubject:subject];
            } else {
                NSMutableArray * urlArray = [[NSMutableArray alloc] init];
                for (NSString * path in array) {
                    NSURL *url = [NSURL fileURLWithPath:path];
                    [urlArray addObject:url];
                }
                [self share:urlArray atSource:originRect withSubject:subject];
                result(nil);
            }
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
}

+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}

+ (void)share:(NSArray *)sharedItems atSource:(CGRect)origin withSubject:(NSString *) subject {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:sharedItems applicationActivities:nil];
    
    UIViewController *controller =[UIApplication sharedApplication].keyWindow.rootViewController;
    activityViewController.popoverPresentationController.sourceView = controller.view;

    if (CGRectIsEmpty(origin)) {
        origin = CGRectMake(0, 0, controller.view.bounds.size.width, controller.view.bounds.size.width /2);
    }
    activityViewController.popoverPresentationController.sourceRect = origin;

    [activityViewController setValue:subject forKey:@"subject"];

    [controller presentViewController:activityViewController animated:YES completion:nil];
}

@end
