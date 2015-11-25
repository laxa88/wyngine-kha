package wyn;

import kha.Image;

typedef ImageCacheData = {
	var width:Int;
	var height:Int;
	var image:Image;
	var type:Int;
}

class WynCache
{
	// This class handles cached stuff exclusively so it
	// can be accessed from anywhere that requires it, e.g. image caches.

	public static inline var CACHE_RECT 	= 1;
	public static inline var CACHE_CIRCLE 	= 2;
	static var imageCache:Array<ImageCacheData>;

	public static function init ()
	{
		imageCache = [];
	}

	/**
	 * Using Image.createRenderTarget(...) is very expensive,
	 * so we have a cache method to keep track of images which
	 * have been created before, based on width/height.
	 */ 
	public static function getCacheImage (w:Int, h:Int, t:Int) : Image
	{
		for (i in 0 ... imageCache.length)
		{
			if (imageCache[i].width == w &&
				imageCache[i].height == h &&
				imageCache[i].type == t)
				return imageCache[i].image;
		}

		// If cache not found, create a new one
		var image = Image.createRenderTarget(w, h);
		setCacheImage(w, h, image, t);

		return image;
	}

	public static function setCacheImage (w:Int, h:Int, img:Image, t:Int)
	{
		// Don't add duplicates
		for (i in 0 ... imageCache.length)
		{
			if (imageCache[i].width == w &&
				imageCache[i].height == h &&
				imageCache[i].type == t)
				return;
		}

		imageCache.push({
			width: w,
			height: h,
			image: img,
			type: t
		});
	}

	/**
	 * Only use if we're running out of memory, I guess?
	 */
	public static function clearCacheImage ()
	{
		imageCache = [];
	}
}