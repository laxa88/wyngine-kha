package wy;

import kha.Color;
import kha.Image;
import kha.Loader;
import kha.Rectangle;
import kha.math.FastMatrix3;
import kha.math.FastVector2;
import kha.graphics2.Graphics;

class WyObject
{
	// TODO
	// - keep an master list of raw images
	// - when rotating, draw the latest rotated image based on raw image
	// - if no new rotation, reuse old raw image to save computing time

	// unique ID for each object. Currently unused.
	public static var ID_COUNTER:Int = 0;

	public var _id:Int = -1; // unique id for each object
	public var _exists:Bool; // for WyPool - doesn't appear in-game
	public var _alive:Bool; // for WyPool - exists but can be dead or alive
	public var _active:Bool; // flag for update
	public var _visible:Bool; // flag for render
	public var _position:FastVector2;
	public var _velocity:FastVector2;
	public var _acceleration:FastVector2; // for gravity or car movement
	public var _drag:FastVector2; // for slowing movement
	public var _torque:Float; // rotation velocity
	// public var _offset:FastVector2;
	public var _alpha:Float;
	public var _angle(get,set):Float;
	private var __angle:Float = 0;
	public var _scale:Float;
	public var _hitbox:Rectangle;
	public var _image:Image;
	public var _color:Color;
	public var _animator:WyAnimator;
	var _rightDirection:Float;
	var _face:Float;
	public var _direction(get,set):Int;

	var _frameColumns:Int;
	var _frameX:Int;
	var _frameY:Int;
	var _frameW:Int;
	var _frameH:Int;

	var _cx:Float;
	var _cy:Float;
	var _cw:Float;
	var _ch:Float;
	var _hit:Bool; // for debug only



	public function new (x:Float=0, y:Float=0)
	{
		_id = ++ID_COUNTER;

		init();

		_position.x = x;
		_position.y = y;
	}

	public function init ()
	{
		// This method is usually called for object pooling

		_exists = true;
		_alive = true;
		_active = true;
		_visible = true;
		_position = new FastVector2();
		_velocity = new FastVector2();
		_acceleration = new FastVector2();
		_drag = new FastVector2();
		_torque = 0.0;
		// _offset = new FastVector2();
		_alpha = 1.0;
		_angle = 0.0;
		_scale = 1.0;
		_hitbox = new Rectangle(0.0, 0.0, 0.0, 0.0);
		_image = null;
		_color = Color.White;
		_animator = new WyAnimator(this);
		_rightDirection = 0.0;
		_face = 0.0;
		_direction = 0;

		_frameColumns = 1; // there should at least be one column if an image exists
		_frameX = 0;
		_frameY = 0;
		_frameW = 0;
		_frameH = 0;
		_cx = 0;
		_cy = 0;
		_cw = 0;
		_ch = 0;
		_hit = false;

		setDefaultFacingRight(true); // default to right
	}

	public function update (dt:Float)
	{
		// TODO - set max velocity

		if (!_active)
			return;

		// update physics and final position
		_velocity.x = WyUtil.computeVelocity(dt, _velocity.x, _acceleration.x, _drag.x, 0);
		_velocity.y = WyUtil.computeVelocity(dt, _velocity.y, _acceleration.y, _drag.y, 0);
		//_velocity.x += dt * _acceleration.x;
		//_velocity.y += dt * _acceleration.y;
		_position.x += dt * _velocity.x;
		_position.y += dt * _velocity.y;

		// apply rotation
		if (_torque != 0)
			_angle += dt * _torque;

		// update hitbox position
		updateHitboxPos();

		// update animation
		_animator.update(dt);

		// update frame index
		var sheetIndex:Int = _animator.getSheetIndex();
		_frameX = (sheetIndex % _frameColumns) * _frameW;
		_frameY = Std.int(sheetIndex / _frameColumns) * _frameH;

		//Wy.log("# frame : " + sheetIndex);
	}

	public function render (g:Graphics)
	{
		if (Wy.DEBUG)
		{
			// Debug image box
			g.color = Color.Green;
			g.drawRect(_position.x, _position.y, _frameW, _frameH);
		}

		if (_image != null && _visible)
		{
			g.color = _color;
			var dx:Float = (_face < 0) ? _frameW * _scale : 0;

			// Draw the rotated image, if any
			if (_angle != 0)
			{
				var rad = WyUtil.degToRad(_angle);
				g.pushTransformation(g.transformation
					// offset toward top-left
					.multmat(FastMatrix3.translation(_position.x + _frameW/2, _position.y + _frameH/2))
					// rotate at offset pivot point
					.multmat(FastMatrix3.rotation(rad))
					// reverse offset
					.multmat(FastMatrix3.translation(-_position.x - _frameW/2, -_position.y - _frameH/2)));
			}

			// Add opacity if any
			//if (_alpha != 1) g.pushOpacity(_alpha);
			g.pushOpacity(_alpha);

			// Draw the actual image, scaled if required
			g.drawScaledSubImage(_image, _frameX, _frameY, _frameW, _frameH, 
				_position.x + dx+(_frameW/2) - (_frameW*_scale/2), 
				_position.y + (_frameH/2) - (_frameH*_scale/2), 
				_frameW * _face * _scale, 
				_frameH * _scale);

			// Finalise opacity
			//if (_alpha != 1) g.popOpacity();
			g.popOpacity();

			// Finalise the rotation
			if (_angle != 0) g.popTransformation();
		}

		if (Wy.DEBUG)
		{
			// Debug hitbox
			g.color = Color.Red;
			g.drawRect(_hitbox.x, _hitbox.y, _hitbox.width, _hitbox.height);
		}
	}

