package wyn.component;

import wyn.WynObject;
import kha.graphics2.Graphics;

class WynComponent
{
	public var tag:String = ""; // for custom identification
	public var parent:WynObject;
	public var enabled(default, set):Bool = true; // usually affects both update() and render()
	public var active(default, set):Bool = true; // affects update()
	public var visible(default, set):Bool = true; // affects render(), if any
	public var alpha:Float = 1.0;
	public var angle:Float = 0.0; // 0 ~ 360
	public var scale:Float = 1.0;
	public function new () : Void {}
	public function init () : Void {}
	public function update () : Void {}
	public function render (g:Graphics) {}
	public function destroy () : Void { tag = ""; parent = null; }

	// Can customise additional behaviour on set
	private function set_enabled (val:Bool) : Bool { return enabled = val; }
	private function set_active (val:Bool) : Bool { return active = val; }
	private function set_visible (val:Bool) : Bool { return visible = val; }
}