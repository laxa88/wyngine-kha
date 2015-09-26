package wy;

import kha.Color;
import kha.Image;
import kha.Loader;
import kha.Rectangle;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;
import kha.graphics2.GraphicsExtension;

enum WyDirection
{
	NONE;
	LEFT;
	RIGHT;
	UP;
	DOWN;
}

class WySprite
{
	// TODO
	// - use origin instead of top-left all the time
	// - set kill/revive
	// - set callback for kill/revive
	// - scale image
	// - rotate image
	// - stress performance test
	// - extend from WyObject

	// TODO advance
	// - scale collider along with image
	// - circle collider
	// - box/circle collider logic
	// - pixel perfect collider



	// unique ID for each object. Currently unused.
	public static var ID_COUNTER:Int = 0;

	private var _image:Image;
	private var _animator:WyAnimator;
	private var _collider:Rectangle;
	//private var _debugCollider:Rectangle;
	private var _rightDirection:Float;
	private var _face:Float;

	private var _id:Int = -1; // unique id for each object
	//private var _active:Bool = true;
	private var _visible:Bool = true;
	private var _x:Float = 0.0;
	private var _y:Float = 0.0;
	private var _z:Int = 0;
	//private var _speedX:Float = 0.0;
	//private var _speedY:Float = 0.0;
	//private var _maxSpeedX:Float = 0.0;
	//private var _maxSpeedY:Float = 0.0;
	private var _angle:Float = 0.0;
	private var _alpha:Float = 1.0;
	private var _scale:Float = 1.0;
	private var _w:Float = 0.0;
	private var _h:Float = 0.0;
	private var _oX:Float = 0.0;
	private var _oY:Float = 0.0;
	//private var _originX:Float = 0.0;
	//private var _originY:Float = 0.0;
	//private var _scaleX:Float = 1.0;
	//private var _scaleY:Float = 1.0;
	//private var _flipX:Bool = false;
	//private var _flipY:Bool = false;

	// for collider
	private var _cx:Float = 0.0;
	private var _cy:Float = 0.0;
	private var _cw:Float = 0.0;
	private var _ch:Float = 0.0;
	private var _hit:Bool = false;

	// for spritesheets and animations
	private var _frameColumns:Int = 0;
	private var _frameX:Int = 0;
	private var _frameY:Int = 0;
	private var _frameW:Int = 0;
	private var _frameH:Int = 0;



	public var image(get,set):Image;
	private inline function get_image():Image { return _image; }
	private inline function set_image(val:Image):Image { _image = val; return _image; }
	public var animator(get,set):WyAnimator;
	private inline function get_animator():WyAnimator { return _animator; }
	private inline function set_animator(val:WyAnimator):WyAnimator { _animator = val; return _animator; }
	public var collider(get,set):Rectangle;
	private inline function get_collider():Rectangle { return _collider; }
	private inline function set_collider(val:Rectangle):Rectangle { _collider = val; return _collider; }
	public var direction(get,set):Int;
	private inline function get_direction():Int { return Std.int(_face); }
	private inline function set_direction(val:Int):Int { if (val > 0) {_face = _rightDirection;} else {_face = -_rightDirection;} return Std.int(_face); }
	public var id(get,set):Int;
	private inline function get_id():Int { return _id; }
	private inline function set_id(val:Int):Int { _id = val; return _id; }
	public var visible(get,set):Bool;
	private inline function get_visible():Bool { return _visible; }
	private inline function set_visible(val:Bool):Bool { _visible = val; return _visible; }
	public var x(get,set):Float;
	private inline function get_x():Float { return _x; }
	private inline function set_x(val:Float):Float { _x = val; return _x; }
	public var y(get,set):Float;
	private inline function get_y():Float { return _y; }
	private inline function set_y(val:Float):Float { _y = val; return _y; }
	public var z(get,set):Int;
	private inline function get_z():Int { return _z; }
	private inline function set_z(val:Int):Int { _z = val; return _z; }
	public var angle(get,set):Float;
	private inline function get_angle():Float { return _angle; }
	private inline function set_angle(val:Float):Float { _angle += val; if (_angle >= 360) {_angle -= 360;} if (_angle < 0) {_angle += 360;} return _angle; }
	public var alpha(get,set):Float;
	private inline function get_alpha():Float { return _alpha; }
	private inline function set_alpha(val:Float):Float { _alpha = val; return _alpha; }
	public var scale(get,set):Float;
	private inline function get_scale():Float { return _scale; }
	private inline function set_scale(val:Float):Float { _scale = val; return _scale; }
	public var w(get,set):Float;
	private inline function get_w():Float { return _w; }
	private inline function set_w(val:Float):Float { _w = val; return _w; }
	public var h(get,set):Float;
	private inline function get_h():Float { return _h; }
	private inline function set_h(val:Float):Float { _h = val; return _h; }






