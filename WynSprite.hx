package wyn;

import kha.Color;
import kha.Image;
import kha.Rectangle;
import kha.Loader;
import kha.math.FastMatrix3;
import kha.math.FastVector2;
import kha.graphics2.Graphics;
import kha.graphics2.GraphicsExtension;

typedef SliceData = {
	var x:Int; // the position and size of the button image to be 9-sliced
	var y:Int;
	var width:Int;
	var height:Int;
	@:optional var borderLeft:Int; // the 9-slice offset to cut from. It's the same as how Unity's SpriteEditor does it.
	@:optional var borderTop:Int;
	@:optional var borderRight:Int;
	@:optional var borderBottom:Int;
}

typedef ImageCacheData = {
	var width:Int;
	var height:Int;
	var image:Image;
}

class WynSprite extends WynObject
{
	/**
	 * This is the base class for anything that can be rendered,
	 * such as sprites, texts, bitmaptexts, buttons, etc.
	 */

	public static var LEFT:Int 		= 1;
	public static var RIGHT:Int 	= 2;
	public static var UP:Int 		= 3;
	public static var DOWN:Int 		= 4;

	public static var SINGLE:Int 			 = 1;
	public static var SINGLE9SLICE:Int 		 = 2;
	public static var BUTTON:Int 			 = 3;
	public static var BUTTON9SLICE:Int 		 = 4;

	static var imageCache:Array<ImageCacheData>;

	public var animator:WynAnimator; // Controls all animations
	public var image:Image; // The target image to be drawn to buffer
	public var frameColumns:Int = 0; // Number of columns in spritesheet
	public var frameX:Int = 0; // Frame position, for animation purpose
	public var frameY:Int = 0;
	public var frameWidth:Int = 0; // Individual frame's size, aka the source spritesheet's size
	public var frameHeight:Int = 0;
	public var imageWidth(default, set):Int = 0; // The target size to be rendered
	public var imageHeight(default, set):Int = 0;
	public var offset:FastVector2 = new FastVector2();
	public var color:Color = Color.White; // tint, default is white
	public var alpha:Float = 1.0; // Opacity - 0.0 to 1.0
	public var scale:Float = 1.0;
	public var flipX:Bool = false;
	public var flipY:Bool = false;
	public var facing(default, set):Int;
	var _faceMap:Map<Int, {x:Bool, y:Bool}> = new Map<Int, {x:Bool, y:Bool}>();
	var _spriteType:Int;

	// NOTE:
	// "image" is used for the usual rendering
	// "originalImage" is used for storing full button spritesheet image,
	// which will be re-9-sliced everytime the width or height changes.
	var originalImage:Image;
	var sliceData:SliceData;



	public function new (x:Float=0, y:Float=0, w:Float=0, h:Float=0)
	{
		super(x, y, w, h);

		if (imageCache == null)
			imageCache = [];

		// By default
		_spriteType = WynSprite.SINGLE;

		animator = new WynAnimator(this);
	}

	override public function update (dt:Float)
	{
		super.update(dt);

		// update animation
		animator.update(dt);

		// update frame index
		updateAnimator();
	}

	override public function render (c:WynCamera)
	{
		super.render(c);

		var g = c.buffer.g2;

		// Get the position in relation to camera's scroll position
		var ox = x - c.scrollX - c.shakeX;
		var oy = y - c.scrollY - c.shakeY;

		// Rather than rendering onto the final buffer directly, we
		// render into each available camera, and offset based on the
		// camera's scrollX/scrollY. The cameras' images are then
		// rendered onto the final buffer.

		if (Wyngine.DEBUG_DRAW && Wyngine.DRAW_COUNT < Wyngine.DRAW_COUNT_MAX)
		{
			// Debug image box
			g.color = Color.Green;
			g.drawRect(ox, oy, imageWidth, imageHeight);

			Wyngine.DRAW_COUNT++;
		}

		if (image != null && visible)
		{
			g.color = color;

			// If an image is flipped, we need to offset it by width/height
			var fx = (flipX) ? -1 : 1; // flip image?
			var fy = (flipY) ? -1 : 1;
			var dx = (flipX) ? imageWidth : 0; // if image is flipped, displace
			var dy = (flipY) ? imageHeight : 0;

			// Remember: Rotations are expensive!
			if (angle != 0)
			{
				var rad = WynUtil.degToRad(angle);
				g.pushTransformation(g.transformation
					// offset toward top-left, to center image on pivot point
					.multmat(FastMatrix3.translation(ox + imageWidth/2, oy + imageHeight/2))
					// rotate at pivot point
					.multmat(FastMatrix3.rotation(rad))
					// reverse offset
					.multmat(FastMatrix3.translation(-ox - imageWidth/2, -oy - imageHeight/2)));
			}

			// Add opacity if any
			if (alpha != 1) g.pushOpacity(alpha);

			// Draw the actual image
			// NOTE: When the image is single, frameWidth/frameHeight is
			// based on each separate frame's size.
			// When the image is 9-slice, frameWidth/frameHeight is the
			// whole image's size, because we have an originalImage from
			// which to slice out the result without scaling.
			g.drawScaledSubImage(image,
				// the spritesheet's frame to extract from
				frameX, frameY, frameWidth, frameHeight, 
				// the target position
				ox + (dx+frameWidth/2) - (frameWidth/2),
				oy + (dy+frameHeight/2) - (frameHeight/2),
				imageWidth * fx * scale,
				imageHeight * fy * scale);

			// Finalise opacity
			if (alpha != 1) g.popOpacity();

			// Finalise the rotation
			if (angle != 0) g.popTransformation();
		}

		if (Wyngine.DEBUG_DRAW && Wyngine.DRAW_COUNT < Wyngine.DRAW_COUNT_MAX)
		{
			// Debug hitbox
			g.color = Color.Red;
			g.drawRect(ox + offset.x, oy + offset.y, width, height);

			Wyngine.DRAW_COUNT++;
		}
	}