	/**
	* Kills this object
	* Note: manually set _alive to false to ensure
	* the object can exist while being marked "dead",
	* for game purposes. E.g. Check all existing enemies
	* that are "dead" within the room.
	*/
	public function kill ()
	{
		// for WyPool.
		_exists = false;
		_alive = false;
	}

	public function revive ()
	{
		_exists = true;
		_alive = true;
	}

	public function destroy ()
	{
		_hitbox = null;
		_animator.destroy();
		_animator = null;
	}

	/**
	* TODO quad tree to solve 1-to-1, 1-to-many, and many-to-many collisions
	*/
	public function collide (other:WyObject, ?callback:Dynamic->Dynamic->Void) : Bool
	{
		if (!_active || !_alive)
			return false;

		if (!other._active || !other._alive)
			return false;

		if (_hitbox.collision(other._hitbox))
		{
			if (callback != null)
				callback(this, other);

			_hit = true;
		}
		else
		{
			_hit = false;
		}

		return _hit;
	}

	public function setPlaceholderImage (color:Color, frameW:Int=50, frameH:Int=50)
	{
		_frameColumns = 1;
		_frameX = 0;
		_frameY = 0;
		_frameW = frameW;
		_frameH = frameH;

		// draw a filled rectangle as placeholder
		_image = Image.createRenderTarget(_frameW, _frameH);
		_image.g2.begin(true, Color.fromValue(0x00000000));
		_image.g2.color = color;
		_image.g2.fillRect(0, 0, frameW, frameH);
		// _image.g2.color = Color.fromValue(0xff00ff00);
		// kha.graphics2.GraphicsExtension.fillCircle(_image.g2, frameW/2, frameH/2, frameW/2);
		//_image.g2.fillRect(0, 0, frameW, frameH);
		_image.g2.end();
	}

	public function setImage (name:String, frameW:Int=0, frameH:Int=0)
	{
		setDefaultFacingRight(true);

		// Image name is set from project.kha
		_image = Loader.the.getImage(name);

		// e.g. _image.width = 128, frameWidth = 32, so _frameColumns = 4
		_frameColumns = Std.int(_image.width / frameW);
		_frameX = 0;
		_frameY = 0;
		_frameW = frameW;
		_frameH = frameH;
	}

	public function setHitbox (?cx:Float, ?cy:Float, cw:Float, ch:Float)
	{
		// NOTE: these are LOCAL values.
		// They need to be added to _position.
		if (cx != null)
			_cx = cx;
		if (cy != null)
			_cy = cy;
		_cw = cw;
		_ch = ch;

		updateHitboxPos();
	}

	function updateHitboxPos ()
	{
		_hitbox.x = _position.x + _cx;// + _offset.x;
		_hitbox.y = _position.y + _cy;// + _offset.y;
		_hitbox.width = _cw;
		_hitbox.height = _ch;
	}

	public function setDefaultFacingRight (isRight:Bool)
	{
		// If current sprite is facing right, then isRight is true,
		// thus _rightDirection will default to +1.0
		// If current sprite is facing left, then isRight is false,
		// thus _rightDirection will default to -1.0

		_rightDirection = (isRight) ? 1.0 : -1.0;
		
		_direction = 1;
	}

	public function setPosition (x:Float, y:Float)
	{
		_position.x = x;
		_hitbox.x = _position.x + _cx;// + _offset.x;

		_position.y = y;
		_hitbox.y = _position.y + _cy;// + _offset.y;

		updateHitboxPos();
	}

	/**
	* Position by default is at TOP-LEFT, so this sets the
	* object and offsets to the center instead.
	*/
	public function setCenterPos (x:Float, y:Float)
	{
		_position.x = x - _frameW/2;
		_position.y = y - _frameH/2;

		updateHitboxPos();
	}

	/**
	* Position by default is at TOP-LEFT, so this returns the
	* center of the object for other cases.
	*/
	public function getCenterPos ():FastVector2
	{
		return new FastVector2(_position.x+_frameW/2, _position.y+_frameH/2);
	}



	private inline function get__angle():Float
	{
		return __angle;
	}
	private inline function set__angle(val:Float):Float
	{
		__angle = val;
		if (__angle < 0)
			__angle += 360;
		if (__angle >= 360)
			__angle -= 360;
		return __angle;
	}
	private inline function get__direction():Int
	{
		return Std.int(_face);
	}
	private inline function set__direction(val:Int):Int
	{
		if (val > 0)
			_face = _rightDirection;
		else
			_face = -_rightDirection;

		return Std.int(_face);
	}
}