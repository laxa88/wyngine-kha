package wyn;

typedef TweenData = {
	var target:WynObject;
	var prop:String;
	var from:Float;
	var to:Float;
	var elapsed:Float;
	var duration:Float;
	var callback:Void->Void;
	var ease:Int;
	var paused:Bool;
}

class WynTween
{
	// TODO
	// - overwrite or cancel tweens

	public static inline var EASENONE:Int 				= 0; // aka linear
	public static inline var EASEINQUAD:Int 			= 1;
	public static inline var EASEOUTQUAD:Int 			= 2;
	public static inline var EASEINOUTQUAD:Int 			= 3;
	public static inline var EASEINCUBIC:Int 			= 4;
	public static inline var EASEOUTCUBIC:Int 			= 5;
	public static inline var EASEINOUTCUBIC:Int 		= 6;
	public static inline var EASEINQUART:Int 			= 7;
	public static inline var EASEOUTQUART:Int 			= 8;
	public static inline var EASEINOUTQUART:Int 		= 9;
	public static inline var EASEINQUINT:Int 			= 10;
	public static inline var EASEOUTQUINT:Int 			= 11;
	public static inline var EASEINOUTQUINT:Int 		= 12;
	public static inline var EASEINSINE:Int 			= 13;
	public static inline var EASEOUTSINE:Int 			= 14;
	public static inline var EASEINOUTSINE:Int 			= 15;
	public static inline var EASEINEXPO:Int 			= 16;
	public static inline var EASEOUTEXPO:Int 			= 17;
	public static inline var EASEINOUTEXPO:Int 			= 18;
	public static inline var EASEINCIRC:Int 			= 19;
	public static inline var EASEOUTCIRC:Int 			= 20;
	public static inline var EASEINOUTCIRC:Int 			= 21;
	public static inline var EASEINELASTIC:Int 			= 22;
	public static inline var EASEOUTELASTIC:Int 		= 23;
	public static inline var EASEINOUTELASTIC:Int 		= 24;
	public static inline var EASEINBACK:Int 			= 25;
	public static inline var EASEOUTBACK:Int 			= 26;
	public static inline var EASEINOUTBACK:Int 			= 27;
	public static inline var EASEINBOUNCE:Int 			= 28;
	public static inline var EASEOUTBOUNCE:Int 			= 29;
	public static inline var EASEINOUTBOUNCE:Int 		= 30;

	public static var instance:WynTween;
	var queue:Array<TweenData>;



	public static function init ()
	{
		instance = new WynTween();
	}

	public function new ()
	{
		queue = [];
	}

	public function update (dt:Float)
	{
		// reusable variables
		var i = 0;
		var item = null;
		var t,b,c,d,n,val;

		Wyngine.log("queue : " + queue.length);

		while (i < queue.length)
		{
			item = queue[i];

			if (item.paused)
			{
				i++;
				continue;
			}

			// Update elapsed
			item.elapsed += dt;
			if (item.elapsed >= item.duration)
				item.elapsed = item.duration;

			// Notes on why we use "n"
			// http://oodavid.com/2013/11/11/easing-functions-refactored.html
			t = item.elapsed;
			b = item.from;
			c = item.to-item.from;
			d = item.duration;
			n = t/d;
			val = 0.0;

			switch (item.ease)
			{
				case EASEINQUAD: 		val = b + WynMath.easeInQuad (n) * c;
				case EASEOUTQUAD: 		val = b + WynMath.easeOutQuad (n) * c;
				case EASEINOUTQUAD: 	val = b + WynMath.easeInOutQuad (n) * c;
				case EASEINCUBIC: 		val = b + WynMath.easeInCubic (n) * c;
				case EASEOUTCUBIC: 		val = b + WynMath.easeOutCubic (n) * c;
				case EASEINOUTCUBIC: 	val = b + WynMath.easeInOutCubic (n) * c;
				case EASEINQUART: 		val = b + WynMath.easeInQuart (n) * c;
				case EASEOUTQUART: 		val = b + WynMath.easeOutQuart (n) * c;
				case EASEINOUTQUART: 	val = b + WynMath.easeInOutQuart (n) * c;
				case EASEINQUINT: 		val = b + WynMath.easeInQuint (n) * c;
				case EASEOUTQUINT: 		val = b + WynMath.easeOutQuint (n) * c;
				case EASEINOUTQUINT: 	val = b + WynMath.easeInOutQuint (n) * c;
				case EASEINSINE: 		val = b + WynMath.easeInSine (n) * c;
				case EASEOUTSINE: 		val = b + WynMath.easeOutSine (n) * c;
				case EASEINOUTSINE: 	val = b + WynMath.easeInOutSine (n) * c;
				case EASEINEXPO: 		val = b + WynMath.easeInExpo (n) * c;
				case EASEOUTEXPO: 		val = b + WynMath.easeOutExpo (n) * c;
				case EASEINOUTEXPO: 	val = b + WynMath.easeInOutExpo (n) * c;
				case EASEINCIRC: 		val = b + WynMath.easeInCirc (n) * c;
				case EASEOUTCIRC: 		val = b + WynMath.easeOutCirc (n) * c;
				case EASEINOUTCIRC: 	val = b + WynMath.easeInOutCirc (n) * c;
				case EASEINELASTIC: 	val = b + WynMath.easeInElastic (n) * c;
				case EASEOUTELASTIC: 	val = b + WynMath.easeOutElastic (n) * c;
				case EASEINOUTELASTIC: 	val = b + WynMath.easeInOutElastic (n) * c;
				case EASEINBACK: 		val = b + WynMath.easeInBack (n) * c;
				case EASEOUTBACK: 		val = b + WynMath.easeOutBack (n) * c;
				case EASEINOUTBACK: 	val = b + WynMath.easeInOutBack (n) * c;
				case EASEINBOUNCE: 		val = b + WynMath.easeInBounce (n) * c;
				case EASEOUTBOUNCE: 	val = b + WynMath.easeOutBounce (n) * c;
				case EASEINOUTBOUNCE: 	val = b + WynMath.easeInOutBounce (n) * c;
				default: 				val = b + WynMath.linear(n) * c; // linear by default
			}

			// If t=0, then val will become NaN, in which case we
			// assume it reached the target value instantly.
			if (Math.isNaN(val))
				val = item.to;

			Reflect.setProperty(item.target, item.prop, val);

			if (item.elapsed >= item.duration)
				queue.remove(item);
			else
				i++;
		}
	}

