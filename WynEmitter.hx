package wyn;

import kha.Image;
import kha.Color;
import kha.math.FastVector2;

class WynEmitter<T:WynParticle> extends WynGroup<T>
{
	var _on:Bool = false;
	var _waitForKill:Bool = false;
	var _emitQuantity:Int = 0;
	var _emitCount:Int = 0;
	var _emitFrequency:Float = 0;
	var _emitElapsed:Float = 0;
	var _emitCounter:Int = 0;
	var _emitLifespan:Float = 0;
	var _elapsed:Float = 0;

	// You can manually set these values to modify
	// the emitter behaviour directly.
	public var _lifespan:Bounds<Float>;
	public var _xPosition:Bounds<Float>;
	public var _yPosition:Bounds<Float>;
	public var _xVelocity:Bounds<Float>;
	public var _yVelocity:Bounds<Float>;
	public var _rotation:Bounds<Float>;
	public var _startScale:Bounds<Float>;
	public var _endScale:Bounds<Float>;
	public var _startAlpha:Bounds<Float>;
	public var _endAlpha:Bounds<Float>;
	public var _particleDrag:FastVector2;
	public var _particleAccel:FastVector2;



	public function new (?x:Int, ?y:Int)
	{
		super(x, y);

		_lifespan = new Bounds<Float>(3, 3);
		_xPosition = new Bounds<Float>(0, 0);
		_yPosition = new Bounds<Float>(0, 0);
		_xVelocity = new Bounds<Float>(-100, 100);
		_yVelocity = new Bounds<Float>(-100, 100);
		_rotation = new Bounds<Float>(-360, 360);
		_startScale = new Bounds<Float>(1.0, 1.0);
		_endScale = new Bounds<Float>(1.0, 1.0);
		_startAlpha = new Bounds<Float>(1.0, 1.0);
		_endAlpha = new Bounds<Float>(0, 0);
		_particleDrag = new FastVector2(0, 0);
		_particleAccel = new FastVector2(0, 0);

		// Start out "dead" by default
		kill();
	}

	/**
	 * Triggers the emitter. Use kill() to stop, use destroy() to remove completely.
	 * NOTE:
	 * - Remember to use add() to add your particles first!
	 * - if countPerEmit is zero, will emit all particles at once
	 * - if frequency is zero, will emit one particle per frame. Otherwise, will emit countPerEmit per frame.
	 * - if quantity is zero, emit indefinitely. Otherwise, emit up to quantity, then kill emitter.
	 * - if lifespan is zero, they never die and get recycled.
	 */
	public function emit (countPerEmit:Int=0, frequency:Float=0, quantity:Int=0, emitLifespan:Float=0)
	{
		// Revive emitter
		revive();

		_emitCount = countPerEmit;
		_emitFrequency = frequency;
		_emitQuantity = quantity;
		_emitLifespan = emitLifespan;

		// Reset the emitter state
		_on = true;
		_waitForKill = false;
		_emitElapsed = 0;
		_elapsed = 0;
		_emitCounter = 0;
	}

	override public function update (dt:Float)
	{
		super.update(dt);

		// If the emitter is on:
		// - if _emitCount is zero, emit ALL particles in one go, then kill emitter
		// - else, emit particles based on _emitFrequency
		// If emitter is off:
		// - wait to kill the emitter
		if (_on)
		{
			// Spawn particles based on _emitCount, or default to emit-all-particles.
			if (_emitCount <= 0)
			{
				// If _emitCount is zero, burst emit ALL particles
				var len:Int = members.length;
				for (i in 0 ... len)
					emitParticle();

				// Flag to kill when we're done
				flagToKill();
			}
			else
			{
				if (_emitFrequency <= 0)
				{
					// If zero frequency, then emit ONE particle EVERY frame until
					// the pool runs out, then flag to kill when done (same as above)
					emitParticle();

					// If there is a quantity to emit, kill once we've emitted enough.
					if (_emitQuantity > 0 && _emitCounter >= _emitQuantity)
						flagToKill();
				}
				else
				{
					// Emit particles
					_emitElapsed += dt;
					while (_emitElapsed >= _emitFrequency)
					{
						for (q in 0 ... _emitCount)
							emitParticle();

						_emitElapsed -= _emitFrequency;
					}

					// If there is a quantity to emit, kill once we've emitted enough.
					if (_emitQuantity > 0 && _emitCounter >= _emitQuantity)
						flagToKill();
				}
			}
		}
		else if (_waitForKill)
		{
			// HaxeFlixel waits for a default of 3 seconds before it kills the emitter.
			_elapsed += dt;
			if (_elapsed >= _emitLifespan)
				kill();
		}
	}

