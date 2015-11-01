package wyn;

import kha.math.FastVector2;
import kha.graphics2.Graphics;
import kha.Image;
import kha.Color;

typedef MouseData =
{
	var worldX:Int;
	var worldY:Int;
	var cameraX:Int;
	var cameraY:Int;
	var screenX:Int;
	var screenY:Int;
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

	public function onMouseStart (worldX:Int, worldY:Int, cameraX:Int, cameraY:Int, screenX:Int, screenY:Int)
	{
		for (listener in downListeners)
		{
			listener({
				worldX : worldX,
				worldY : worldY,
				cameraX : cameraX,
				cameraY : cameraY,
				screenX : screenX,
				screenY : screenY
			});
		}
	}

	public function onMouseMove (worldX:Int, worldY:Int, cameraX:Int, cameraY:Int, screenX:Int, screenY:Int)
	{
		for (listener in moveListeners)
		{
			listener({
				worldX : worldX,
				worldY : worldY,
				cameraX : cameraX,
				cameraY : cameraY,
				screenX : screenX,
				screenY : screenY
			});
		}
	}

	public function onMouseEnd (worldX:Int, worldY:Int, cameraX:Int, cameraY:Int, screenX:Int, screenY:Int)
	{
		for (listener in upListeners)
		{
			listener({
				worldX : worldX,
				worldY : worldY,
				cameraX : cameraX,
				cameraY : cameraY,
				screenX : screenX,
				screenY : screenY
			});
		}
	}

	private function set_zoom (val:Float) : Float
	{
		if (val < 1)
			val = 1;

		return (zoom = val);
	}
}