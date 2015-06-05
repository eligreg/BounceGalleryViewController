# BounceGalleryViewController
Contextually aware partitioned image gallery built on top of UIKit dynamics. Repo includes image detail controller with common U.S. and other social sharing capabilities.

Watch a video of Bounce Gallery in action:

[![YouTube](http://img.youtube.com/vi/X_BdpiEjO2I/0.jpg)](http://www.youtube.com/watch?v=X_BdpiEjO2I)

## Usage
BounceGalleryViewController is a UICollectionView subclass (and view controller). It uses ALAsset(s) found using your device's AssetLibrary. 

*A pre-requisite for use is to have access to the device's Assets Library.*

Usage is simple:

_bounce = [[BounceGalleryViewController alloc] initWithCollectionViewLayout: [[BounceGalleryFlowLayout alloc] init] andAssets:@[/* NSArray of ALAsset objects */];

if (_bounce) [self presentViewController:_bounce animated:TRUE completion:nil];

That's it, and this includes a fully fleshed out sharing capabilities.
