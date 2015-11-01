package wyn;

import kha.math.FastVector2;
import kha.graphics2.Graphics;
import kha.Image;
import kha.Color;

class WynCamera
{
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

	// This is the physical size of the camera that will be
	// rendered onto the screen.
	// E.g. {x:50, y:50} means the camera position is offset
	// 50,50 away from top-left corner.
	public var x:Float = 0;
	public var y:Float = 0;
	public var width:Float = 0;
	public var height:Float = 0;
	public var bgColor:Color;



	public function new (x:Int, y:Int, width:Int, height:Int, color:Color)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		bgColor = color;

		buffer = Image.createRenderTarget(width, height);
	}
}