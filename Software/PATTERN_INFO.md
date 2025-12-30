# Pattern Info

This is a loosely structured doc covering bit's info about how images work across the system, which will hopefully help explain why things work the way they do.


The firmware supports multiple LED Pixel lengths, so to support multiple output sizes, the firmware behaves the same for all lengths, and just stops outputing after the configured pixels size. Therefore the same rules apply regardless of your configuration.

Images are limited by the following constraints.
1. The total pixel count must be below 40,000. (width * height <= 40000)
2. Height must be less than 255.

If your image height is taller than your pixel count, the firmware will only output the top pixels of your image. However it still will read the full image from the disk, and larger images take longer to upload and load when changing patterns (its barely noticiable but it is noticable).

If your image height is less than your pixel count, the firmware will tile the pattern vertically. This means if you wanted to output a single solid color on all of your leds, forever, you would only need an image that is 1x1 resolution, however....

Images with 1 width dont render properly. I should probably fix this, but until then, if you wanted to output a single solid color on all of your leds, forever, you only need an image that is 1x2 resolution.
