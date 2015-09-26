package wy;

import kha.Color;
import kha.Image;
import kha.Loader;
import kha.Rectangle;
import kha.math.FastMatrix3;
import kha.math.FastVector2;
import kha.graphics2.Graphics;
import kha.graphics2.GraphicsExtension;

class WySprite extends WyObject
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



	public var _image:Image;
	public var _animator:WyAnimator;
	private var _rightDirection:Float;
	private var _face:Float = 1;
	public var _direction(get,set):Int;
	private inline function get__direction():Int { return Std.int(_face); }
	private inline function set__direction(val:Int):Int { if (val > 0) {_face = _rightDirection;} else {_face = -_rightDirection;} return Std.int(_face); }
	//private var _active:Bool = true;
	public var _velocity:FastVector2; // used for updating actual position
	public var _acceleration:FastVector2; // used to modify velocity (e.g gravity)
	//private var _originX:Float = 0.0;
	//private var _originY:Float = 0.0;
	//private var _flipX:Bool = false;
	//private var _flipY:Bool = false;
	// for spritesheets and animations
	private var _animated:Bool = false;
	private var _frameColumns:Int = 0;
	private var _frameX:Int = 0;
	private var _frameY:Int = 0;
	private var _frameW:Int = 0;
	private var _frameH:Int = 0;






	public override function new (x:Float=0, y:Float=0, ?z:Int)
	{
		super(x,y,z);

		// NOTE:
		// - w and h is the image size
		// - collision box is independent of image size
		// - on new(), collision boxes is same as image size

		_animator = new WyAnimator(this);
		_velocity = new FastVector2();
		_acceleration = new FastVector2();
	}
	public override function destroy ()
	{
		super.destroy();

		_image = null;
		_animator = null;
		_collider = null;
	}
	public override function update (elapsed:Float)
	{
		super.update(elapsed);

		// update physics
		_velocity.x += elapsed * _acceleration.x;
		_velocity.y += elapsed * _acceleration.y;
		_x += elapsed * _velocity.x;
		_y += elapsed * _velocity.y;

		// update collider position
		updateCollider();

		// update animator
		if (_animated)
		{
			_animator.update(elapsed);

			// update frame index
			var frameIndex:Int = _animator.getFrameIndex();
			_frameX = (frameIndex % _frameColumns) * _frameW;
			_frameY = Std.int(frameIndex / _frameColumns) * _frameH;
		}
	}
	public override function render (g:Graphics)
	{
		super.render(g);

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

			if (false)
			{
				// Debug image box
				g.color = Color.fromBytes(0, 255, 0);
				g.drawRect(_x, _y, _frameW, _frameH);
			}
		}
	}






	public function loadImage (name:String, animated:Bool=false, frameWidth:Int=0, frameHeight:Int=0)
	{
		_animated = animated;
		setDefaultFacingRight(true);

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
		_direction = 1;
	}
}