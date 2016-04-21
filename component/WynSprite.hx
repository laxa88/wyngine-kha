package wyn.component;

import kha.Image;
import kha.graphics2.Graphics;
import kha.math.FastMatrix3;
import wyn.util.WynUtil;

class WynSprite extends WynRenderable
{
	public static var WYN_DEBUG:Bool = false;

	override public function render (g:Graphics)
	{
		if (!visible)
			return;
		else if (image == null || region == null)
			return;

		// If an image is flipped, we need to offset it by width/height
		var fx = (flipX) ? -1 : 1; // flip image?
		var fy = (flipY) ? -1 : 1;
		var dx = (flipX) ? width*scale : 0; // if image is flipped, displace
		var dy = (flipY) ? height*scale : 0;
		var sx = ((width*scale) - width) / 2; // When iamge is scaled, we center it rather than leave it at origin.
		var sy = ((height*scale) - height) / 2;

		if (angle != 0)
		{
			// 2016-04-21
			// TODO - test if the getPosX/Y works instead of ox/oy
			// var ox = parent.x - (parent.screen.scrollX - parent.screen.shakeX) * parent.scrollFactorX + offsetX;
			// var oy = parent.y - (parent.screen.scrollY - parent.screen.shakeY) * parent.scrollFactorY + offsetY;

			var rad = WynUtil.degToRad(angle);
				g.pushTransformation(g.transformation
					// offset toward top-left, to center image on pivot point
					.multmat(FastMatrix3.translation(getPosX() + scale*width/2, getPosY() + scale*height/2))
					// rotate at pivot point
					.multmat(FastMatrix3.rotation(rad))
					// reverse offset
					.multmat(FastMatrix3.translation(-getPosX() - scale*width/2, -getPosY() - scale*height/2)));
		}

		// Add opacity if any
		if (alpha != 1) g.pushOpacity(alpha);

		g.drawScaledSubImage(image,
			region.x, region.y,
			region.w, region.h,
			getPosX() + (dx+width/2)-(width/2)-sx,
			getPosY() + (dy+height/2)-(height/2)-sy, //parent.x + offsetX, parent.y + offsetY,
			width * fx * scale,
			height * fy * scale);

		// Finalise opacity
		if (alpha != 1) g.popOpacity();

		// Finalise the rotation
		if (angle != 0) g.popTransformation();

		if (WYN_DEBUG)
			g.drawRect(parent.x + offsetX, parent.y + offsetY, width, height);
	}

	inline function getPosX ()
	{
		// http://stackoverflow.com/questions/9942209/unwanted-lines-apearing-in-html5-canvas-using-tiles
		return Math.round(parent.x + offsetX + (parent.screen.scrollX - parent.screen.shakeX) * parent.scrollFactorX);
	}

	inline function getPosY ()
	{
		return Math.round(parent.y + offsetY + (parent.screen.scrollY - parent.screen.shakeY) * parent.scrollFactorY);
	}
}