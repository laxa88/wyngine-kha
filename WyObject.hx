package wy;

import kha.graphics2.Graphics;

class WyObject
{
	public var _id:Int;
	public var _active:Bool;
	public var _x:Float;
	public var _y:Float;
	public var _z:Int;

	public function new (x:Int=0, y:Int=0, ?z:Int):Void {}
	public function init ():Void {}
	public function destroy ():Void {}
	public function update (elapsed:Float):Void {}
	public function render (g:Graphics):Void {}
}