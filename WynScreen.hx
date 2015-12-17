package wyn;

import kha.Color;

class WynScreen extends WynGroup<WynObject>
{
	/**
	 * WynScreen is like HaxeFlixel FlxState; they're fancy
	 * WynGroup that extends the most basic Wyn class.
	 */

	public var persistentUpdate:Bool = false; // set true to update when inactive
	public var persistentRender:Bool = true; // set true to render when inactive
	public var currSubScreen:WynSubScreen;
	public var prevSubScreen:WynSubScreen;
	var requestSubScreenReset:Bool = false;
	var requestedSubScreen:WynSubScreen;



	/**
	 * A screen doesn't have a size. The rendering (and thus, its size) is done on the WynCamera.
	 */
	public function new ()
	{
		super();
	}

	public function tryUpdate ()
	{
		// Referenced from Flixel:
		// Instead of calling update() directly, Wyngine will call tryUpdate().
		// This checks if the current screen is inactive (there's a subscreen over it),
		// and if persistentUpdate is true, will update under the subscreen.
		// This process is repeated for tryRender.

		if (persistentUpdate || currSubScreen == null)
		{
			// Only update this screen if it's persistent, or if
			// this is the only screen visible.
			update();
		}

		if (requestSubScreenReset)
		{
			requestSubScreenReset = false;
			resetSubScreen();
		}
		else
		{
			// Update subscreen if it exists
			if (prevSubScreen != null)
			{
				prevSubScreen.tryUpdate();

				if (prevSubScreen._dead)
				{
					prevSubScreen.destroy();
					prevSubScreen = null;
				}
			}

			if (currSubScreen != null)
				currSubScreen.tryUpdate();
		}
	}

	override public function update ()
	{
		super.update();
	}

	override public function render (c:WynCamera)
	{
		if (persistentRender || currSubScreen == null)
		{
			// Only render this screen if it's persistent, or if
			// this is the only screen visible.
			super.render(c);
		}

		// Render subscreen if it exists
		if (prevSubScreen != null)
			prevSubScreen.render(c);

		if (currSubScreen != null)
			currSubScreen.render(c);
	}

	override public function destroy ()
	{
		super.destroy();
	}

	public function onResize ()
	{
		// For you to handle whenever the screen size is changed
	}

	public function openSubScreen (subScreen:WynSubScreen)
	{
		requestSubScreenReset = true;
		requestedSubScreen = subScreen;
	}

	public function closeSubScreen ()
	{
		requestSubScreenReset = true;
	}

	function resetSubScreen ()
	{
		if (currSubScreen != null)
		{
			// Let subscreen handle its own closing, to allow transitions.
			// Don't forget to set _dead to true when done, otherwise the
			// subscreen will not be removed.
			currSubScreen.doClose();
		}

		// Assign subscreen, if any.
		prevSubScreen = currSubScreen;
		currSubScreen = requestedSubScreen;
		requestedSubScreen = null;

		// If the assigned subscreen exists, open it
		if (currSubScreen != null)
		{
			// If the subscreen covers the main screen, don't
			// let the input interfere with the subscreen upon creation
			if (!persistentUpdate)
				WynKeyboard.reset();

			// Check the flag so we only create the subscreen once.
			if (!currSubScreen._created)
			{
				currSubScreen._created = true;
				currSubScreen._parentScreen = this;
				currSubScreen.doOpen();
			}
		}
	}
}