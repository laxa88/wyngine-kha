package wyn;

import kha.Color;
import kha.Image;
import kha.Rectangle;
import kha.Loader;
import kha.math.FastMatrix3;
import kha.math.FastVector2;
import kha.graphics2.Graphics;
import kha.graphics2.GraphicsExtension;

class WynSprite extends WynObject
{
	/**
	 * This is the base class for anything that can be rendered,
	 * such as sprites, texts, bitmaptexts, buttons, etc.
	 */

	public static var LEFT:Int 		= 0;
	public static var RIGHT:Int 	= 1;
	public static var UP:Int 		= 2;
	public static var DOWN:Int 		= 3;

	public var animator:WynAnimator; // Controls all animations
	public var image:Image;
	public var frameColumns:Int = 0; // Number of columns in spritesheet
	public var frameX:Int = 0; // Frame position, for animation purpose
	public var frameY:Int = 0;
	public var frameWidth:Int = 0; // Individual frame's size
	public var frameHeight:Int = 0;
	public var offset:FastVector2 = new FastVector2();
	public var color:Color = Color.White; // tint, default is white
	public var alpha:Float = 1.0; // Opacity - 0.0 to 1.0
	public var scale:Float = 1.0;
	public var flipX:Bool = false;
	public var flipY:Bool = false;
	public var facing(default, set):Int;
	var _faceMap:Map<Int, {x:Bool, y:Bool}> = new Map<Int, {x:Bool, y:Bool}>();



	public function new (?x:Float=0, ?y:Float=0, ?w:Float=0, ?h:Float=0)
	{
		super(x, y, w, h);

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

	override public function render (g:Graphics)
	{
		super.render(g);

		if (Wyngine.DEBUG_DRAW && Wyngine.DRAW_COUNT < Wyngine.DRAW_COUNT_MAX)
		{
			g.color = Color.Green;
			g.drawRect(x, y, frameWidth, frameHeight);

			Wyngine.DRAW_COUNT++;
		}

		if (image != null && visible)
		{
			g.color = color;

			// If an image is flipped, we need to offset it by width/height
			var fx = (flipX) ? -1 : 1; // flip image?
			var fy = (flipY) ? -1 : 1;
			var dx = (flipX) ? frameWidth : 0; // if image is flipped, displace
			var dy = (flipY) ? frameHeight : 0;

			// Remember: Rotations are expensive!
			if (angle != 0)
			{
				var rad = WynUtil.degToRad(angle);
				g.pushTransformation(g.transformation
					// offset toward top-left, to center image on pivot point
					.multmat(FastMatrix3.translation(x + frameWidth/2, y + frameHeight/2))
					// rotate at pivot point
					.multmat(FastMatrix3.rotation(rad))
					// reverse offset
					.multmat(FastMatrix3.translation(-x - frameWidth/2, -y - frameHeight/2)));
			}

			// Add opacity if any
			if (alpha != 1) g.pushOpacity(alpha);

			// Draw the actual image
			// TODO: scale?
			g.drawScaledSubImage(image,
				// the spritesheet's frame to extract from
				frameX, frameY, frameWidth, frameHeight, 
				// the target position
				x + (dx+frameWidth/2) - (frameWidth/2),
				y + (dy+frameHeight/2) - (frameHeight/2),
				frameWidth * fx * scale,
				frameHeight * fy * scale);

			// Finalise opacity
			if (alpha != 1) g.popOpacity();

			// Finalise the rotation
			if (angle != 0) g.popTransformation();
		}

		if (Wyngine.DEBUG_DRAW && Wyngine.DRAW_COUNT < Wyngine.DRAW_COUNT_MAX)
		{
			// Debug hitbox
			g.color = Color.Red;
			g.drawRect(x + offset.x, y + offset.y, width, height);

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
	 * Convenient method to create images if you're prototyping without images.
	 */
	public function createEmptyImage (w:Int=50, h:Int=50)
	{
		// Reset the size
		width = w;
		height = h;

		// Create a new image
		image = Image.createRenderTarget(w, h);

		// Set the frame size to same as image size
		frameWidth = w;
		frameHeight = h;

		// NOTE: does not adjust hitbox offset
	}

	/**
	 * Convenient method to create images if you're prototyping without images.
	 */
	public function createPlaceholderRect (color:Color, w:Int=50, h:Int=50, filled:Bool=false)
	{
		createEmptyImage(w, h);

		image.g2.begin(true, Color.fromValue(0x00000000));
		image.g2.color = color;
		if (filled)
			image.g2.fillRect(0, 0, w, h);
		else
			image.g2.drawRect(0, 0, w, h);
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
		// Image name is set from project.kha
		image = Loader.the.getImage(name);

		// Update variables
		frameWidth = frameW;
		frameHeight = frameH;
		frameX = 0;
		frameY = 0;
		frameColumns = Std.int(image.width / frameWidth);

		width = frameW;
		height = frameH;

		// NOTE: does not adjust hitbox offset
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
		var sheetIndex:Int = animator.getSheetIndex();
		frameX = Std.int(sheetIndex % frameColumns) * frameWidth;
		frameY = Std.int(sheetIndex / frameColumns) * frameHeight;
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
}