package wyn.manager;

typedef TweenData = {
	var target:Dynamic;
	var props:Dynamic;
	var elapsed:Float;
	var duration:Float;
	var ease:Int;
	var callback:Void->Void;
	var paused:Bool;
}