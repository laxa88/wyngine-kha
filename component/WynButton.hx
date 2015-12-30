package wyn.component;

import kha.Image;
import kha.graphics2.Graphics;
import kha.math.FastMatrix3;
import wyn.manager.WynMouse;
import wyn.manager.WynTouch;
import wyn.manager.TouchData;
import wyn.util.WynUtil;

class WynButton extends WynComponent
{
	public static var DEBUG:Bool = false;

	public static inline var STATE_NONE:Int = 0;
	public static inline var STATE_UP:Int = 1;
	public static inline var STATE_OVER:Int = 2;
	public static inline var STATE_DOWN:Int = 3;
	public var currState:Int = STATE_UP;
	public var prevState:Int = STATE_UP;

	public var image:Image;
	public var region:Region;
	public var sliceDataUp:SliceData;
	public var sliceDataOver:SliceData;
	public var sliceDataDown:SliceData;
	public var width:Int = 0;
	public var height:Int = 0;
	public var alpha:Float = 1;
	public var scale:Float = 1;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	var downListeners:Array<WynButton->Void>;
	var upListeners:Array<WynButton->Void>;
	var enterListeners:Array<WynButton->Void>;
	var exitListeners:Array<WynButton->Void>;

	public function new (w:Int, h:Int)
	{
		super();

		width = w;
		height = h;

		downListeners = [];
		upListeners = [];
		enterListeners = [];
		exitListeners = [];
	}

	override public function init ()
	{
		parent.addRenderer(render);
	}

	override public function update ()
	{
		if (!active)
			return;

		// If the mouse is in or outside
		var state = STATE_UP;

		// If the mouse is inside the button, check for
		// mouse down or mouse over states.
		if (WynMouse.init)
		{
			if (isMouseWithinButton())
			{
				// NOTE: down and up event may happen in the same update, so don't do if-else.
				if (WynMouse.isDown())
				{
					for (listener in downListeners)
						listener(this);
				}

				if (WynMouse.isUp())
				{
					for (listener in upListeners)
						listener(this);
				}
				
				if (WynMouse.isAny())
					state = STATE_DOWN;
				else
					state = STATE_OVER;
			}
		}

		if (WynTouch.init)
		{
			if (isTouchWithinButton())
			{
				if (WynTouch.isDown())
				{
					for (listener in downListeners)
						listener(this);
				}

				if (WynTouch.isUp())
				{
					for (listener in upListeners)
						listener(this);
				}
				
				if (WynTouch.isAny())
					state = STATE_DOWN;
				else
					state = STATE_OVER;
			}
		}

		// If the state changed, check for enter/exit events
		if (state != currState)
		{
			// Mouse moved into button
			if ((state == STATE_OVER || state == STATE_DOWN) &&
				(prevState == STATE_UP || prevState == STATE_NONE))
			{
				for (listener in enterListeners)
					listener(this);
			}

			// Mouse moved out of button
			if ((state == STATE_UP || state == STATE_NONE) &&
				(prevState == STATE_OVER || prevState == STATE_DOWN))
			{
				for (listener in exitListeners)
					listener(this);

				// Reset state
				state = STATE_UP;
			}
		}

		setState(state);
	}

	inline function isMouseWithinButton () : Bool
	{
		if (!WynMouse.init)
			return false;

		var hitHoriz = false;
		var hitVert = false;

		if (WynMouse.x > parent.x + offsetX) hitHoriz = (WynMouse.x < parent.x + offsetX + width);
		if (WynMouse.y > parent.y + offsetY) hitVert = (WynMouse.y < parent.y + offsetY + height);

		return (hitHoriz && hitVert);
	}

	inline function isTouchWithinButton () : Bool
	{
		if (!WynTouch.init)
			return false;

		var hit = false;
		var hitHoriz = false;
		var hitVert = false;
		var data:TouchData;

		for (key in WynTouch.touches.keys())
		{
			data = WynTouch.touches[key];
			if (data.x > parent.x + offsetX) hitHoriz = (data.x < parent.x + offsetX + width);
			if (data.y > parent.y + offsetY) hitVert = (data.y < parent.y + offsetY + height);

			hit = hit || (hitHoriz && hitVert);

			hitHoriz = false;
			hitVert = false;
		}

		return hit;
	}

	override public function destroy ()
	{
		super.destroy();

		denotify();

		parent.removeRenderer(render);

		image = null;
		region = null;
	}



	public function render (g:Graphics)
	{
		if (image == null || region == null)
			return;

		if (parent.angle != 0)
		{
			var ox = parent.x - (parent.screen.scrollX - parent.screen.shakeX) * parent.scrollFactorX + offsetX;
			var oy = parent.y - (parent.screen.scrollY - parent.screen.shakeY) * parent.scrollFactorY + offsetY;

			var rad = WynUtil.degToRad(parent.angle);
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
			region.sx, region.sy,
			region.sw, region.sh,
			parent.x + offsetX, parent.y + offsetY,
			width, height);

		// Finalise opacity
		if (alpha != 1) g.popOpacity();

		// Finalise the rotation
		if (parent.angle != 0) g.popTransformation();

		// if (DEBUG)
		// {
		// 	g.color = 0xFFFF0000;
		// 	g.drawRect(parent.x, parent.y, width, height);
		// 	g.color = 0xFFFFFFFF;
		// }
	}

	inline public function setImage (img:Image, upData:SliceData, overData:SliceData, downData:SliceData)
	{
		image = img;

		sliceDataUp = upData;
		sliceDataOver = overData;
		sliceDataDown = downData;

		setState(STATE_UP);
	}

	inline public function setOffset (ox:Float, oy:Float)
	{
		offsetX = ox;
		offsetY = oy;
	}

	function setState (state:Int)
	{
		prevState = currState;
		currState = state;

		// Default up state
		var sliceData:SliceData = sliceDataUp;

		switch (currState)
		{
			case STATE_NONE: sliceData = sliceDataUp;

			case STATE_UP: sliceData = sliceDataUp;

			case STATE_OVER: sliceData = sliceDataOver;

			case STATE_DOWN: sliceData = sliceDataDown;
		}

		// update region
		region = {
			sx : sliceData.x,
			sy : sliceData.y,
			sw : sliceData.width,
			sh : sliceData.height
		};
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
}