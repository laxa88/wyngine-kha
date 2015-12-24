package wyn;

import wyn.manager.WynManager;
import kha.Scheduler;
import kha.graphics2.Graphics;

class Wyngine
{
	public static var dt:Float = 0;
	static var currTime:Float = 0;
	static var prevTime:Float = 0;
	static var scene:WynScene;
	static var managers:Array<WynManager>;

	inline public static function setup ()
	{
		managers = [];

		currTime = Scheduler.time();
	}

	inline public static function update ()
	{
		// Update delta time
		prevTime = currTime;
		currTime = Scheduler.time();
		dt = currTime - prevTime;

		// Update scene object and their components
		if (scene != null)
			scene.update();

		// Allow each manager to process events before calling update.
		for (m in managers)
		{
			if (m.active)
				m.update();
		}
	}

	inline public static function render (g:Graphics)
	{
		if (scene != null)
			scene.render(g);
	}

	inline public static function setScene (newScene:WynScene)
	{
		scene = newScene;
	}

	inline public static function addManager (manager:WynManager)
	{
		managers.push(manager);
	}
}