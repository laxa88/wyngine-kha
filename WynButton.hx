package wyn;

import kha.Color;
import kha.Image;
import kha.Assets;
import kha.graphics2.Graphics;

class WynButton extends WynSprite
{
	/**
	 * - Buttons have separate images for up/hover/down states.
	 * - If the button is 9-slices, it will re-draw the slice every time
	 * the width or height changes.
	 * - By logic, a 9-slice image cannot be animated because it consists
	 * of 9 parts within a spritesheet.
	 * - As such, buttons can't be animated.
	 *
	 * To use WynButton:
	 * - instance it normally like a WynSprite
	 * - load the image and provide the down/hover/up state's SliceData
	 * - (optional) set the hitbox offset.
	 */

	// Button states as int
	public static inline var NONE:Int = 0;
	public static inline var UP:Int = 1;
	public static inline var HOVER:Int = 2;
	public static inline var DOWN:Int = 3;

	// Store the slice data so we can reslice it when width or height changes
	var upData:WynSprite.SliceData;
	var hoverData:WynSprite.SliceData;
	var downData:WynSprite.SliceData;

	var _downListeners:Array<WynButton->Void>;
	var _upListeners:Array<WynButton->Void>;
	var _enterListeners:Array<WynButton->Void>;
	var _exitListeners:Array<WynButton->Void>;

	var _buttonState:Int;
	var _prevState:Int;



	public function new (x:Float=0, y:Float=0, w:Float=0, h:Float=0)
	{
		super(x, y, w, h);

		_downListeners = [];
		_upListeners = [];
		_enterListeners = [];
		_exitListeners = [];
	}

	override public function update ()
	{
		super.update();

		if (!active)
			return;

		// Reset state every update. When iterating through multiple
		// cameras, the mouse may be "inside" a button in one camera, but
		// "outside" the button in other cameras. As such, prioritise:
		// DOWN > HOVER > UP
		var state = WynButton.UP;

		for (cam in Wyngine.G.cameras)
		{
			// If the mouse is in or outside
			var hitHoriz = false;
			var hitVert = false;
			if (WynMouse.gameX > x) hitHoriz = WynMouse.gameX < x + width;
			if (WynMouse.gameY > y) hitVert = WynMouse.gameY < y + height;

			// If the mouse is inside the button, check for
			// mouse down or mouse over states.
			if (hitHoriz && hitVert)
			{
				// NOTE: down and up event may happen in the same update, so don't do if-else.
				if (WynMouse.isMouseDown(0))
				{
					for (listener in _downListeners)
						listener(this);
				}

				if (WynMouse.isMouseUp(0))
				{
					for (listener in _upListeners)
						listener(this);
				}
				
				if (WynMouse.isMouse(0))
					state = WynButton.DOWN;
				else
					state = WynButton.HOVER;
			}
		}

		// If the state changed, check for enter/exit events
		if (state != _prevState)
		{
			// Mouse moved into button
			if ((state == WynButton.HOVER || state == WynButton.DOWN) &&
				(_prevState == WynButton.UP || _prevState == WynButton.NONE))
			{
				for (listener in _enterListeners)
					listener(this);
			}

			// Mouse moved out of button
			if ((state == WynButton.UP || state == WynButton.NONE) &&
				(_prevState == WynButton.HOVER || _prevState == WynButton.DOWN))
			{
				for (listener in _exitListeners)
					listener(this);

				// Reset state
				state = WynButton.UP;
			}
		}

		setButtonState(state);
		_prevState = state;
	}

	override public function render (c:WynCamera)
	{
		super.render(c);
	}

	override public function destroy ()
	{
		_downListeners = [];
		_upListeners = [];
		_enterListeners = [];
		_exitListeners = [];
	}

	/**
	 * Add event listeners for down, up, enter and exit mouse states.
	 */
	public function notify (?downFunc:WynButton->Void, ?upFunc:WynButton->Void, ?enterFunc:WynButton->Void, ?exitFunc:WynButton->Void)
	{
		if (downFunc != null)
		{
			if (_downListeners.indexOf(downFunc) == -1)
				_downListeners.push(downFunc);
		}

		if (upFunc != null)
		{
			if (_upListeners.indexOf(upFunc) == -1)
				_upListeners.push(upFunc);
		}

		if (enterFunc != null)
		{
			if (_enterListeners.indexOf(enterFunc) == -1)
				_enterListeners.push(enterFunc);
		}

		if (exitFunc != null)
		{
			if (_exitListeners.indexOf(exitFunc) == -1)
				_exitListeners.push(exitFunc);
		}
	}

