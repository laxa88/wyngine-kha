package wyn.component;

import kha.Image;
import kha.graphics2.Graphics;

class WynSprite extends WynComponent
{
	public static var DEBUG:Bool = false;
	public var image:Image;
	public var region:Region;
	public var width:Int = 0;
	public var height:Int = 0;

	public function new (w:Int, h:Int)
	{
		super();

		width = w;
		height = h;
	}

	override public function init ()
	{
		if (parent.render != null)
			trace("Warning: replace an existing render method.");

		parent.render = render;
	}

	override public function destroy ()
	{
		super.destroy();

		image = null;
		region = null;
	}



	public function render (g:Graphics)
	{
		if (image == null || region == null)
			return;

		g.drawScaledSubImage(image,
			region.sx, region.sy,
			region.sw, region.sh,
			parent.x, parent.y,
			width, height);

		// if (DEBUG)
		// {
		// 	g.color = 0xFFFF0000;
		// 	g.drawRect(parent.x, parent.y, width, height);
		// 	g.color = 0xFFFFFFFF;
		// }
	}

	public function setImage (img:Image, frameX:Int, frameY:Int, frameW:Int, frameH:Int)
	{
		image = img;
		region = {
			sx : frameX,
			sy : frameY,
			sw : frameW,
			sh : frameH
		};
	}
}

typedef Region = {
	var sx:Int;
	var sy:Int;
	var sw:Int;
	var sh:Int;
}