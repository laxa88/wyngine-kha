package wyn.component;

import wyn.WynObject;

class WynComponent
{
	public var tag:String = ""; // for custom identification
	public var parent:WynObject;
	public var active(default, set):Bool = true;
	public function new () : Void {}
	public function init () : Void {}
	public function update () : Void {}
	public function destroy () : Void { parent = null; active = false; }

	// Can customise additional behaviour on set
	private function set_active (val:Bool) : Bool { return active = val; }
}