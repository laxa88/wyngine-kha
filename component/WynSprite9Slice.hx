package wyn.component;

import kha.Image;
import kha.graphics2.Graphics;

class WynSprite9Slice extends WynComponent
{
	// Notes:
	// This component draws each section of the 9-slice directly on the backbuffer.
	//
	// Reason:
	// - If we draw the 9-slice result onto one new image, it invokes 1 new draw call.
	// - If there's 100 9-slice images, this means 100 draw calls.
	// - Instead, directly drawing means no new draw calls, but 9 additional drawScaledSubImage() calls
	// - Test result: direct drawing is about 2x faster than using new image.

	public static var DEBUG:Bool = false;

	var originImage:Image;
	var sliceData:SliceData;
	public var width:Int = 0;
	public var height:Int = 0;
	public var offsetX:Int = 0;
	public var offsetY:Int = 0;

	public function new (w:Int, h:Int) : Void
	{
		super();

		width = w;
		height = h;
	}

	override public function init () : Void
	{
		parent.addRenderer(render);
	}

	override public function destroy () : Void
	{
		super.destroy();

		parent.removeRenderer(render);

		originImage = null;
		sliceData = null;
	}



	public function render (g:Graphics)
	{
		if (originImage == null || sliceData == null)
			return;

		draw9Slice(originImage, g);

		// if (DEBUG)
		// {
		// 	g.color = 0xFFFF0000;
		// 	g.drawRect(parent.x, parent.y, width, height);
		// 	g.color = 0xFFFFFFFF;
		// }
	}

	inline function draw9Slice (origin:Image, g:Graphics)
	{
		if (sliceData == null)
			return;

		// var g:Graphics = target.g2;

		if (sliceData.borderLeft == null) sliceData.borderLeft = 0;
		if (sliceData.borderRight == null) sliceData.borderRight = 0;
		if (sliceData.borderTop == null) sliceData.borderTop = 0;
		if (sliceData.borderBottom == null) sliceData.borderBottom = 0;

		// If the total of 3-slices horizontally or vertically
		// is longer than the actual button's size, Then we'll have
		// to scale the borders so that they'll stay intact.
		var ratioW = 1.0;
		var ratioH = 1.0;
		var destW = width;
		var destH = height;

		// Get the border width and height (without the corners)
		var sx = sliceData.x;
		var sy = sliceData.y;
		var sw = sliceData.width - sliceData.borderLeft - sliceData.borderRight;
		var sh = sliceData.height - sliceData.borderTop - sliceData.borderBottom;
		var dx = parent.x + offsetX;
		var dy = parent.y + offsetY;
		var dw = destW - sliceData.borderLeft - sliceData.borderRight;
		var dh = destH - sliceData.borderTop - sliceData.borderBottom;
		// Width and height cannot be less than zero.
		if (sw < 0) sw = 0;
		if (sh < 0) sh = 0;
		if (dw < 0) dw = 0;
		if (dh < 0) dh = 0;

		// Get ratio of the border corners if the width or height
		// is zero or less. Imagine when a 9-slice image is too short,
		// we end up not seeing the side borders anymore; only the corners.
		// When that happens, we have to scale the corners by ratio.
		if (destW < sliceData.borderLeft + sliceData.borderRight)
			ratioW = destW / (sliceData.borderLeft + sliceData.borderRight);

		if (destH < sliceData.borderTop + sliceData.borderBottom)
			ratioH = destH / (sliceData.borderTop + sliceData.borderBottom);

		// begin drawing
		// g.begin(true, 0x00000000);

		// g.fillRect(0,0,1,1);

		// top-left border
		g.drawScaledSubImage(originImage,
			sx, sy, sliceData.borderLeft, sliceData.borderTop, // source
			dx, dy, sliceData.borderLeft*ratioW, sliceData.borderTop*ratioH // destination
			);

		// top border
		g.drawScaledSubImage(originImage,
			sliceData.borderLeft, sy, sw, sliceData.borderTop,
			dx+(sliceData.borderLeft*ratioW), dy, dw, sliceData.borderTop*ratioH
			);

		// top-right border
		g.drawScaledSubImage(originImage,
			sliceData.width-sliceData.borderRight, sy, sliceData.borderRight, sliceData.borderTop,
			dx+(destW-sliceData.borderRight*ratioW), dy, sliceData.borderRight*ratioW, sliceData.borderTop*ratioH
			);

		// middle-left border
		g.drawScaledSubImage(originImage,
			sx, sy+sliceData.borderTop, sliceData.borderLeft, sh,
			dx, dy+(sliceData.borderTop*ratioH), sliceData.borderLeft*ratioW, dh
			);

		// middle
		g.drawScaledSubImage(originImage,
			sliceData.borderLeft, sy+sliceData.borderTop, sw, sh,
			dx+(sliceData.borderLeft*ratioW), dy+(sliceData.borderTop*ratioH), dw, dh
			);

		// middle-right border
		g.drawScaledSubImage(originImage,
			sliceData.width-sliceData.borderRight, sy+sliceData.borderTop, sliceData.borderRight, sh,
			dx+(destW-sliceData.borderRight*ratioW), dy+(sliceData.borderTop*ratioH), sliceData.borderRight*ratioW, dh
			);

		// bottom-left border
		g.drawScaledSubImage(originImage,
			sx, sy+sliceData.height-sliceData.borderBottom, sliceData.borderLeft, sliceData.borderBottom,
			dx, dy+(destH-sliceData.borderBottom*ratioH), sliceData.borderLeft*ratioW, sliceData.borderBottom*ratioH
			);

		// bottom
		g.drawScaledSubImage(originImage,
			sliceData.borderLeft, sy+sliceData.height-sliceData.borderBottom, sw, sliceData.borderBottom,
			dx+(sliceData.borderLeft*ratioW), dy+(destH-sliceData.borderBottom*ratioH), dw, sliceData.borderBottom*ratioH
			);

		// bottom-right border
		g.drawScaledSubImage(originImage,
			sliceData.width-sliceData.borderRight, sy+sliceData.height-sliceData.borderBottom, sliceData.borderRight, sliceData.borderBottom,
			dx+(destW-sliceData.borderRight*ratioW), dy+(destH-sliceData.borderBottom*ratioH), sliceData.borderRight*ratioW, sliceData.borderBottom*ratioH
			);

		g.end();
	}

	public function setImage (img:Image, data:SliceData)
	{
		originImage = img;
		sliceData = data;
	}

	inline public function setSize (w:Int, h:Int)
	{
		width = w;
		height = h;
	}

	inline public function setOffset (x:Int, y:Int)
	{
		offsetX = x;
		offsetY = y;
	}
}