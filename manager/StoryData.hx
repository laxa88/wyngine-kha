package wyn.manager;

typedef StoryData = {
	var name:String;
	var eventIndex:Int;
	var events:Array<EventData>;
	var elapsed:Float;
	var loopCounter:Int;
	var loop:Int; // -1 = infinite, 0 = no repeat
	var paused:Bool;
	var firedEvent:Bool;
}