	public function new (x:Int=0, y:Int=0, ?z:Int)
	{
		// NOTE:
		// - w and h is the image size
		// - collision box is independent of image size
		// - on new(), collision boxes is same as image size
		_id = ++ID_COUNTER;
		_x = x;
		_y = y;
		_z = (z==null) ? _id : 0;
		_collider = new Rectangle(0,0,0,0);
		//_debugCollider = new Rectangle(0,0,0,0);
		_animator = new WyAnimator(this);

		Wy.log("New sprite : " + _id);

		init();
	}
	public function init ()
	{
	}
	public function destroy ()
	{
		_image = null;
		_animator = null;
		_collider = null;
		//_debugCollider = null;
	}
	public function update (elapsed:Float)
	{
		// update animator
		_animator.update(elapsed);

		// update collider position
		updateCollider();

		// update frame index
		var frameIndex:Int = _animator.getFrameIndex();
		_frameX = (frameIndex % _frameColumns) * _frameW;
		_frameY = Std.int(frameIndex / _frameColumns) * _frameH;
	}
	public function render (g:Graphics)
	{
		// Draw the image
		g.color = Color.White;
		if (_image != null && _visible)
		{
			// TODO
			// - set collider origin point
			// - set image origin point

			var dx:Float = (_face < 0) ? _frameW*_scale : 0;
			if (_angle != 0)
			{
				var rad = WyUtil.degToRad(_angle);
				g.pushTransformation(g.transformation.multmat(FastMatrix3.translation(_x + _frameW/2, _y + _frameH/2)).multmat(FastMatrix3.rotation(rad)).multmat(FastMatrix3.translation(-_x - _frameW/2, -_y - _frameH/2)));
			}
			g.pushOpacity(_alpha);
			g.drawScaledSubImage(_image, _frameX, _frameY, _frameW, _frameH, _x+dx+(_frameW/2)-(_frameW*_scale/2), _y+(_frameH/2)-(_frameH*_scale/2), _frameW * _face * _scale, _frameH * _scale);
			g.popOpacity();
			if (_angle != 0) g.popTransformation();
		}

		if (false)
		{
			// Debug image box
			g.color = Color.fromBytes(0, 255, 0);
			g.drawRect(_x, _y, _frameW, _frameH);

			// Debug collider box
			if (_hit)
				g.color = Color.fromBytes(0, 255, 0);
			else
				g.color = Color.fromBytes(255, 0, 0);
			g.drawRect(_collider.x, _collider.y, _collider.width, _collider.height);

			//GraphicsExtension.drawCircle(g, _x, _y, 20);
		}
	}






	public function loadImage (name:String, animated:Bool=false, frameWidth:Int=0, frameHeight:Int=0)
	{
		// Image name is set from project.kha
		_image = Loader.the.getImage(name);

		// e.g. _image.width = 128, frameWidth = 32, so _frameColumns = 4
		_frameColumns = Std.int(_image.width / frameWidth);
		_frameX = 0;
		_frameY = 0;
		_frameW = frameWidth;
		_frameH = frameHeight;
	}
	public function setDefaultFacingRight (isRight:Bool)
	{
		// If current sprite is facing right, then isRight is true,
		// thus _rightDirection will default to +1.0
		// If current sprite is facing left, then isRight is false,
		// thus _rightDirection will default to -1.0

		_rightDirection = (isRight) ? 1.0 : -1.0;
		_face = _rightDirection;
	}
	public function setCollider (?cx:Float, ?cy:Float, cw:Float, ch:Float)
	{
		if (cx != null)
			_cx = cx;
		if (cy != null)
			_cy = cy;
		_cw = cw;
		_ch = ch;

		updateCollider();
	}
	public function collide (other:WySprite)
	{
		if (_collider.collision(other.collider))
		{
			_hit = true;
			onCollide(other);
		}
		else
		{
			_hit = false;
		}
	}
	function updateCollider ()
	{
		_collider.x = _x + _cx;
		_collider.y = _y + _cy;
		_collider.width = _cw;
		_collider.height = _ch;
	}
	function onCollide (other:WySprite)
	{

		Wy.log("collide : " + _id + " > " + other.id);
	}
}