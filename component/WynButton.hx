package wyn.component;

import kha.input.Mouse;
import kha.input.Surface;
import kha.Image;
import kha.graphics2.Graphics;
import kha.math.FastMatrix3;
import wyn.Wyngine;
import wyn.util.WynUtil;

class WynButton extends WynComponent
{
	public static var WYN_DEBUG:Bool = false;

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

	var hitTouches:Map<Int, Bool>; // map of whether each touch is within the button
	var isTouchDowns:Map<Int, Bool>; // map of whether each touch is down or up
	var hitMouse:Bool = false; // whether the mouse is within the button
	var isMouseDown:Bool = false; // whether the mouse state is down or up

	var downListeners:Array<WynButton->Void> = [];
	var upListeners:Array<WynButton->Void> = [];
	var enterListeners:Array<WynButton->Void> = [];
	var exitListeners:Array<WynButton->Void> = [];

	var processedDown = false;
	var processedMove = false;
	var processedUp = false;



	public function new (w:Int, h:Int)
	{
		super();

		width = w;
		height = h;

		hitTouches = new Map<Int, Bool>();
		isTouchDowns = new Map<Int, Bool>();

		// add listeners
		Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, null);
		Surface.get().notify(onTouchStart, onTouchEnd, onTouchMove);
	}

	override public function update ()
	{
		super.update();

		processedDown = false;
		processedMove = false;
		processedUp = false;
	}





	function onMouseDown (index:Int, x:Int, y:Int)
	{
		if (!isButtonActive())
			return;

		isMouseDown = true;
		processedDown = true;

		if (isWithinButton(x, y))
		{
			// if current mouse is within button, call event
			for (listener in downListeners)
				listener(this);

			// update flag
			setState(STATE_DOWN);
		}

		// if current mouse is outside button, do nothing
	}

	function onMouseUp (index:Int, x:Int, y:Int)
	{
		if (!isButtonActive())
			return;

		isMouseDown = false;
		processedUp = true;

		if (isWithinButton(x, y))
		{
			// if current mouse is within button, call event
			for (listener in upListeners)
				listener(this);

			// update flag
			setState(STATE_OVER);
		}
	}

	function onMouseMove (x:Int, y:Int, _, _)
	{
		if (!isButtonActive())
			return;

		var prevHitMouse = hitMouse;
		processedMove = true;

		if (isWithinButton(x, y))
		{
			hitMouse = true;

			// if mouse wasn't in button but now is, flag state change
			if (!prevHitMouse)
			{
				if (isMouseDown)
					setState(STATE_DOWN);
				else
					setState(STATE_OVER);

				for (listener in enterListeners)
					listener(this);
			}
		}
		else
		{
			hitMouse = false;

			// if mouse was in button but now isn't, flag state change
			if (prevHitMouse)
			{
				setState(STATE_UP);

				for (listener in exitListeners)
					listener(this);
			}
		}
	}



	function onTouchStart (index:Int, x:Int, y:Int)
	{
		if (index == 0 && processedDown)
			return;

		if (!isButtonActive())
			return;

		isTouchDowns.set(index, true);
		processedDown = true;

		if (isWithinButton(x, y))
		{
			for (listener in downListeners)
				listener(this);

			setState(STATE_DOWN);
		}
	}

	function onTouchEnd (index:Int, x:Int, y:Int)
	{
		if (index == 0 && processedUp)
			return;

		if (!isButtonActive())
			return;

		isTouchDowns.remove(index);
		processedUp = true;

		if (isWithinButton(x, y))
		{
			// if current mouse is within button, call event
			for (listener in upListeners)
				listener(this);

			// update flag
			setState(STATE_OVER);
		}
	}

	function onTouchMove (index:Int, x:Int, y:Int)
	{
		if (index == 0 && processedMove)
			return;

		if (!isButtonActive())
			return;

		var prevHitTouch = hitTouches.exists(index);
		var isTouchDown = isTouchDowns.exists(index);
		processedMove = true;

		if (isWithinButton(x, y))
		{
			hitTouches.set(index, true);

			if (!prevHitTouch)
			{
				if (isTouchDown)
					setState(STATE_DOWN);
				else
					setState(STATE_UP);

				for (listener in enterListeners)
					listener(this);
			}
		}
		else
		{
			hitTouches.remove(index);

			if (prevHitTouch)
			{
				setState(STATE_UP);

				for (listener in exitListeners)
					listener(this);
			}
		}
	}



	function isButtonActive () : Bool
	{
		if (!enabled || !active)
			return false;
		else if (parent != null && (!parent.enabled || !parent.active))
			return false;
		else
			return true;
	}

	function isWithinButton (rawX:Int, rawY:Int) : Bool
	{
		var hitHoriz = false;
		var hitVert = false;

		var screenX = Std.int(rawX / Wyngine.gameScale - Wyngine.screenOffsetX);
		var screenY = Std.int(rawY / Wyngine.gameScale - Wyngine.screenOffsetY);

		if (screenX > parent.x + offsetX) hitHoriz = (screenX < parent.x + offsetX + width);
		if (screenY > parent.y + offsetY) hitVert = (screenY < parent.y + offsetY + height);

		return (hitHoriz && hitVert);
	}





	override public function init ()
	{
		parent.addRenderer(render);

		setState(STATE_UP);
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

		hitTouches = null;
		isTouchDowns = null;

		downListeners = null;
		upListeners = null;
		enterListeners = null;
		exitListeners = null;

		Mouse.get().remove(onMouseDown, onMouseUp, onMouseMove, null);
		Surface.get().remove(onTouchStart, onTouchEnd, onTouchMove);
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

		// if (WYN_DEBUG)
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