# NLCustomCamera

[![CI Status](https://img.shields.io/travis/wz_yinglong/NLCustomCamera.svg?style=flat)](https://travis-ci.org/wz_yinglong/NLCustomCamera)
[![Version](https://img.shields.io/cocoapods/v/NLCustomCamera.svg?style=flat)](https://cocoapods.org/pods/NLCustomCamera)
[![License](https://img.shields.io/cocoapods/l/NLCustomCamera.svg?style=flat)](https://cocoapods.org/pods/NLCustomCamera)
[![Platform](https://img.shields.io/cocoapods/p/NLCustomCamera.svg?style=flat)](https://cocoapods.org/pods/NLCustomCamera)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
```
NLRecordParam *param = [NLRecordParam recordConfigWithVideoRatio:NLShootRatioFullScreen shootMode:photoVideoMode position:AVCaptureDevicePositionBack maxRecordTime:15.0f minRecordTime:1.0f isCompression:NO waterMark:nil isFilter:YES isShowBeautyBtn:NO isShowAlbumBtn:YES currentVC:self];
[NLRecordManager shareManager].recordParam = param;
NLPhotoViewController *page = [NLPhotoViewController new];
[self presentViewController:page animated:YES completion:nil];
```

## Fix GPUImage
###Fix Xcode main thread warning  https://github.com/BradLarson/GPUImage/pull/2533/files
```
- (void)recalculateViewGeometry;
{
    
    __block CGRect currentBounds;
    
    runOnMainQueueWithoutDeadlocking(^{
        currentBounds = self.bounds;
    });
    
    runSynchronouslyOnVideoProcessingQueue(^{
        CGFloat heightScaling, widthScaling;
        
//        CGSize currentViewSize = self.bounds.size;
        
        //    CGFloat imageAspectRatio = inputImageSize.width / inputImageSize.height;
        //    CGFloat viewAspectRatio = currentViewSize.width / currentViewSize.height;
        
        CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(inputImageSize, currentBounds);
        
        switch(_fillMode)
        {
            case kGPUImageFillModeStretch:
            {
                widthScaling = 1.0;
                heightScaling = 1.0;
            }; break;
            case kGPUImageFillModePreserveAspectRatio:
            {
                widthScaling = insetRect.size.width / currentBounds.size.width;
                heightScaling = insetRect.size.height / currentBounds.size.height;
            }; break;
            case kGPUImageFillModePreserveAspectRatioAndFill:
            {
                //            CGFloat widthHolder = insetRect.size.width / currentViewSize.width;
                widthScaling = currentBounds.size.height / insetRect.size.height;
                heightScaling = currentBounds.size.width / insetRect.size.width;
            }; break;
        }
        
        imageVertices[0] = -widthScaling;
        imageVertices[1] = -heightScaling;
        imageVertices[2] = widthScaling;
        imageVertices[3] = -heightScaling;
        imageVertices[4] = -widthScaling;
        imageVertices[5] = heightScaling;
        imageVertices[6] = widthScaling;
        imageVertices[7] = heightScaling;
    });
    
//    static const GLfloat imageVertices[] = {
//        -1.0f, -1.0f,
//        1.0f, -1.0f,
//        -1.0f,  1.0f,
//        1.0f,  1.0f,
//    };
}

```

## Installation

NLCustomCamera is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'NLCustomCamera'
```

## Author

wzyinglong, wz_yinglong@163.com

## License

NLCustomCamera is available under the MIT license. See the LICENSE file for more info.