	/**
	 * Load image via kha's internal image loader. Make
	 * sure you loaded the room that contains this image,
	 * in project.kha.
	 */
	public function setButtonImage (img:Image, frameW:Int, frameH:Int, ?up:WynSprite.SliceData, ?hover:WynSprite.SliceData, ?down:WynSprite.SliceData)
	{
		_spriteType = WynSprite.BUTTON;

		// Same as WynSprite
		image = img;

		// Set default variables in case there is no button data
		frameWidth = imageWidth = frameW;
		frameHeight = imageHeight = frameH;

		// Assign the data for each state
		upData = up;
		hoverData = hover;
		downData = down;

		// Default state is always up
		setButtonState(WynButton.UP);
	}

	/**
	 * Unlike a fixed-sized button, 9-sliced buttons will resize based on
	 * frameWidth/frameHeight whenever width/height is changed, much like
	 * how WynSprite's 9-slice image works.
	 */ 
	public function set9SliceButtonImage (img:Image, ?up:WynSprite.SliceData, ?hover:WynSprite.SliceData, ?down:WynSprite.SliceData)
	{
		_spriteType = WynSprite.BUTTON9SLICE;

		// Assign the data for each state
		upData = up;
		hoverData = hover;
		downData = down;

		// Refer to WynSprite.load9SliceImage for comments on this part
		originalImage = img;
		image = Image.createRenderTarget(Wyngine.G.gameWidth, Wyngine.G.gameHeight);

		// Note: image's frame X/Y/Width/Height never changes; we use the
		// sliceData for each state and use originalImage to slice and draw
		// the final full image unto "image".
		frameX = 0;
		frameY = 0;
		frameWidth = imageWidth = cast width;
		frameHeight = imageHeight = cast height;

		// Set default slice data
		setButtonState(WynButton.UP);
	}

	function setButtonState (state:Int)
	{
		// No need to repeat if it's been done before
		if (_buttonState == state)
			return;

		_buttonState = state;

		if (state == WynButton.UP && upData != null)
			sliceData = upData;
		else if (state == WynButton.HOVER && hoverData != null)
			sliceData = hoverData;
		else if (state == WynButton.DOWN && downData != null)
			sliceData = downData;

		// Remember: We're slicing from originalImage (the raw size atlas)
		// onto the image (dynamic size) using sliceData. When rendering
		// image onto the buffer, the frame data (frameX, frameY,
		// frameWidth, frameHeight) never changes.
		if (sliceData != null)
		{
			if (_spriteType == WynSprite.BUTTON)
			{
				// If this is a single button, then the whole image atlas is
				// used normally, and we just draw from source frame like how
				// sprite animations do.
				frameX = sliceData.x;
				frameY = sliceData.y;
				frameWidth = sliceData.width;
				frameHeight = sliceData.height;
			}
			else if (_spriteType == WynSprite.BUTTON9SLICE)
			{
				// If this is a 9-slice button, the source frame never changes:
				// frameX, frameY = 0
				// frameWidth, frameHeight = imageWidth, imageHeight
				drawSlice(originalImage, image, sliceData);
			}
		}
	}

	override private function set_imageWidth (val:Int) : Int
	{
		imageWidth = val;
		if (imageWidth < 0) imageWidth = 0;

		// Refer to WynSprite for the comments on this part
		updateButtonSize();

		return imageWidth;
	}

	override private function set_imageHeight (val:Int) : Int
	{
		imageHeight = val;
		if (imageHeight < 0) imageHeight = 0;

		// Refer to WynSprite for the comments on this part
		updateButtonSize();

		return imageHeight;
	}

	inline function updateButtonSize ()
	{
		if (_spriteType == WynSprite.BUTTON9SLICE)
		{
			// If this is a slice image, setting width/height will
			// affect both the hitbox and the frameWidth/frameHeight.
			if (sliceData != null)
			{
				frameWidth = imageWidth;
				frameHeight = imageHeight;

				if (_spriteType == WynSprite.BUTTON9SLICE)
				{
					// For buttons, we need to reslice for up,hover,down states
					if (imageWidth > image.width || imageHeight > image.height)
						image = Image.createRenderTarget(cast imageWidth, cast imageHeight);

					// Slice into 3 separate images so we can just draw
					drawSlice(originalImage, image, sliceData);
				}
			}
		}
	}
}