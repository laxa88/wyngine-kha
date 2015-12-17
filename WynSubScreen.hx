package wyn;

import kha.Color;

class WynSubScreen extends WynScreen
{
	public var _parentScreen:WynScreen;
	public var onOpenCallback:Void->Void = null; // assign manually
	public var onCloseCallback:Void->Void = null; // assign manually
	public var _created:Bool = false;
	public var _dead:Bool = false;



	// NOTE:
	// There is no open() method, because we use the
	// parent screen to open subscreens.

	public function close ()
	{
		// Use this to notify parent to close the subscreen
		_parentScreen.closeSubScreen();
	}

	@:allow(wyn.WynScreen)
	function doOpen ()
	{
		// NOTE: you shouldn't call this manually -- let the parent screen do it.
		// Independent method, can be overridden. This allows custom behaviour like transitions.
		onOpen();
	}

	@:allow(wyn.WynScreen)
	function doClose ()
	{
		// NOTE: you shouldn't call this manually -- let the parent screen do it.
		// Independent method, can be overridden. This allows custom behaviour like transitions.
		onClose();
	}

	function onOpen ()
	{
		// For overriding. This is called when the parent screen is done opening (right before it updates).

		if (onOpenCallback != null)
			onOpenCallback();
	}

	function onClose ()
	{
		// For overriding. This is called when the parent screen is done closing (right before destroying).

		if (onCloseCallback != null)
			onCloseCallback();

		// If this subscreen belongs to a parent, clear it
		if (_parentScreen.currSubScreen == this)
			_parentScreen.currSubScreen = null;

		// flag as dead so parent knows to remove this.
		_dead = true;
	}



	public function new ()
	{
		super();
	}

	override public function update ()
	{
		super.update();
	}

	override public function render (c:WynCamera)
	{
		super.render(c);
	}

	override public function destroy ()
	{
		super.destroy();

		onOpenCallback = null;
		onCloseCallback = null;
		_parentScreen = null;
	}
}