	override public function destroy ()
	{
		super.destroy();
	}

	/**
	 * This flags the object for pooling.
	 */
	override public function kill ()
	{
		super.kill();

		// NOTE: we don't set these by default because
		// use cases are diverse. E.g. When a character dies,
		// he is still active and visible (updates and renders),
		// but will not do some "alive" logic.

		// active = false;
		// visible = false;
	}

	/**
	 * This flags the object for pooling.
	 */
	override public function revive ()
	{
		super.revive();

		// NOTE: Similar comments to kill() above

		// active = true;
		// visible = true;
	}

	/**
	 * When you don't need fancy quadtrees, you can
	 * use this for single checks.
	 */
	override public function collide (other:WynObject) : Bool
	{
		var hitHoriz:Bool;
		var hitVert:Bool;
		var otherx:Float;
		var othery:Float;

		if (Std.is(other, WynSprite))
		{
			var sprite = cast (other, WynSprite);
			otherx = sprite.x + sprite.offset.x;
			othery = sprite.y + sprite.offset.y;
		}
		else
		{
			otherx = other.x;
			othery = other.y;
		}

		if (x < otherx)
			hitHoriz = otherx < (x + width);
		else
			hitHoriz = x < (otherx + other.width);

		if (y < othery)
			hitVert = othery < (y + height);
		else
			hitVert = y < (othery + other.height);

		return (hitHoriz && hitVert);
	}



	/**
	 * Using Image.createRenderTarget(...) is very expensive,
	 * so we have a cache method to keep track of images which
	 * have been created before, based on width/height.
	 */ 
	function getCacheImage (w:Int, h:Int) : Image
	{
		for (i in 0 ... imageCache.length)
		{
			if (imageCache[i].width == w && imageCache[i].height == h)
				return imageCache[i].image;
		}

		return null;
	}

	function setCacheImage (w:Int, h:Int, img:Image)
	{
		// Don't add duplicates
		for (i in 0 ... imageCache.length)
		{
			if (imageCache[i].width == w && imageCache[i].height == h)
				return;
		}

		imageCache.push({
			width: w,
			height: h,
			image: img
		});
	}

	/**
	 * Only use if we're running out of memory, I guess?
	 */
	public static function clearCacheImage ()
	{
		imageCache = [];
	}

	/**
	 * Convenient method to create images if you're prototyping without images.
	 * Similar idea with HaxeFlixel, we try to cache images because doing
	 * createRenderTarget is very expensive. We only create unique images
	 * if explicitly flagged.
	 */
	public function createEmptyImage (imageW:Int=50, imageH:Int=50, isUnique:Bool=false)
	{
		// Reset the size
		width = imageW;
		height = imageH;

		// Get cached image if not flagged
		if (!isUnique)
			image = getCacheImage(imageW, imageH);

		// Create a new image
		if (image == null)
		{
			image = Image.createRenderTarget(imageW, imageH);
			setCacheImage(imageW, imageH, image);
		}

		// Set the frame size to same as image size
		frameWidth = imageW;
		frameHeight = imageH;
		imageWidth = imageW;
		imageHeight = imageH;

		// NOTE: does not adjust hitbox offset
	}

	/**
	 * Convenient method to create images if you're prototyping without images.
	 */
	public function createPlaceholderRect (color:Color, imageW:Int=50, imageH:Int=50, filled:Bool=false)
	{
		// createEmptyImage(imageW, imageH);

		// Note: creating image is expensive, so this method uses cached image.
		createEmptyImage(imageW, imageH);

		image.g2.begin(true, Color.fromValue(0x00000000));
		image.g2.color = color;
		if (filled)
			image.g2.fillRect(0, 0, imageW, imageH);
		else
			image.g2.drawRect(0, 0, imageW, imageH);
		image.g2.end();
	}

