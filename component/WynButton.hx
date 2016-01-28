package wyn.component;

import kha.input.Mouse;
import kha.input.Surface;
import kha.Image;
import kha.graphics2.Graphics;
import kha.math.FastMatrix3;
import wyn.Wyngine;
import wyn.util.WynUtil;

class WynButton extends WynRenderable
{
	// NOTE:
	// - WynButton only handles visual state changes. The
	// actual down/up/over/exit events need to be manually
	// handled by your game.
	//
	// - The reason for this is, HTML5 events need to be triggered
	// from the first callback function in order to maintain trustedSource. If
	// the callback calls another function (e.g. custom listener arrays),
	// then it will be flagged as insecure and blocked by pop-up blockers.
	// 
	// - Use stateChanged to check if an event needs to be triggered.

	public static var WYN_DEBUG:Bool = false;

	static var MOUSE_ENABLED:Bool = false;
	static var SURFACE_ENABLED:Bool = false;

	public static inline var STATE_NONE:Int = 0;
	public static inline var STATE_UP:Int = 1;
	public static inline var STATE_OVER:Int = 2;
	public static inline var STATE_DOWN:Int = 3;
	public var currState:Int = STATE_NONE;
	public var prevState:Int = STATE_NONE;

	public var regionDataUp:Region;
	public var regionDataOver:Region;
	public var regionDataDown:Region;

	var hitTouches:Map<Int, Bool>; // map of whether each touch is within the button
	var isTouchDowns:Map<Int, Bool>; // map of whether each touch is down or up
	var hitMouse:Bool = false; // whether the mouse is within the button
	var isMouseDown:Bool = false; // whether the mouse state is down or up

	var processedDown = false;
	var processedMove = false;
	var processedUp = false;

	// Use this flag on events to check if this button needs to be triggered
	public var stateChanged = false;



	public function new (w:Int, h:Int)
	{
		super(w, h);

		hitTouches = new Map<Int, Bool>();
		isTouchDowns = new Map<Int, Bool>();

		Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, null);
		Surface.get().notify(onTouchStart, onTouchEnd, onTouchMove);
	}

	override public function update ()
	{
		super.update();

		processedDown = false;
		processedMove = false;
		processedUp = false;

		if (currState == prevState)
		{
			stateChanged = false;
		}
		else
		{
			stateChanged = true;
			prevState = currState;
		}
	}





	function onMouseDown (index:Int, x:Int, y:Int)
	{
		if (!isButtonActive())
			return;

		isMouseDown = true;
		processedDown = true;

		if (isWithinButton(x, y))
		{
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
			}
		}
		else
		{
			hitMouse = false;

			// if mouse was in button but now isn't, flag state change
			if (prevHitMouse)
			{
				setState(STATE_UP);
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
			}
		}
		else
		{
			hitTouches.remove(index);

			if (prevHitTouch)
			{
				setState(STATE_UP);
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

	public function isWithinButton (rawX:Int, rawY:Int) : Bool
	{
		if (!enabled || !active)
			return false;
		else if (parent == null)
			return false;
		else if (!parent.enabled || !parent.active)
			return false;
		else if (parent.screen == null)
			return false;
		else if (!parent.screen.alive)
			return false;

		var hitHoriz = false;
		var hitVert = false;

		var screenX = Std.int(rawX / Wyngine.gameScale - Wyngine.screenOffsetX);
		var screenY = Std.int(rawY / Wyngine.gameScale - Wyngine.screenOffsetY);

		if (screenX > parent.x + offsetX) hitHoriz = (screenX < parent.x + offsetX + width);
		if (screenY > parent.y + offsetY) hitVert = (screenY < parent.y + offsetY + height);

		// trace("isWithinButton : " + rawX + "," + rawY + " / " + screenX + "," + screenY + " / " + parent.x + "," + parent.y);

		return (hitHoriz && hitVert);
	}





	override public function init ()
	{
		super.init();

		setState(STATE_UP);
	}

	override public function destroy ()
	{
		super.destroy();

		regionDataUp = null;
		regionDataOver = null;
		regionDataDown = null;

		hitTouches = null;
		isTouchDowns = null;

		Mouse.get().remove(onMouseDown, onMouseUp, onMouseMove, null);
		Surface.get().remove(onTouchStart, onTouchEnd, onTouchMove);
	}



	override public function render (g:Graphics)
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

	inline public function setButtonImage (img:Image, upData:Region, overData:Region, downData:Region)
	{
		image = img;

		regionDataUp = upData;
		regionDataOver = overData;
		regionDataDown = downData;

		setState(STATE_UP);
	}

	inline override public function setImage (img:Image, data:Region)
	{
		image = img;

		regionDataUp = data;
		regionDataOver = data;
		regionDataDown = data;

		setState(STATE_UP);
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

	override private function set_active (val:Bool) : Bool
	{
		if (!val)
			setState(STATE_UP);

		return active = val;
	}
}