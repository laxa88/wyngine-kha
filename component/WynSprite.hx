package wyn.component;

import kha.Image;
import kha.graphics2.Graphics;

class WynSprite extends WynComponent
{
	public var image:Image;
	public var region:Region;

	public function new ()
	{
		super();
	}

	override public function init ()
	{
		parent.render = render;
	}

	public function setImage (img:Image, sx:Int, sy:Int, sw:Int, sh:Int)
	{
		image = img;
		region = {
			sx : sx,
			sy : sy,
			sw : sw,
			sh : sh
		};
	}

	public function render (g:Graphics)
	{
		if (image == null || region == null)
			return;

		g.drawScaledSubImage(image,
			region.sx, region.sy,
			region.sw, region.sh,
			parent.x, parent.y,
			parent.width, parent.height);
	}

	override public function destroy ()
	{
		super.destroy();

		image = null;
		region = null;
	}
}

typedef Region = {
	var sx:Int;
	var sy:Int;
	var sw:Int;
	var sh:Int;
}