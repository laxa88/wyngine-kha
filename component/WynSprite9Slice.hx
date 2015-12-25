package wyn.component;

import kha.Image;
import kha.graphics2.Graphics;

class WynSprite9Slice extends WynComponent
{
	public static var DEBUG:Bool = false;

	var originImage:Image;
	var image:Image;
	var sliceData:SliceData;
	public var width(default, set):Int = 0;
	public var height(default, set):Int = 0;

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
		image = null;
		sliceData = null;
	}



	public function render (g:Graphics)
	{
		if (originImage == null || image == null || sliceData == null)
			return;

		g.drawScaledSubImage(image,
			0, 0,
			width, height,
			parent.x, parent.y,
			width, height);

		// if (DEBUG)
		// {
		// 	g.color = 0xFFFF0000;
		// 	g.drawRect(parent.x, parent.y, width, height);
		// 	g.color = 0xFFFFFFFF;
		// }
	}

	public function setImage (img:Image, data:SliceData)
	{
		originImage = img;

		image = Image.createRenderTarget(width, height);

		sliceData = data;

		draw9Slice();
	}

	function draw9Slice ()
	{
		if (sliceData == null)
			return;

		var g:Graphics = image.g2;

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
		g.begin(true, 0x00000000);

		// g.fillRect(0,0,1,1);

		// top-left border
		g.drawScaledSubImage(originImage,
			sx, sy, sliceData.borderLeft, sliceData.borderTop, // source
			0, 0, sliceData.borderLeft*ratioW, sliceData.borderTop*ratioH // destination
			);

		// top border
		g.drawScaledSubImage(originImage,
			sliceData.borderLeft, sy, sw, sliceData.borderTop,
			sliceData.borderLeft*ratioW, 0, dw, sliceData.borderTop*ratioH
			);

		// top-right border
		g.drawScaledSubImage(originImage,
			sliceData.width-sliceData.borderRight, sy, sliceData.borderRight, sliceData.borderTop,
			destW-sliceData.borderRight*ratioW, 0, sliceData.borderRight*ratioW, sliceData.borderTop*ratioH
			);

		// middle-left border
		g.drawScaledSubImage(originImage,
			sx, sy+sliceData.borderTop, sliceData.borderLeft, sh,
			0, sliceData.borderTop*ratioH, sliceData.borderLeft*ratioW, dh
			);

		// middle
		g.drawScaledSubImage(originImage,
			sliceData.borderLeft, sy+sliceData.borderTop, sw, sh,
			sliceData.borderLeft*ratioW, sliceData.borderTop*ratioH, dw, dh
			);

		// middle-right border
		g.drawScaledSubImage(originImage,
			sliceData.width-sliceData.borderRight, sy+sliceData.borderTop, sliceData.borderRight, sh,
			destW-sliceData.borderRight*ratioW, sliceData.borderTop*ratioH, sliceData.borderRight*ratioW, dh
			);

		// bottom-left border
		g.drawScaledSubImage(originImage,
			sx, sy+sliceData.height-sliceData.borderBottom, sliceData.borderLeft, sliceData.borderBottom,
			0, destH-sliceData.borderBottom*ratioH, sliceData.borderLeft*ratioW, sliceData.borderBottom*ratioH
			);

		// bottom
		g.drawScaledSubImage(originImage,
			sliceData.borderLeft, sy+sliceData.height-sliceData.borderBottom, sw, sliceData.borderBottom,
			sliceData.borderLeft*ratioW, destH-sliceData.borderBottom*ratioH, dw, sliceData.borderBottom*ratioH
			);

		// bottom-right border
		g.drawScaledSubImage(originImage,
			sliceData.width-sliceData.borderRight, sy+sliceData.height-sliceData.borderBottom, sliceData.borderRight, sliceData.borderBottom,
			destW-sliceData.borderRight*ratioW, destH-sliceData.borderBottom*ratioH, sliceData.borderRight*ratioW, sliceData.borderBottom*ratioH
			);

		g.end();
	}

	private function set_width (val:Int) : Int
	{
		if (width != val)
		{
			width = val;
			image = Image.createRenderTarget(width, height);
			draw9Slice();
		}

		return width;
	}

	private function set_height (val:Int) : Int
	{
		if (height != val)
		{
			height = val;
			image = Image.createRenderTarget(width, height);
			draw9Slice();
		}

		return height;
	}
}