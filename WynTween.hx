package wyn;

// typedef TweenData = {
// 	var target:WynObject;
// 	var prop:String;
// 	var from:Float;
// 	var to:Float;
// 	var elapsed:Float;
// 	var duration:Float;
// 	var callback:Void->Void;
// 	var ease:Int;
// 	var paused:Bool;
// }

typedef TweenData = {
	var target:Dynamic;
	var props:Dynamic;
	var elapsed:Float;
	var duration:Float;
	var ease:Int;
	var callback:Void->Void;
	var paused:Bool;
}

typedef PropData = {
	@:optional var from:Float;
	@:optional var to:Float;
}

class WynTween
{
	// props example:
	//  - var props = { x: { to:50 }, y: { from:100, to:200 } }
	// Priority:
	// 	- If mode is "PLAYDEFAULT", will use current value as start value if "from" isn't provided
	// 	- If mode is "PLAYRESET", will rest "from" 
	// 	- If mode is "PLAYSKIP", will use "from" and "to" values whenever available.
	//

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

	public static inline var PLAYDEFAULT:Int = 0; // tweens from current value
	public static inline var PLAYRESET:Int = 1; // if current item is being tweened, resets to original "from" value before tweening
	public static inline var PLAYSKIP:Int = 2; // if current item is being tweened, jumps to "to" value before tweening

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

	public function update ()
	{
		// reusable variables
		var i = 0;
		var tween = null;
		var t,b,c,d,n,val;

		while (i < queue.length)
		{
			// Get tween data
			tween = queue[i];

			// Don't update if tween is paused
			if (tween.paused)
			{
				i++;
				continue;
			}

			// Update elapsed
			tween.elapsed += Wyngine.dt;
			if (tween.elapsed >= tween.duration)
				tween.elapsed = tween.duration;

			// Notes on why we use "n"
			// http://oodavid.com/2013/11/11/easing-functions-refactored.html
			t = tween.elapsed;
			b = 0;
			c = 0;
			d = tween.duration;
			n = t/d;
			val = 0.0;

			// For this tween target, update each of its properties
			var fields:Array<String> = Reflect.fields(tween.props);
			for (field in fields)
			{
				var data = Reflect.getProperty(tween.props, field);
				b = data.from;
				c = data.to - data.from;

				switch (tween.ease)
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

				// Update the value
				// If t=0, then val will become NaN, in which case we
				// assume it reached the target value instantly.
				if (Math.isNaN(val))
					val = data.to;

				Reflect.setProperty(tween.target, field, val);
			}

			if (tween.elapsed >= tween.duration)
			{
				if (tween.callback != null)
					tween.callback();

				queue.remove(tween);
			}
			else
				i++;
		}
	}

	/**
	 * Uses Reflection to tween a parameter in the target WynObject for a duration.
	 * This method only tweens a single property.
	 * This method only tweens from CURRENT value to target value
	 */
	public static function tween (target:Dynamic, props:Dynamic, duration:Float=1, ease:Int=EASENONE, playbackMode:Int=PLAYDEFAULT, ?callback:Void->Void)
	{
		// Make sure the tween is valid
		if (target == null)
			throw "Cannot tween null target.";
		else if (props == null)
			throw "Cannot tween null props.";

		// Save the tween data
		var data:TweenData = {
			target : target,
			props : props,
			elapsed : 0,
			duration : duration,
			ease : ease,
			callback : callback,
			paused : false
		};

		// Add (or replace) data into tween queue
		instance.addToQueue(data, playbackMode);
	}

	function addToQueue (data:TweenData, playbackMode:Int)
	{
		var len = queue.length;
		for (i in 0 ... len)
		{
			// If the target already has a tween, based on playbackMode,
			// we update the tween data accordingly.
			if (data.target == queue[i].target)
			{
				// For each property, Update the "from" value to current value
				var queueData = queue[i];

				// Update data
				queueData.elapsed = 0;
				queueData.duration = data.duration;
				queueData.ease = data.ease;
				queueData.callback = data.callback;
				queueData.paused = false;

				// Update tween properties for this target
				var queueFields:Array<String> = Reflect.fields(queueData.props);
				for (field in queueFields)
				{
					// e.g. field = "x", "width", etc.

					var prevFieldProps:PropData = Reflect.getProperty(queueData.props, field);
					var currFieldProps:PropData = Reflect.getProperty(data.props, field);

					if (currFieldProps.from == null)
					{
						switch (playbackMode)
						{
							case PLAYDEFAULT:
								currFieldProps.from = Reflect.getProperty(data.target, field);

							case PLAYRESET:
								currFieldProps.from = prevFieldProps.from;

							case PLAYSKIP:
								currFieldProps.from = prevFieldProps.to;
						}
					}

					// Set the {from, to} values to field of prop, e.g. "x", "width"...
					Reflect.setProperty(queueData.props, field, currFieldProps);
				}

				// For every field that we've updated "from" and "to", update the queue data
				queue[i] = queueData;

				// Once we updated the tween data, no need to do further checks
				return;
			}
		}

		// If target doesn't have tween, just add to queue normally
		var dataFields:Array<String> = Reflect.fields(data.props);
		for (field in dataFields)
		{
			// Make sure there is a "from" value
			var propData = Reflect.getProperty(data.props, field); // e.g. "x"
			if (propData.from == null)
				propData.from = Reflect.getProperty(data.target, field);
		}
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
	public static function cancel (target:Dynamic, resetType:Int=PLAYDEFAULT)
	{
		var i = 0;
		var queue = instance.queue;
		var data = null;

		while (i < queue.length)
		{
			data = queue[i];

			// If the target has a tween...
			if (data.target == target)
			{
				// Note: PLAYDEFAULT means the tween is abruptly cancelled
				// without resetting the current field values. If it's not
				// default, then we reset by PLAYRESET or PLAYSKIP type.
				if (resetType != PLAYDEFAULT)
				{
					var dataFields:Array<String> = Reflect.fields(data.props);
					for (field in dataFields)
					{
						// Reset the field to "from" value
						var propData = Reflect.getProperty(data.props, field); // e.g. "x"

						// propData
						if (resetType == PLAYRESET)
							Reflect.setProperty(data.target, field, propData.from);
						else if (resetType == PLAYSKIP)
							Reflect.setProperty(data.target, field, propData.to);
					}
				}

				queue.remove(data);
			}
			else
				i++;
		}
	}

	/**
	 * Clears all tweens. Useful when resetting the game.
	 */
	public static function clear ()
	{
		instance.queue = [];
	}
}