	function flagToKill ()
	{
		_emitCount = 0;
		_on = false;
		_waitForKill = true;
	}

	function emitParticle ()
	{
		// Recycle and revive the particle
		var particle:WynParticle = cast recycle();
		if (particle != null)
		{
			// Reset and randomise stats
			var lifespan = WynUtil.randomFloat(_lifespan.min, _lifespan.max);
			var xPosition = WynUtil.randomFloat(_xPosition.min, _xPosition.max);
			var yPosition = WynUtil.randomFloat(_yPosition.min, _yPosition.max);
			var xVelocity = WynUtil.randomFloat(_xVelocity.min, _xVelocity.max);
			var yVelocity = WynUtil.randomFloat(_yVelocity.min, _yVelocity.max);
			var rotation = WynUtil.randomFloat(_rotation.min, _rotation.max);
			var startScale = WynUtil.randomFloat(_startScale.min, _startScale.max);
			var endScale = WynUtil.randomFloat(_endScale.min, _endScale.max);
			var startAlpha = WynUtil.randomFloat(_startAlpha.min, _startAlpha.max);
			var endAlpha = WynUtil.randomFloat(_endAlpha.min, _endAlpha.max);

			particle.reset();
			particle.lifespan = lifespan;
			particle.setCenterPosition(x + xPosition, y + yPosition);
			particle.velocity = new FastVector2(xVelocity, yVelocity);
			particle.angularVelocity = rotation;

			// Flag if there is a change, otherwise skip
			if (startScale != endScale)
			{
				particle.useScaling = true;
				particle.startScale = startScale;
				particle.endScale = endScale;
			}
			else
			{
				particle.useScaling = false;
				particle.scale = startScale;
			}

			// Flag if there is a change, otherwise skip
			if (startAlpha != endAlpha)
			{
				particle.useFading = true;
				particle.startAlpha = startAlpha;
				particle.endAlpha = endAlpha;
			}
			else
			{
				particle.useFading = false;
				particle.alpha = startAlpha;
			}

			particle.drag = _particleDrag;
			particle.acceleration = _particleAccel;
		}
		else
		{
			trace("Ran out of particles. You may wanna allocate more manually.");
		}

		_emitCounter++;
	}

	override public function render (c:WynCamera)
	{
		super.render(c);
	}

	override public function destroy ()
	{
		super.destroy();
	}

	override public function kill ()
	{
		super.kill();
	}

	override public function revive ()
	{
		super.revive();
	}

	// /**
	//  * Don't use WynGroup's set_x/set_y method, because we don't
	//  * want to affect the position of the child particles.
	//  */
	// override private function set_x (val:Float) : Float
	// {
	// 	if (_xPosition != null)
	// 		_xPosition.min = val;

	// 	return x = val;
	// }
	// override private function set_y (val:Float) : Float
	// {
	// 	if (_yPosition != null)
	// 		_yPosition.min = val;

	// 	return y = val;
	// }
	// override private function set_width (val:Float) : Float
	// {
	// 	if (_xPosition != null)
	// 		_xPosition.max = val;

	// 	return super.set_width(val);
	// }
	// override private function set_height (val:Float) : Float
	// {
	// 	if (_yPosition != null)
	// 		_yPosition.max = val;

	// 	return super.set_height(val);
	// }
}

/**
 * Taken from HaxeFlixel's FlxTypedEmitter
 * Helper object for holding bounds of different variables
 */
class Bounds<T>
{
	public var min:T;
	public var max:T;

	public function new(min:T, ?max:Null<T>)
	{
		set(min, max);
	}
	
	public function set(min:T, ?max:Null<T>):Bounds<T>
	{
		this.min = min;
		this.max = max == null ? min : max;
		return this;
	}
}