	/**
	 * Convenient method to create images if you're prototyping without images.
	 */
	public function createPlaceholderCircle (color:Color, radius:Int=25, filled:Bool=false)
	{
		createEmptyImage(radius*2, radius*2);

		image.g2.begin(true, Color.fromValue(0x00000000));
		image.g2.color = color;
		if (filled)
			GraphicsExtension.fillCircle(image.g2, radius, radius, radius);
		else
			GraphicsExtension.drawCircle(image.g2, radius, radius, radius);
		image.g2.end();
	}

	/**
	 * Load image via kha's internal image loader. Make
	 * sure you loaded the room that contains this image,
	 * in project.kha.
	 */
	public function loadImage (name:String, frameW:Int, frameH:Int)
	{
		_spriteType = SINGLE;

		// Image name is set from project.kha
		image = Loader.the.getImage(name);

		// Update variables
		frameWidth = frameW;
		frameHeight = frameH;
		frameX = 0;
		frameY = 0;
		frameColumns = Std.int(image.width / frameWidth);

		// Set the image size. Remember; the width/height is for hitbox.
		imageWidth = frameW;
		imageHeight = frameH;

		// NOTE: does not adjust hitbox offset
	}

	public function load9SliceImage (name:String, ?data:SliceData)
	{
		_spriteType = WynSprite.SINGLE9SLICE;

		// This is the original image which we'll use as a base for 9-slicing.
		originalImage = Loader.the.getImage(name);

		// Rather than create an image that fits width/height exactly,
		// We create a full-screen image as the "max size" for the 9-slice.
		// That way, we can resize via frameW/frameH without directly
		// doing a createRenderTarget each time.
		image = Image.createRenderTarget(Wyngine.G.gameWidth, Wyngine.G.gameHeight);

		if (data != null)
		{
			// Draw the slice directly onto the image, if there's
			// the slice data. Otherwise, we're gonna just draw the whole
			// original image and scale it.
			sliceData = data;

			imageWidth = cast width;
			imageHeight = cast height;

			drawSlice(originalImage, image, sliceData);
		}
		else
		{
			imageWidth = image.width;
			imageHeight = image.height;

			// If no slice data is given, then we'll scale and fit the whole
			// originalImage onto the final image.
			image.g2.begin(true, Color.fromValue(0x00000000));
			image.g2.drawScaledImage(originalImage, 0, 0, imageWidth, imageHeight);
			image.g2.end();
		}
	}

	/**
	 * Draw each section of the 9-slice based on the data
	 */
	function drawSlice (source:Image, target:Image, data:WynSprite.SliceData)
	{
		// No need to slice if data is empty
		if (data == null)
			return;

		var g:Graphics = target.g2;

		// If the total of 3-slices horizontally or vertically
		// is longer than the actual button's size, Then we'll have
		// to scale the borders so that they'll stay intact.
		var ratioW = 1.0;
		var ratioH = 1.0;
		var destW = imageWidth;
		var destH = imageHeight;

		// Get the border width and height (without the corners)
		var sx = data.x;
		var sy = data.y;
		var sw = data.width - data.borderLeft - data.borderRight;
		var sh = data.height - data.borderTop - data.borderBottom;
		var dw = destW - data.borderLeft - data.borderRight;
		var dh = destH - data.borderTop - data.borderBottom;
		// Width and height cannot be less than zero.
		if (sw < 0) sw = 0;
		if (sh < 0) sh = 0;
		if (dw < 0) dw = 0;
		if (dh < 0) dh = 0;

		// Get ratio of the border corners if the width or height
		// is zero or less. Imagine when a 9-slice image is too short,
		// we end up not seeing the side borders anymore; only the corners.
		// When that happens, we have to scale the corners by ratio.
		if (destW < data.borderLeft + data.borderRight)
			ratioW = destW / (data.borderLeft + data.borderRight);

		if (destH < data.borderTop + data.borderBottom)
			ratioH = destH / (data.borderTop + data.borderBottom);

		// begin drawing
		g.begin(true, Color.fromValue(0x00000000));

		// g.fillRect(0,0,1,1);

		// top-left border
		g.drawScaledSubImage(source,
			sx, sy, data.borderLeft, data.borderTop, // source
			0, 0, data.borderLeft*ratioW, data.borderTop*ratioH // destination
			);

		// top border
		g.drawScaledSubImage(source,
			data.borderLeft, sy, sw, data.borderTop,
			data.borderLeft*ratioW, 0, dw, data.borderTop*ratioH
			);

		// top-right border
		g.drawScaledSubImage(source,
			data.width-data.borderRight, sy, data.borderRight, data.borderTop,
			destW-data.borderRight*ratioW, 0, data.borderRight*ratioW, data.borderTop*ratioH
			);

		// middle-left border
		g.drawScaledSubImage(source,
			sx, sy+data.borderTop, data.borderLeft, sh,
			0, data.borderTop*ratioH, data.borderLeft*ratioW, dh
			);

		// middle
		g.drawScaledSubImage(source,
			data.borderLeft, sy+data.borderTop, sw, sh,
			data.borderLeft*ratioW, data.borderTop*ratioH, dw, dh
			);

		// middle-right border
		g.drawScaledSubImage(source,
			data.width-data.borderRight, sy+data.borderTop, data.borderRight, sh,
			destW-data.borderRight*ratioW, data.borderTop*ratioH, data.borderRight*ratioW, dh
			);

		// bottom-left border
		g.drawScaledSubImage(source,
			sx, sy+data.height-data.borderBottom, data.borderLeft, data.borderBottom,
			0, destH-data.borderBottom*ratioH, data.borderLeft*ratioW, data.borderBottom*ratioH
			);

		// bottom
		g.drawScaledSubImage(source,
			data.borderLeft, sy+data.height-data.borderBottom, sw, data.borderBottom,
			data.borderLeft*ratioW, destH-data.borderBottom*ratioH, dw, data.borderBottom*ratioH
			);

		// bottom-right border
		g.drawScaledSubImage(source,
			data.width-data.borderRight, sy+data.height-data.borderBottom, data.borderRight, data.borderBottom,
			destW-data.borderRight*ratioW, destH-data.borderBottom*ratioH, data.borderRight*ratioW, data.borderBottom*ratioH
			);

		g.end();
	}

