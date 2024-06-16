
# Known Issues

## Missing Artist Images After Import

The backup and export feature only exports the database, not the artist images. These images are stored in the cache, and when the app is reinstalled, the cache is lost. 

To fix this, you can skip through your entire music library and then import the database again. This way, you'll have the correct data without the skip count increasing dramatically.

I could save the artist images in the database, but this might increase lookup times. Another solution could be to add an option to export the cached images and reimport them as well.
