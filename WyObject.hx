package wy;

import kha.Color;
import kha.Rectangle;
import kha.graphics2.Graphics;

class WyObject
{
	// unique ID for each object. Currently unused.
	public static var ID_COUNTER:Int = 0;

	public var _id:Int = -1; // unique id for each object
	public var _active:Bool;
	public var _visible:Bool = true;
	public var _x:Float = 0.0;
	public var _y:Float = 0.0;
	public var _z:Int = 0;
	private var angle:Float = 0.0;
	public var _angle(get,set):Float;
	private inline function get__angle():Float { return angle; }
	private inline function set__angle(val:Float):Float { angle += val; if (angle >= 360) {angle -= 360;} if (angle < 0) {angle += 360;} return angle; }
	public var _alpha:Float = 1.0;
	public var _scale:Float = 1.0;
	//private var _scaleX:Float = 1.0;
	//private var _scaleY:Float = 1.0;
	// for collider
	private var _collider:Rectangle;
	private var _cx:Float = 0.0;
	private var _cy:Float = 0.0;
	private var _cw:Float = 0.0;
	private var _ch:Float = 0.0;
	private var _hit:Bool = false;



	public function new (x:Float=0, y:Float=0, ?z:Int):Void
	{
		_id = ++ID_COUNTER;
		_x = x;
		_y = y;
		_z = (z==null) ? _id : 0;
		_collider = new Rectangle(0,0,0,0);
		//Wy.log("# New object : " + _id);
	}
	public function destroy ():Void {}
	public function update (elapsed:Float):Void {}
	public function render (g:Graphics):Void
	{
		if (false)
		{
			// Debug collider box
			if (_hit)
				g.color = Color.fromBytes(0, 255, 0);
			else
				g.color = Color.fromBytes(255, 0, 0);
			g.drawRect(_collider.x, _collider.y, _collider.width, _collider.height);

			//GraphicsExtension.drawCircle(g, _x, _y, 20);
		}
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
	public function collide (other:WyObject)
	{
		if (_collider.collision(other._collider))
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
	function onCollide (other:WyObject)
	{
		//Wy.log("collide : " + _id + " > " + other._id);
	}
}