package wyn.component;

import wyn.WynObject;

class WynComponent
{
	public var parent:WynObject;
	public var active:Bool = true;
	public function new () : Void {}
	public function init () : Void {}
	public function update () : Void {}
	public function destroy () : Void {}
}