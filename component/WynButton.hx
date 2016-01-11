package wyn.component;

import kha.Image;
import kha.graphics2.Graphics;
import kha.math.FastMatrix3;
import wyn.Wyngine;
import wyn.manager.WynMouse;
import wyn.manager.WynTouch;
import wyn.manager.TouchData;
import wyn.manager.TouchState;
import wyn.util.WynUtil;

class WynButton extends WynComponent
{
	public static var DEBUG:Bool = false;

	static var MOUSE_ENABLED:Bool = false;
	static var SURFACE_ENABLED:Bool = false;

	public static inline var STATE_NONE:Int = 0;
	public static inline var STATE_UP:Int = 1;
	public static inline var STATE_OVER:Int = 2;
	public static inline var STATE_DOWN:Int = 3;
	public var currState:Int = STATE_NONE;
	public var prevState:Int = STATE_NONE;

	public var image:Image;
	public var region:Region;
	public var regionDataUp:Region;
	public var regionDataOver:Region;
	public var regionDataDown:Region;
	public var width:Int = 0;
	public var height:Int = 0;
	public var alpha:Float = 1;
	public var angle:Float = 0; // 0 ~ 360
	public var scale:Float = 1;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	var hitTouches:Map<Int, TouchData>;
	var hitMouse:Bool = false;

	var downListeners:Array<WynButton->Void> = [];
	var upListeners:Array<WynButton->Void> = [];
	var enterListeners:Array<WynButton->Void> = [];
	var exitListeners:Array<WynButton->Void> = [];



	public function new (w:Int, h:Int)
	{
		super();

		width = w;
		height = h;

		hitTouches = new Map<Int, TouchData>();

		// Make sure mouse position is scaled for button
		Wyngine.refreshGameScale();
	}

	override public function init ()
	{
		parent.addRenderer(render);

		setState(STATE_UP);
	}

	override public function update ()
	{
		if (!active)
			return;

		if (WynMouse.init)
		{
			updateMouse();
		}
		else if (WynTouch.init)
		{
			updateTouch();
		}
	}

	inline function updateMouse ()
	{
		var state = STATE_UP;
		var hitHoriz = false;
		var hitVert = false;

		if (WynMouse.x > parent.x + offsetX) hitHoriz = (WynMouse.x < parent.x + offsetX + width);
		if (WynMouse.y > parent.y + offsetY) hitVert = (WynMouse.y < parent.y + offsetY + height);
		
		if (hitHoriz && hitVert)
		{
			state = STATE_OVER;

			if (!hitMouse)
			{
				for (listener in enterListeners)
					listener(this);

				hitMouse = true;
			}

			if (WynMouse.isDown())
			{
				for (listener in downListeners)
					listener(this);

				state = STATE_DOWN;
			}

			if (WynMouse.isHeld())
			{
				state = STATE_DOWN;
			}
			
			if (WynMouse.isUp())
			{
				for (listener in upListeners)
					listener(this);
			}
		}
		else
		{
			if (hitMouse)
			{
				for (listener in exitListeners)
					listener(this);

				hitMouse = false;
			}
		}

		// finalise the state
		setState(state);
	}

	inline function updateTouch ()
	{
		var state = STATE_UP;
		var hitHoriz = false;
		var hitVert = false;

		for (key in WynTouch.touches.keys())
		{
			var data = WynTouch.touches[key];

			// For each touch, check if it's within the button area
			if (data.x > parent.x + offsetX) hitHoriz = (data.x < parent.x + offsetX + width);
			if (data.y > parent.y + offsetY) hitVert = (data.y < parent.y + offsetY + height);

			// As long as any new touch hits a button, it cancels out
			// other states such as OVER and UP
			if (hitHoriz && hitVert)
			{
				if (!hitTouches.exists(key))
				{
					// If the touch doesn't exist, then this is the first
					// time the touch enters the button (either thru tapping
					// or dragging a finger into the button area).
					for (listener in enterListeners)
						listener(this);
				}

				hitTouches.set(key, data);

				// NOTE: Remember, there is no OVER state
				// for buttons when using touch.
				state = STATE_DOWN;
			}
			else
			{
				if (hitTouches.exists(key))
				{
					hitTouches.remove(key);

					// For every touch that previously existed but now
					// isn't hitting the button, call the exit listener.
					for (listener in exitListeners)
						listener(this);
				}
			}

			hitHoriz = false;
			hitVert = false;
		}

		for (key in hitTouches.keys())
		{
			var data = hitTouches[key];

			if (data.state == TouchState.DOWN)
			{
				for (listener in downListeners)
					listener(this);
			}
			else if (data.state == TouchState.UP)
			{
				for (listener in upListeners)
					listener(this);
			}
		}

		// finalise the state
		setState(state);
	}