	/**
	 * Not sure if this will not work on an existing image
	 * because in Khasteroids, the image width/height do not reset.
	 * NOTE: doing this does not reset the animation
	 * and frame x/y/width/height values, remember to
	 * manually update them.
	 */
	public function setImage (img:Image)
	{
		image = img;

		// NOTE: does not adjust hitbox offset
	}

	public function playAnim (name:String, reset:Bool=false)
	{
		animator.play(name, reset);

		// update the sheet
		updateAnimator();
	}

	function updateAnimator ()
	{
		if (_spriteType == WynSprite.SINGLE)
		{
			var sheetIndex:Int = animator.getSheetIndex();
			frameX = Std.int(sheetIndex % frameColumns) * frameWidth;
			frameY = Std.int(sheetIndex / frameColumns) * frameHeight;
		}
	}

	/**
	 * Maps a direction to whether the image should flip on X/Y axis.
	 * E.g.
	 * setFaceFlip(WynObject.UP, false, true); // sets to flip on Y-axis if this sprite's direction is UP
	 * setFaceFlip(WynObject.LEFT, true, false); // sets to flip on X-axis if this sprite's direction is LEFT
	 */
	public function setFaceFlip (direction:Int, flipX:Bool, flipY:Bool)
	{
		_faceMap.set(direction, {x:flipX, y:flipY});
	}

	public function setHitbox (x:Float, y:Float, w:Float, h:Float)
	{
		offset.x = x;
		offset.y = y;
		width = w;
		height = h;
	}



	/**
	 * This applies X/Y flip based on what you set from
	 * setFaceFlip() method. If map is not set, nothing happens.
	 */
	private function set_facing (direction:Int) : Int
	{
		var flip = _faceMap.get(direction);
		if (flip != null)
		{
			flipX = flip.x;
			flipY = flip.y;
		}
		
		return (facing = direction);
	}

	private function set_imageWidth (val:Int) : Int
	{
		imageWidth = val;
		if (imageWidth < 0) imageWidth = 0;

		// If this is a single image, setting width/height doesn't
		// affect the frameWidth/frameHeight.

		// Use inline function so we don't need to manually rewrite code.
		updateImageSize();

		return imageWidth;
	}

	private function set_imageHeight (val:Int) : Int
	{
		imageHeight = val;
		if (imageHeight < 0) imageHeight = 0;

		updateImageSize();

		return imageHeight;
	}

	inline function updateImageSize ()
	{
		if (_spriteType == WynSprite.SINGLE9SLICE)
		{
			// If this is a slice image, setting width/height will
			// affect both the hitbox and the frameWidth/frameHeight.
			if (sliceData != null)
			{
				frameWidth = imageWidth;
				frameHeight = imageHeight;

				if (_spriteType == WynSprite.SINGLE9SLICE)
				{
					if (imageWidth > image.width || imageHeight > image.height)
						image = Image.createRenderTarget(cast imageWidth, cast imageHeight);

					// For images, we only need to slice once
					drawSlice(originalImage, image, sliceData);
				}
			}
		}
	}
}