package wy;

import kha.Color;
import kha.Loader;
import kha.Font;
import kha.FontStyle;
import kha.graphics2.Graphics;

import bitmapText.BitmapText;
import bitmapText.BitmapTextAlign;

class WyBitmapText extends WyObject
{
	private var _bm:BitmapText;
	public var _font:String;
	public var _width:Int;
	public var _height:Int;
	private var _cacheText:String;
	private var _cacheAlign:BitmapTextAlign;
	private var _oriColor:Color;

	public var text(get,set):String;
	private inline function get_text():String { return _cacheText; }
	private inline function set_text(s:String):String {
		if (s == _cacheText)
			return _cacheText;
		else {
			_cacheText = s;
			_bm.text = s;
			_bm.update();
			return _cacheText;
		}
	}
	public var align(get,set):BitmapTextAlign;
	private inline function get_align():BitmapTextAlign { return _cacheAlign; }
	private inline function set_align(a:BitmapTextAlign):BitmapTextAlign {
		if (a == _cacheAlign)
			return _cacheAlign;
		else {
			_cacheAlign = a;
			_bm.align = a;
			_bm.update();
			return _cacheAlign;
		}
	}
	



	public override function update (elapsed:Float):Void
	{
		// TODO - animate, jiggle, etc
	}
	public override function render (g:Graphics):Void
	{
		_oriColor = g.color;
		g.color = Color.White;
		g.drawImage(_bm.image, _x, _y);
		g.color = _oriColor;

		if (true)
		{
			// debug text area
			g.drawRect(_x, _y, _width, _height);
		}
	}



	public function loadFont (font:String, width:Int, height:Int, text:String="")
	{
		// NOTE:
		// - font size must be available from assets folder
		//_font = Loader.the.loadFont(filename, new FontStyle(false, false, false), size);
		//Wy.log("load : " + _font.name + " , " + _font.size);

		_font = font;
		_width = width;
		_height = height;

		// Load font data
		BitmapText.loadFont(font);

		// Init and create a new bitmap for text
		_bm = new BitmapText(text, _font, _width, _height);
	}
	public function setBitmapSize (width:Int, height:Int)
	{
		_width = width;
		_height = height;
		_bm = new BitmapText(_bm.text, _font, _width, _height);
	}
}