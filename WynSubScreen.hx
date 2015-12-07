package wyn;

import kha.Color;

class WynSubScreen extends WynScreen
{
	public var closeCallback:Void->Void;
	public var _parentScreen:WynScreen;
	public var _created:Bool = false;



	public function close ()
	{
		if (_parentScreen != null && _parentScreen.currSubScreen == this)
			_parentScreen.closeSubState();
	}

	public function onOpen ()
	{
		// For overriding. This is called when the parent screen is done opening this.
	}

	public function new ()
	{
		super();

		closeCallback = null;
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

		closeCallback = null;
		_parentScreen = null;
	}
}