	/**
	 * Uses Reflection to tween a parameter in the target WynObject for a duration.
	 * This method only tweens a single property.
	 * This method only tweens from CURRENT value to target value
	 */
	public static function tweenTo (target:Dynamic, property:String, to:Float, duration:Float, ease:Int=0, ?callback:Void->Void)
	{
		// Get the starting value, making sure it's a valid value.
		var from:Dynamic = Reflect.getProperty(target, property);
		if (from == null)
			throw "Property (" + property + ") does not exist";
		if (Math.isNaN(from))
			throw "Property (" + property + ") is not numeric";

		// Save the data
		var data:TweenData = {
			target : target,
			prop : property,
			from : from,
			to : to,
			elapsed : 0,
			duration : duration,
			ease : ease,
			callback : callback,
			paused : false
		};

		// Add to queue
		instance.addToQueue(data);
	}

	public static function tweenFromTo (target:Dynamic, property:String, from:Float, to:Float, duration:Float, ease:Int=0, ?callback:Void->Void)
	{
		// Save the data
		var data:TweenData = {
			target : target,
			prop : property,
			from : from,
			to : to,
			elapsed : 0,
			duration : duration,
			ease : ease,
			callback : callback,
			paused : false
		};

		// Add to queue
		instance.addToQueue(data);
	}

	function addToQueue (data:TweenData)
	{
		var i = 0;
		var item = null;
		while (i < queue.length)
		{
			// If the target/prop pair already exists,
			// overwrite it.
			if (queue[i].target == data.target &&
				queue[i].prop == data.prop)
			{
				queue[i] = data;
				return;
			}
			i++;
		}

		// If we didn't overwrite anything, it means this data
		// is unique, so push to queue.
		queue.push(data);
	}

	public static function pause (target:Dynamic)
	{
		var queue = instance.queue;
		for (i in 0 ... queue.length)
		{
			if (queue[i].target == target)
				queue[i].paused = true;
		}
	}

	public static function resume (target:Dynamic)
	{
		var queue = instance.queue;
		for (i in 0 ... queue.length)
		{
			if (queue[i].target == target)
				queue[i].paused = false;
		}
	}

	/**
	 * Cancels tween on target. if reset is true, then will revert
	 * to original value before tween began.
	 */
	public static function cancel (target:Dynamic, reset:Bool=false)
	{
		var i = 0;
		var queue = instance.queue;
		var item = null;

		while (i < queue.length)
		{
			item = queue[i];
			if (item.target == target)
			{
				if (reset)
					Reflect.setProperty(item.target, item.prop, item.from);

				queue.remove(item);
			}
			else
				i++;
		}
	}
}