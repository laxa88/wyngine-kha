package wyn.util;

class WynFPS
{
	public var current(get, null):Int;
	private var totalTime:Float;
	private var times:Array<Float>;

	public function new ()
	{
		totalTime = 0;
		times = [];
	}

	public function update (deltaTime:Float):Void
	{
		totalTime += deltaTime;
		times.push(totalTime);
	}

	private function get_current ():Int
	{
		while (times[0] < totalTime - 1.0)
			times.shift();

		return times.length;
	}
}
