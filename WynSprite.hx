package wyn;

import kha.Color;
import kha.Image;
import kha.Rectangle;
import kha.Loader;
import kha.math.FastMatrix3;
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
	public var frameColumns:Int; // Number of columns in spritesheet
	public var frameX:Int; // Frame position, for animation purpose
	public var frameY:Int;
	public var frameWidth:Int; // Individual frame's size
	public var frameHeight:Int;
	public var hitbox:Rectangle;
	public var color:Color = Color.White; // tint, default is white
	public var alpha:Float = 1.0; // Opacity - 0.0 to 1.0
	public var flipX:Bool = false;
	public var flipY:Bool = false;
	public var facing(default, set):Int;
	var _faceMap:Map<Int, {x:Bool, y:Bool}> = new Map<Int, {x:Bool, y:Bool}>();



	public function new (?x:Float=0, ?y:Float=0, ?w:Float=0, ?h:Float=0)
	{
		super(x, y, w, h);

		hitbox = new Rectangle(x, y, w, h);
	}

	override public function update (dt:Float)
	{
		super.update(dt);
	}

	override public function render (g:Graphics)
	{
		super.render(g);

		// Image is offset based on hitbox. In collision checking,
		// such as WynQuadTree, we consider the hitbox's x/y/width/height,
		// not the image's x/y/width/height.
		var imgX = x - hitbox.x;
		var imgY = y - hitbox.y;

		if (Wyngine.DEBUG)
		{
			g.color = Color.Green;
			g.drawRect(imgX, imgY, frameWidth, frameHeight);
		}

		if (image != null && visible)
		{
			g.color = color;

			// If an image is flipped, we need to offset it by width/height
			var dx = (flipX) ? frameWidth : 0;
			var dy = (flipY) ? frameHeight : 0;
			var face = 1;

			// Remember: Rotations are expensive!
			if (angle != 0)
			{
				var rad = WynUtil.degToRad(angle);
				g.pushTransformation(g.transformation
					// offset toward top-left
					.multmat(FastMatrix3.translation(imgX + frameWidth/2, imgY + frameHeight/2))
					// rotate at offset pivot point
					.multmat(FastMatrix3.rotation(rad))
					// reverse offset
					.multmat(FastMatrix3.translation(-imgX - frameWidth/2, -imgY - frameHeight/2)));
			}

			// Add opacity if any
			if (alpha != 1) g.pushOpacity(alpha);

			// Draw the actual image, scaled if required
			g.drawScaledSubImage(image, frameX, frameY, frameWidth, frameHeight, 
				imgX + dx+(frameWidth/2) - (frameWidth/2), 
				imgY + (frameHeight/2) - (frameHeight/2), 
				frameWidth * face,
				frameHeight);

			// Finalise opacity
			if (alpha != 1) g.popOpacity();

			// Finalise the rotation
			if (angle != 0) g.popTransformation();
		}

		if (Wyngine.DEBUG)
		{
			// Debug hitbox
			g.color = Color.Red;
			g.drawRect(x, y, hitbox.width, hitbox.height);
		}
	}

	override public function destroy ()
	{
		super.destroy();
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

		// Reset hitbox
		setHitbox(0, 0, frameWidth, frameHeight);
	}

	/**
	 * Convenient method to create images if you're prototyping without images.
	 */
	public function createPlaceholderRect (color:Color, w:Int=50, h:Int=50, filled:Bool=false)
	{
		createEmptyImage(w, h);

		image.g2.begin(true, color);
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

		// Reset hitbox
		setHitbox(0, 0, frameWidth, frameHeight);
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

		// Reset hitbox
		setHitbox(0, 0, image.width, image.height);
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

	/**
	 * Sets the hitbox size, and offsets X/Y position from top-left origin.
	 * You'll probably need this if your hitbox is not the same size as
	 * the frame's size.
	 */
	public function setHitbox (offsetX:Float, offsetY:Float, w:Float, h:Float)
	{
		hitbox.x = offsetX;
		hitbox.y = offsetY;
		hitbox.width = w;
		hitbox.height = h;
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