# Lee's Image processor (LImg)

## limg.rb [OPTIONS]

This tool takes an image or a list of images and chops them up into the various sizes we use for the website. The name is short for "Lee's IMaGes". You can call the tool with default settings by typing limg.rb. You can access help by typing limg.rb -h


### default
Will take all image files in .../Downloads/WebAssets, resize them so they're square with a white background, chop them up into the default sizes (see below), and save them to R:/RETAIL/IMAGES/4Web.

##### ```-f     t,sw,med,lg```
  Given a comma-separated list of sizes, will let you select which sizes to chop images into.
- t = 100x100
- sw = 350x350 (you'll have to chop this to 25x25 manually)
- med = 350x350
- lg = 1050x1050

##### ```-e```
  Also parses images into med and t versions and saves them to RPro's root image directory: R:/RETAIL/RPRO/Images/Inven

##### ```--source SOURCE```
  Lets you define a single image or a directory of images to chop up. Use absolute paths.

##### ```--dest DEST```
  Lets you define a directory to save chopped up images to. Use absolute paths.


### Example
```limg.rb -e -f sw,med,lg --source "c:/Documents and Settings/pos/image.jpg" --dest "c:/Documents and Settings/pos"```

This code will take a single image image.jpg, chop it into sw, med, and lg versions and save them to c:/Documents and Settings/pos. The -e flag means it will also chop the image into t and med versions and save them to ECI's image directory.


### NOTES:

Image files should be named with their SID followed by the full name of their Attr if it exists and separated by underscores. See instructions on image naming elsewhere on this site for more information. (TODO: Write instructions on image naming.)