	override public function destroy ()
	{
		super.destroy();

		denotify();

		parent.removeRenderer(render);

		image = null;
		region = null;
		regionDataUp = null;
		regionDataOver = null;
		regionDataDown = null;
	}



	public function render (g:Graphics)
	{
		if (!visible)
			return;

		if (image == null || region == null)
			return;

		if (angle != 0)
		{
			var ox = parent.x - (parent.screen.scrollX - parent.screen.shakeX) * parent.scrollFactorX + offsetX;
			var oy = parent.y - (parent.screen.scrollY - parent.screen.shakeY) * parent.scrollFactorY + offsetY;

			var rad = WynUtil.degToRad(angle);
				g.pushTransformation(g.transformation
					// offset toward top-left, to center image on pivot point
					.multmat(FastMatrix3.translation(ox + scale*width/2, oy + scale*height/2))
					// rotate at pivot point
					.multmat(FastMatrix3.rotation(rad))
					// reverse offset
					.multmat(FastMatrix3.translation(-ox - scale*width/2, -oy - scale*height/2)));
		}

		// Add opacity if any
		if (alpha != 1) g.pushOpacity(alpha);

		g.drawScaledSubImage(image,
			region.x, region.y,
			region.w, region.h,
			parent.x + offsetX, parent.y + offsetY,
			width, height);

		// Finalise opacity
		if (alpha != 1) g.popOpacity();

		// Finalise the rotation
		if (angle != 0) g.popTransformation();

		// if (DEBUG)
		// {
		// 	g.color = 0xFFFF0000;
		// 	g.drawRect(parent.x, parent.y, width, height);
		// 	g.color = 0xFFFFFFFF;
		// }
	}

	inline public function setImage (img:Image, upData:Region, overData:Region, downData:Region)
	{
		image = img;

		regionDataUp = upData;
		regionDataOver = overData;
		regionDataDown = downData;

		setState(STATE_UP);
	}

	inline public function setOffset (ox:Float, oy:Float)
	{
		offsetX = ox;
		offsetY = oy;
	}

	function setState (state:Int)
	{
		// don't update if inactive
		if (!active)
			return;

		// don't repeatedly reassign state
		if (currState == state)
			return;

		prevState = currState;
		currState = state;

		// Default up state
		var regionData:Region = regionDataUp;

		switch (currState)
		{
			case STATE_NONE: regionData = regionDataUp;

			case STATE_UP: regionData = regionDataUp;

			case STATE_OVER: regionData = regionDataOver;

			case STATE_DOWN: regionData = regionDataDown;
		}

		// For invisible buttons, we fallback on empty data
		if (regionData == null)
			regionData = { x:0, y:0, w:0, h:0 };

		// update region
		region = regionData;
	}

	inline public function notify (onDown:WynButton->Void, onUp:WynButton->Void, onEnter:WynButton->Void, onExit:WynButton->Void)
	{
		notifyDown(onDown);
		notifyUp(onUp);
		notifyEnter(onEnter);
		notifyExit(onExit);
	}

	inline public function denotify ()
	{
		while (downListeners.length > 0)
			downListeners.pop();

		while (upListeners.length > 0)
			upListeners.pop();

		while (enterListeners.length > 0)
			enterListeners.pop();

		while (exitListeners.length > 0)
			exitListeners.pop();
	}

	inline public function notifyDown (func:WynButton->Void)
	{
		if (func == null)
			return;

		if (downListeners.indexOf(func) == -1)
			downListeners.push(func);
	}

	inline public function notifyUp (func:WynButton->Void)
	{
		if (func == null)
			return;

		if (upListeners.indexOf(func) == -1)
			upListeners.push(func);
	}

	inline public function notifyEnter (func:WynButton->Void)
	{
		if (func == null)
			return;

		if (enterListeners.indexOf(func) == -1)
			enterListeners.push(func);
	}

	inline public function notifyExit (func:WynButton->Void)
	{
		if (func == null)
			return;

		if (exitListeners.indexOf(func) == -1)
			exitListeners.push(func);
	}

	inline public function removeDown (func:WynButton->Void)
	{
		downListeners.remove(func);
	}

	inline public function removeUp (func:WynButton->Void)
	{
		upListeners.remove(func);
	}

	inline public function removeEnter (func:WynButton->Void)
	{
		enterListeners.remove(func);
	}

	inline public function removeExit (func:WynButton->Void)
	{
		exitListeners.remove(func);
	}

	inline public function setSize (w:Int, h:Int)
	{
		width = w;
		height = h;
	}

	override private function set_active (val:Bool) : Bool
	{
		if (!val)
			setState(STATE_UP);

		return active = val;
	}
}