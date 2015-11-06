package wyn;

import kha.Color;
import kha.Image;
import kha.Loader;
import kha.Rectangle;
import kha.graphics2.Graphics;

class WynButton extends WynSprite
{
	/**
	 * - Buttons have separate images for up/hover/down states.
	 * - If the button is 9-slices, it will re-draw the slice every time
	 * the width or height changes.
	 * - By logic, a 9-slice image cannot be animated because it consists
	 * of 9 parts within a spritesheet.
	 * - As such, buttons can't be animated.
	 *
	 * To use WynButton:
	 * - instance it normally like a WynSprite
	 * - load the image and provide the down/hover/up state's SliceData
	 * - (optional) set the hitbox offset.
	 */

	// Button states as int
	public static inline var NONE:Int = 0;
	public static inline var DOWN:Int = 1;
	public static inline var HOVER:Int = 2;
	public static inline var OVER:Int = 3;

	// These store a cached image for the 9-sliced button.
	// This way we don't have to slice it every update.
	var imageUp:Image;
	var imageHover:Image;
	var imageDown:Image;

	// Store the slice data so we can reslice it when width or height changes
	var upData:WynSprite.SliceData;
	var hoverData:WynSprite.SliceData;
	var downData:WynSprite.SliceData;



	public function new (x:Float=0, y:Float=0, w:Float=0, h:Float=0)
	{
		super(x, y, w, h);
	}

	override public function update (dt:Float)
	{
		super.update(dt);
	}

	override public function render (c:WynCamera)
	{
		super.render(c);
	}

	override public function destroy ()
	{
		super.destroy();
	}

	override public function kill ()
	{
		super.kill();
	}

	override public function revive ()
	{
		super.revive();
	}

	/**
	 * Load image via kha's internal image loader. Make
	 * sure you loaded the room that contains this image,
	 * in project.kha.
	 */
	public function loadButtonImage (name:String, w:Float, h:Float, downData:WynSprite.SliceData, hoverData:WynSprite.SliceData, upData:WynSprite.SliceData)
	{

		if (downData != null)
		{
			this.downData = downData;
			drawSlice(imageUp, downData);
		}

		if (hoverData != null)
		{
			this.hoverData = hoverData;
			drawSlice(imageUp, hoverData);
		}

		if (upData != null)
		{
			this.upData = upData;
			drawSlice(imageUp, upData);
		}
	}
}