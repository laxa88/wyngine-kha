package wy;

import kha.Image;
import kha.Color;
import kha.Loader;
import kha.Font;
import kha.FontStyle;
import kha.graphics2.Graphics;

class WyText extends WyObject
{
	public var _font:Font;
	public var _color:Color;
	public var _text:String;



	public function new (x:Int=0, y:Int=0, name:String, size:Int, w:Int=200, h:Int=100, bold:Bool=false, italic:Bool=false, underlined:Bool=false)
	{
		super(x,y);

		_frameW = w;
		_frameH = h;

		setFont(name, size, bold, italic, underlined);
		_color = Color.White;
		_text = "";
		_image = Image.createRenderTarget(_frameW, _frameH);
	}

	public override function update (dt:Float)
	{
		super.update(dt);
	}

	public override function render (g:Graphics)
	{
		super.render(g);
	}

	public function setFont (name:String, size:Int, bold:Bool=false, italic:Bool=false, underlined:Bool=false)
	{
		// Make sure the size is available as in project.kha
		_font = Loader.the.loadFont(name, new FontStyle(bold, italic, underlined), size);
	}

	public function setText (t:String)
	{
		_text = t;

		// Update the text once
		_image.g2.begin(true, Color.fromValue(0x00000000));
		_image.g2.font = _font;
		_image.g2.color = _color; // white
		_image.g2.drawString(_text, 0, 0);
		_image.g2.end();
	}
}