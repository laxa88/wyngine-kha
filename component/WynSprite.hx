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
	public var offsetX:Int = 0;
	public var offsetY:Int = 0;

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

		g.drawScaledSubImage(image,
			region.sx, region.sy,
			region.sw, region.sh,
			parent.x + offsetX, parent.y + offsetY,
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
		image = img;
		region = {
			sx : data.x,
			sy : data.y,
			sw : data.width,
			sh : data.height
		};
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