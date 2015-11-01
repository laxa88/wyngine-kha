package wyn;

import kha.Image;
import kha.Color;
import kha.Loader;
import kha.Font;
import kha.FontStyle;
import kha.graphics2.Graphics;

class WynText extends WynSprite
{
	public var font:Font;
	public var text:String = "";
	var _prevText:String = "";



	public function new (t:String, name:String, size:Int, x:Float=0, y:Float=0, w:Int=200, h:Int=100, bold:Bool=false, italic:Bool=false, underlined:Bool=false)
	{
		super(x, y, w, h);

		setFont(name, size, bold, italic, underlined);
		createEmptyImage(w, h);

		text = t;
	}

	public override function update (dt:Float)
	{
		super.update(dt);

		// Only redraw the text if the text changed,
		// to save on draw calls.
		if (text != _prevText)
		{
			updateText();
			_prevText = text;
		}
	}

	public override function render (c:WynCamera)
	{
		c.buffer.g2.font = font;

		super.render(c);
	}

	public function setFont (name:String, size:Int, bold:Bool=false, italic:Bool=false, underlined:Bool=false)
	{
		// Make sure the size is available as in project.kha
		font = Loader.the.loadFont(name, new FontStyle(bold, italic, underlined), size);
	}

	function updateText ()
	{
		// Only update the text if something changed.
		// We can save on unnecessarily drawing text this way.
		// Update the text once
		image.g2.begin(true, Color.fromValue(0x00000000));
		image.g2.font = font;
		image.g2.color = color; // white
		image.g2.drawString(text, 0, 0);
		image.g2.end();
	}
}