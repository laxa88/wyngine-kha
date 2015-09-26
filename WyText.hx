package wy;

import kha.graphics2.Graphics;

class WyText extends WyObject
{
	public var _text:String;



	public function new (x:Int=0, y:Int=0, ?z:Int):Void
	{
		super(x,y,z);
	}
	public override function init ():Void
	{

	}
	public override function destroy ():Void
	{

	}
	public override function update (elapsed:Float):Void
	{

	}
	public override function render (g:Graphics):Void
	{
		g.drawString("text : " + _text, _x, _y);
	}
}