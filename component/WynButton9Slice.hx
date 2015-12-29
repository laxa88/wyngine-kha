package wyn.component;

import kha.Image;
import kha.graphics2.Graphics;
import kha.math.FastMatrix3;

class WynButton9Slice extends WynButton
{
	var sliceData:SliceData;

	override public function destroy () : Void
	{
		super.destroy();

		sliceData = null;
	}



	override public function render (g:Graphics)
	{
		if (image == null || sliceData == null)
			return;

		draw9Slice(image, g);

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

		if (parent.angle != 0)
		{
			var ox = parent.x - (parent.screen.scrollX - parent.screen.shakeX) * parent.scrollFactorX + offsetX;
			var oy = parent.y - (parent.screen.scrollY - parent.screen.shakeY) * parent.scrollFactorY + offsetY;

			var rad = WynUtil.degToRad(parent.angle);
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

		// top-left border
		g.drawScaledSubImage(origin,
			sx, sy, sliceData.borderLeft, sliceData.borderTop, // source
			dx, dy, sliceData.borderLeft*ratioW, sliceData.borderTop*ratioH // destination
			);

		// top border
		g.drawScaledSubImage(origin,
			sliceData.borderLeft, sy, sw, sliceData.borderTop,
			dx+(sliceData.borderLeft*ratioW), dy, dw, sliceData.borderTop*ratioH
			);

		// top-right border
		g.drawScaledSubImage(origin,
			sliceData.width-sliceData.borderRight, sy, sliceData.borderRight, sliceData.borderTop,
			dx+(destW-sliceData.borderRight*ratioW), dy, sliceData.borderRight*ratioW, sliceData.borderTop*ratioH
			);

		// middle-left border
		g.drawScaledSubImage(origin,
			sx, sy+sliceData.borderTop, sliceData.borderLeft, sh,
			dx, dy+(sliceData.borderTop*ratioH), sliceData.borderLeft*ratioW, dh
			);

		// middle
		g.drawScaledSubImage(origin,
			sliceData.borderLeft, sy+sliceData.borderTop, sw, sh,
			dx+(sliceData.borderLeft*ratioW), dy+(sliceData.borderTop*ratioH), dw, dh
			);

		// middle-right border
		g.drawScaledSubImage(origin,
			sliceData.width-sliceData.borderRight, sy+sliceData.borderTop, sliceData.borderRight, sh,
			dx+(destW-sliceData.borderRight*ratioW), dy+(sliceData.borderTop*ratioH), sliceData.borderRight*ratioW, dh
			);

		// bottom-left border
		g.drawScaledSubImage(origin,
			sx, sy+sliceData.height-sliceData.borderBottom, sliceData.borderLeft, sliceData.borderBottom,
			dx, dy+(destH-sliceData.borderBottom*ratioH), sliceData.borderLeft*ratioW, sliceData.borderBottom*ratioH
			);

		// bottom
		g.drawScaledSubImage(origin,
			sliceData.borderLeft, sy+sliceData.height-sliceData.borderBottom, sw, sliceData.borderBottom,
			dx+(sliceData.borderLeft*ratioW), dy+(destH-sliceData.borderBottom*ratioH), dw, sliceData.borderBottom*ratioH
			);

		// bottom-right border
		g.drawScaledSubImage(origin,
			sliceData.width-sliceData.borderRight, sy+sliceData.height-sliceData.borderBottom, sliceData.borderRight, sliceData.borderBottom,
			dx+(destW-sliceData.borderRight*ratioW), dy+(destH-sliceData.borderBottom*ratioH), sliceData.borderRight*ratioW, sliceData.borderBottom*ratioH
			);

		// Finalise opacity
		if (alpha != 1) g.popOpacity();

		// Finalise the rotation
		if (parent.angle != 0) g.popTransformation();
	}

	override function setState (state:Int)
	{
		prevState = currState;
		currState = state;

		// Default up state
		sliceData = sliceDataUp;

		switch (currState)
		{
			case WynButton.STATE_NONE: sliceData = sliceDataUp;

			case WynButton.STATE_UP: sliceData = sliceDataUp;

			case WynButton.STATE_OVER: sliceData = sliceDataOver;

			case WynButton.STATE_DOWN: sliceData = sliceDataDown;
		}
	}
}