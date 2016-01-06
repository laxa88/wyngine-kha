package wyn.component;

typedef Region = {
	var x:Int;
	var y:Int;
	var w:Int;
	var h:Int;
	@:optional var borderLeft:Int; // the 9-slice offset to cut from. It's the same as how Unity's SpriteEditor does it.
	@:optional var borderTop:Int;
	@:optional var borderRight:Int;
	@:optional var borderBottom:Int;
}