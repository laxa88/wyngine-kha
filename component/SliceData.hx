package wyn.component;

typedef SliceData = {
	var x:Int; // the position and size of the button image to be 9-sliced
	var y:Int;
	var width:Int;
	var height:Int;
	@:optional var borderLeft:Int; // the 9-slice offset to cut from. It's the same as how Unity's SpriteEditor does it.
	@:optional var borderTop:Int;
	@:optional var borderRight:Int;
	@:optional var borderBottom:Int;
}