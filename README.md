# Appstore Screenshot Generator

## Generate iPhone/iPad Screenshots (w/ device frame)
 - Using the simulator, CMD+SHIFT+5 (select the option to screnshot the window)
 - Click the simulator to screenshot
 - Crop out the window bar with Gimp
 - Crop to content
 - Name each screen the same thing across platforms
 - Save in `/iphone` or `/ipad`

## Generate Android Screenshots (w/ device frame)
 - Run an emulator IN ANDROID STUDIO
 - Click the camera button to screenshot
 - A window will pop up asking if you want the device frame in the image
 - Name each screen the same thing across platforms
 - Save in `/android_phone` or `/android_tablet`

## Generating the promotional graphics
 - Modify `messagfes.json` to include a blurb for every file (all files must exist in all platforms)
 - run `php -f generate_all.php`
 - Files generate into the `/out` directory.