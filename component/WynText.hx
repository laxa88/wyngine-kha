package wyn.component;

import kha.Font;
import kha.Color;
import kha.Image;
import kha.graphics2.Graphics;

class WynText extends WynComponent
{
	public static var WYN_DEBUG:Bool = false;

	// TODO:
	// process multi-line texts
	// - calculate overall height and width when doing set_text, set_size or set_font
	// - update tx/ty based on halign, valign

	public var text(default, set):String = "";
	var texts:Array<String> = []; // for printing newlines

	public var font:Font;
	public var halign:HAlign = HAlign.LEFT;
	public var valign:VAlign = VAlign.TOP;
	public var fontSize:Int = 12;
	// public var width:Int = 0; // not needed
	// public var height:Int = 0; // not needed
	// public var alpha:Float = 1; // TODO
	// public var scale:Float = 1; // TODO
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var color:Color = 0xFFFFFFFF; // default white
	static var oldColor:Color; // for reusability



	public function new (t:String, f:Font, s:Int, ?option:TextOptions)
	{
		super();

		text = t;

		setFont(f);

		setSize(s);

		if (option != null)
		{
			if (option.color != null)
				color = option.color;

			if (option.halign != null)
				halign = option.halign;

			if (option.valign != null)
				valign = option.valign;
		}
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
		if (!visible)
			return;
		
		oldColor = g.color;

		g.font = font;
		g.fontSize = fontSize;
		g.color = color;

		// NOTE
		// Can't rotate text because we don't know the width/height
		// and so... conveniently skip alpha as well

		var tx:Float = parent.x + offsetX;
		var ty:Float = parent.y + offsetY;
		var w:Float = 0;
		var h:Float = 0;
		var nx:Float = 0;
		var ny:Float = 0;
		var lineY:Float = 0;
		var lines:Float = texts.length;
		var h = g.font.height(fontSize);

		switch (valign)
		{
			case VAlign.TOP:
				ny = ty;

			case VAlign.CENTER:
				lineY = -(lines-1) * h / 2.0;
				ny = ty - h/2;

			case VAlign.BOTTOM:
				lineY = -(lines-1) * h;
				ny = ty - h;
		}

		for (line in texts)
		{
			w = g.font.width(fontSize, line);

			switch (halign)
			{
				case HAlign.LEFT:
					nx = tx;

				case HAlign.MIDDLE:
					nx = tx - w/2;

				case HAlign.RIGHT:
					nx = tx - w;
			}

			g.drawString(line, nx, ny + lineY);

			if (WYN_DEBUG)
				g.drawRect(nx, ny + lineY, w, h);

			lineY += h;
		}

		g.color = oldColor;
	}

	inline public function setOffset (ox:Float, oy:Float)
	{
		offsetX = ox;
		offsetY = oy;
	}

	public function set_text (val:String) : String
	{
		if (text == val)
			return text;

		text = val;

		// split the text by newlines only
		// gets ALL occurence of line breaks and splits into array
		texts = ~/[\n\r]/g.split(val);

		return val;
	}
}