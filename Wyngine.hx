package wyn;

import wyn.manager.WynManager;
import kha.graphics2.Graphics;

class Wyngine
{
	static var scene:WynScene;
	static var managers:Array<WynManager>;

	inline public static function setup ()
	{
		managers = [];
	}

	inline public static function update ()
	{
		for (m in managers)
		{
			if (m.active)
				m.update();
		}

		if (scene != null)
			scene.update();
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