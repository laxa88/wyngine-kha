package wyn;

import kha.math.FastVector2;
import kha.graphics2.Graphics;
import kha.Image;
import kha.Color;

// Refer to WynMouse.onMouseStart for explanation
typedef MouseData =
{
	var windowX:Int;
	var windowY:Int;
	var screenX:Int;
	var screenY:Int;
	var camWindowX:Int;
	var camWindowY:Int;
	var camScreenX:Int;
	var camScreenY:Int;
	var worldX:Int;
	var worldY:Int;
}

class WynCamera
{
	// TODO
	// camera zoom

	/**
	 * Each camera is basically an image which we'll render
	 * to the final screen buffer later. Wyngine will handle
	 * calling each camera's rendering.
	 *
	 * All game objects are rendered to all cameras; the only
	 * difference is where you can draw each object within those
	 * cameras, and then what you can do to the camera's
	 * size/layer order.
	 */

	public var buffer:Image;

	// This is where the image will "render" WynSprites.
	// e.g. if a sprite is at x=50 and camera has scrollX=20,
	// then the the sprite is actually rendered at x=30 within
	// this camera.
	public var scrollX:Float = 0;
	public var scrollY:Float = 0;
	public var shakeHorizontal:Bool = false;
	public var shakeVertical:Bool = false;
	public var intensity:Float = 0;
	public var weakenRate:Float = 0;
	public var shakeX:Float = 0;
	public var shakeY:Float = 0;

	var isFading:Bool = false;
	var curtainImage:Image;
	var curtainColor:Color;
	var curtainFadeDirection:Float = 0;
	var curtainAlpha:Float = 0;
	var curtainDuration:Float = 0;
	var curtainCallback:Void->Void;

	// This is the physical size of the camera that will be
	// rendered onto the screen.
	// E.g. {x:50, y:50} means the camera position is offset
	// 50,50 away from top-left corner.
	public var x:Float = 0;
	public var y:Float = 0;
	public var width:Float = 0;
	public var height:Float = 0;
	public var bgColor:Color;
	public var zoom(default, set):Float = 1;

	// Mouse listeners
	var downListeners:Array<MouseData->Void>;
	var moveListeners:Array<MouseData->Void>;
	var upListeners:Array<MouseData->Void>;



	public function new (x:Int, y:Int, width:Int, height:Int, color:Color, zoom:Float=1)
	{
		// NOTE:
		// zoom can only be >= 1

		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		bgColor = color;
		this.zoom = zoom;

		downListeners = [];
		moveListeners = [];
		upListeners = [];

		buffer = Image.createRenderTarget(width, height);

		curtainImage = Image.createRenderTarget(1, 1); // we only need to upscale to the screen size
		curtainImage.g2.begin();
		curtainImage.g2.color = Color.White;
		curtainImage.g2.fillRect(0, 0, 1, 1);
		curtainImage.g2.end();
	}

	/**
	 * This is called from Wyngine to update animations, such as
	 * camera shake, flash, etc.
	 */
	public function update (dt:Float)
	{
		// Handle camera shake logic
		if (intensity > 0)
		{
			var point:FastVector2 = WynUtil.randomInCircle().mult(intensity);
			shakeX = (shakeHorizontal) ? point.x : 0;
			shakeY = (shakeVertical) ? point.y : 0;
			intensity -= dt * weakenRate;

			if (intensity <= 0)
			{
				shakeX = 0;
				shakeY = 0;
			}
		}

		// Handle flash, fadein, fadeout logic
		if (isFading || curtainDuration > 0)
		{
			curtainDuration -= dt;
			curtainAlpha += (curtainFadeDirection * (dt / curtainDuration)); // fade forward or back

			if (curtainDuration <= 0)
			{
				if (curtainCallback != null)
					curtainCallback();

				curtainCallback = null;
				curtainDuration = 0;
				curtainAlpha = (curtainFadeDirection < 0) ? 0 : 1;
				isFading = false;
			}
		}
	}

	/**
	 * This is called to render extra stuff on the cameraa fter
	 * updates, such as camera flashes.
	 */
	public function render ()
	{
		// As long as the curtain isn't invisible, we draw the curtain.
		if (curtainAlpha != 0)
		{
			var g = buffer.g2;
			var oldOpacity = g.opacity;
			var oldColor = g.color;
			g.color = Color.White;
			g.opacity = curtainAlpha;
			g.drawScaledImage(curtainImage, 0, 0, width, height);
			g.opacity = oldOpacity;
			g.color = oldColor;
		}
	}

	public function shake (intensity:Float, weakenRate:Float, horizontal:Bool=true, vertical:Bool=true)
	{
		this.intensity = intensity;
		this.weakenRate = weakenRate;
		shakeHorizontal = horizontal;
		shakeVertical = vertical;
	}

	public function fill (color:Color)
	{
		// This is literally a fadeOut() without a duration.
		fadeOut(color, 0, null);
	}

	public function flash (color:Color, duration:Float)
	{
		// This is the same as fadeIn(). The only difference is
		// the more intuitive name and the lack of callback.
		fadeIn(color, duration, null);
	}

	public function fadeIn (color:Color, duration:Float, callback:Void->Void)
	{
		curtainColor = color;
		curtainAlpha = 1;
		curtainDuration = duration;
		curtainCallback = callback;
		curtainFadeDirection = -1; // from alpha 1 to 0
		isFading = true;
	}

	public function fadeOut (color:Color, duration:Float, callback:Void->Void)
	{
		curtainColor = color;
		curtainAlpha = 0;
		curtainDuration = duration;
		curtainCallback = callback;
		curtainFadeDirection = 1; // from alpha 0 to 1
		isFading = true;
	}

	/**
	 * Use these notify methods to listen for mouse
	 * up/move/down for each individual camera
	 */

	public function notifyMouseDown (listener:MouseData->Void)
	{
		// Don't add duplicates
		if (downListeners.indexOf(listener) != -1)
			return;

		downListeners.push(listener);
	}

	public function notifyMouseMove (listener:MouseData->Void)
	{
		// Don't add duplicates
		if (moveListeners.indexOf(listener) != -1)
			return;

		moveListeners.push(listener);
	}

	public function notifyMouseUp (listener:MouseData->Void)
	{
		// Don't add duplicates
		if (upListeners.indexOf(listener) != -1)
			return;

		upListeners.push(listener);
	}

	/**
	 * These methods are called by WynMouse accordingly.
	 */

	public function onMouseStart (data:MouseData)
	{
		for (listener in downListeners)
			listener(data);
	}

	public function onMouseMove (data:MouseData)
	{
		for (listener in moveListeners)
			listener(data);
	}

	public function onMouseEnd (data:MouseData)
	{
		for (listener in upListeners)
			listener(data);
	}

	private function set_zoom (val:Float) : Float
	{
		if (val < 1)
			val = 1;

		return (zoom = val);
	}
}