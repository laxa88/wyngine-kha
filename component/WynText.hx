package wyn.component;

import kha.Font;
import kha.Color;
import kha.Image;
import kha.graphics2.Graphics;

class WynText extends WynComponent
{
	public var color:Color;
	public var font:Font;
	public var fontSize:Int;
	public var text:String = "";
	static var oldColor:Color; // for reusability

	public function new (t:String, f:Font, s:Int, c:Color)
	{
		super();

		text = t;
		setFont(f);
		setSize(s);
		color = c;
	}

	override public function init ()
	{
		parent.addRenderer(render);
	}

	override public function destroy ()
	{
		super.destroy();

		parent.removeRenderer(render);

		font = null;
	}



	inline public function setFont (f:Font)
	{
		font = f;
	}

	inline public function setSize (fs:Int)
	{
		fontSize = fs;
	}

	public function render (g:Graphics)
	{
		oldColor = g.color;

		g.font = font;
		g.fontSize = fontSize;
		g.color = color;

		// NOTE
		// Can't rotate text because we don't know the width/height
		// and so... conveniently skip alpha as well

		g.drawString(text, parent.x, parent.y);

		g.color = oldColor;
	}
}