package wyn.component;

import kha.Image;
import kha.graphics2.Graphics;
import kha.math.FastMatrix3;
import wyn.util.WynUtil;

class WynSprite extends WynComponent
{
	public static var DEBUG:Bool = false;

	public var image:Image;
	public var region:Region;
	public var width:Int = 0;
	public var height:Int = 0;
	public var alpha:Float = 1;
	public var angle:Float = 0; // 0 ~ 360
	public var scale:Float = 1;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public function new (w:Int, h:Int)
	{
		super();

		width = w;
		height = h;
	}

	override public function init ()
	{
		parent.addRenderer(render);
	}

	override public function destroy ()
	{
		super.destroy();

		parent.removeRenderer(render);

		image = null;
		region = null;
	}



	public function render (g:Graphics)
	{
		if (image == null || region == null)
			return;

		if (angle != 0)
		{
			var ox = parent.x - (parent.screen.scrollX - parent.screen.shakeX) * parent.scrollFactorX + offsetX;
			var oy = parent.y - (parent.screen.scrollY - parent.screen.shakeY) * parent.scrollFactorY + offsetY;

			var rad = WynUtil.degToRad(angle);
				g.pushTransformation(g.transformation
					// offset toward top-left, to center image on pivot point
					.multmat(FastMatrix3.translation(ox + scale*width/2, oy + scale*height/2))
					// rotate at pivot point
					.multmat(FastMatrix3.rotation(rad))
					// reverse offset
					.multmat(FastMatrix3.translation(-ox - scale*width/2, -oy - scale*height/2)));
		}

		// Add opacity if any
		if (alpha != 1) g.pushOpacity(alpha);

		g.drawScaledSubImage(image,
			region.x, region.y,
			region.w, region.h,
			parent.x + offsetX, parent.y + offsetY,
			width * scale, height * scale);

		// Finalise opacity
		if (alpha != 1) g.popOpacity();

		// Finalise the rotation
		if (angle != 0) g.popTransformation();

		if (DEBUG)
			g.drawRect(parent.x + offsetX, parent.y + offsetY, width, height);
	}

	inline public function setImage (img:Image, data:Region)
	{
		image = img;

		// width/height can be stretched, so don't follow provided img size.
		// width = img.width;
		// height = img.height;

		region = data;
	}

	inline public function setOffset (ox:Float, oy:Float)
	{
		offsetX = ox;
		offsetY = oy;
	}

	inline public function setSize (w:Int, h:Int)
	{
		width = w;
		height = h;
	}
}