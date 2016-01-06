package wyn.component;

import kha.Image;
import kha.graphics2.Graphics;
import kha.math.FastMatrix3;
import wyn.util.WynUtil;

class WynSprite9Slice extends WynSprite
{
	// Notes:
	// This component draws each section of the 9-slice directly on the backbuffer.
	//
	// Reason:
	// - If we draw the 9-slice result onto one new image, it invokes 1 new draw call.
	// - If there's 100 9-slice images, this means 100 draw calls.
	// - Instead, directly drawing means no new draw calls, but 9 additional drawScaledSubImage() calls
	// - Test result: direct drawing is about 2x faster than using new image.

	override public function render (g:Graphics)
	{
		if (image == null || region == null)
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
		if (region == null)
			return;

		if (region.borderLeft == null) region.borderLeft = 0;
		if (region.borderRight == null) region.borderRight = 0;
		if (region.borderTop == null) region.borderTop = 0;
		if (region.borderBottom == null) region.borderBottom = 0;

		// If the total of 3-slices horizontally or vertically
		// is longer than the actual button's size, Then we'll have
		// to scale the borders so that they'll stay intact.
		var ratioW = 1.0;
		var ratioH = 1.0;
		var destW = width;
		var destH = height;

		// Get the border width and height (without the corners)
		var sx = region.x;
		var sy = region.y;
		var sw = region.w - region.borderLeft - region.borderRight;
		var sh = region.h - region.borderTop - region.borderBottom;
		var dx = parent.x + offsetX;
		var dy = parent.y + offsetY;
		var dw = destW - region.borderLeft - region.borderRight;
		var dh = destH - region.borderTop - region.borderBottom;
		// Width and height cannot be less than zero.
		if (sw < 0) sw = 0;
		if (sh < 0) sh = 0;
		if (dw < 0) dw = 0;
		if (dh < 0) dh = 0;

		// Get ratio of the border corners if the width or height
		// is zero or less. Imagine when a 9-slice image is too short,
		// we end up not seeing the side borders anymore; only the corners.
		// When that happens, we have to scale the corners by ratio.
		if (destW < region.borderLeft + region.borderRight)
			ratioW = destW / (region.borderLeft + region.borderRight);

		if (destH < region.borderTop + region.borderBottom)
			ratioH = destH / (region.borderTop + region.borderBottom);

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
			sx, sy, region.borderLeft, region.borderTop, // source
			dx, dy, region.borderLeft*ratioW, region.borderTop*ratioH // destination
			);

		// top border
		g.drawScaledSubImage(origin,
			sx+region.borderLeft, sy, sw, region.borderTop,
			dx+(region.borderLeft*ratioW), dy, dw, region.borderTop*ratioH
			);

		// top-right border
		g.drawScaledSubImage(origin,
			sx+region.w-region.borderRight, sy, region.borderRight, region.borderTop,
			dx+(destW-region.borderRight*ratioW), dy, region.borderRight*ratioW, region.borderTop*ratioH
			);

		// middle-left border
		g.drawScaledSubImage(origin,
			sx, sy+region.borderTop, region.borderLeft, sh,
			dx, dy+(region.borderTop*ratioH), region.borderLeft*ratioW, dh
			);

		// middle
		g.drawScaledSubImage(origin,
			sx+region.borderLeft, sy+region.borderTop, sw, sh,
			dx+(region.borderLeft*ratioW), dy+(region.borderTop*ratioH), dw, dh
			);

		// middle-right border
		g.drawScaledSubImage(origin,
			sx+region.w-region.borderRight, sy+region.borderTop, region.borderRight, sh,
			dx+(destW-region.borderRight*ratioW), dy+(region.borderTop*ratioH), region.borderRight*ratioW, dh
			);

		// bottom-left border
		g.drawScaledSubImage(origin,
			sx, sy+region.h-region.borderBottom, region.borderLeft, region.borderBottom,
			dx, dy+(destH-region.borderBottom*ratioH), region.borderLeft*ratioW, region.borderBottom*ratioH
			);

		// bottom
		g.drawScaledSubImage(origin,
			sx+region.borderLeft, sy+region.h-region.borderBottom, sw, region.borderBottom,
			dx+(region.borderLeft*ratioW), dy+(destH-region.borderBottom*ratioH), dw, region.borderBottom*ratioH
			);

		// bottom-right border
		g.drawScaledSubImage(origin,
			sx+region.w-region.borderRight, sy+region.h-region.borderBottom, region.borderRight, region.borderBottom,
			dx+(destW-region.borderRight*ratioW), dy+(destH-region.borderBottom*ratioH), region.borderRight*ratioW, region.borderBottom*ratioH
			);

		// Finalise opacity
		if (alpha != 1) g.popOpacity();

		// Finalise the rotation
		if (parent.angle != 0) g.popTransformation();
	}
}