package wyn.component;

import kha.Image;
import wyn.WynObject;

class WynRenderable extends WynComponent
{
	public var image:Image;
	public var region:Region;
	public var width:Int = 0;
	public var height:Int = 0;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var flipX:Bool = false;
	public var flipY:Bool = false;

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

	public function setImage (img:Image, data:Region)
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