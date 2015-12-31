package wyn.component;

import kha.Font;
import kha.Color;
import kha.Image;
import kha.graphics2.Graphics;

class WynText extends WynComponent
{
	// TODO:
	// process multi-line texts
	// - calculate overall height and width when doing set_text, set_size or set_font
	// - update tx/ty based on halign, valign

	public var color:Color;
	public var font:Font;
	public var fontSize:Int;
	public var text:String = "";
	public var halign:HAlign = HAlign.LEFT;
	public var valign:VAlign = VAlign.TOP;

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

		var tx = parent.x;
		var ty = parent.y;

		var w:Float = g.font.width(fontSize, text);
		var h:Float = g.font.height(fontSize);

		switch (halign)
		{
			case HAlign.LEFT:
				// do nothing

			case HAlign.MIDDLE:
				tx -= w/2;

			case HAlign.RIGHT:
				tx -= w;
		}

		switch (valign)
		{
			case VAlign.TOP:
				// do nothing

			case VAlign.CENTER:
				ty -= h/2;

			case VAlign.BOTTOM:
				ty -= h;
		}

		g.drawString(text, tx, ty);

		g.color = oldColor;
	}
}