package wyn;

import wyn.manager.WynManager;
import kha.Scheduler;
import kha.graphics2.Graphics;

class Wyngine
{
	public static var onResize:Void->Void;
	public static var gameWidth:Int = 0;
	public static var gameHeight:Int = 0;
	public static var gameScale:Float = 1; // this value will adjust according to khanvas dimensions
	public static var dt:Float = 0;

	static var currTime:Float = 0;
	static var prevTime:Float = 0;
	static var screens:Array<WynScreen>;
	static var managers:Array<WynManager>;
	static var currScreen:WynScreen;
	static var screensLen:Int;

	inline public static function setup (width:Int, height:Int)
	{
		gameWidth = width;
		gameHeight = height;

		screens = [];
		managers = [];

		currTime = Scheduler.time();

		#if js

			// Prevents mobile touches from scrolling/scaling the screen.
			js.Browser.window.addEventListener("touchstart", function (e:js.html.Event) {
				e.preventDefault();
			});

			// Make sure that the canvas is refreshed on browser resize, to prevent
			// the mouse/touch positions from desyncing.
			js.Browser.window.addEventListener("resize", function () {
				
				// NOTE: we need to delay the method call here because we can't get
				// the updated width/height values immediately.
				haxe.Timer.delay(function () {

					refreshGameScale();
					if (onResize != null)
						onResize();

				}, 100);
			});

			refreshGameScale();

			var wyn = 'background:#ff69b4;color:#ffffff';
			var black = 'background:#ffffff;color:#000000';
			var kha = 'background:#2073d0;color:#fdff00';
			js.Browser.console.log('%cMade with %c wyngine %c\nPowered by %c kha ', black, wyn, black, kha);

		#end
	}

	static function refreshGameScale ()
	{
		var khanvasW = kha.System.pixelWidth;
		var khanvasH = kha.System.pixelHeight;
		var ratioW = gameWidth / khanvasW;
		var ratioH = gameHeight / khanvasH;
		var ratio = Math.min(ratioW, ratioH);
		gameScale = ratio;
	}

	inline public static function update ()
	{
		// Update delta time
		prevTime = currTime;
		currTime = Scheduler.time();
		dt = currTime - prevTime;

		// Update scene object and their components
		// render from back to front (index 0 to last)
		var i = 0;
		while (i < screens.length)
		{
			currScreen = screens[i];

			// remove screens that are inactive
			if (!currScreen.alive)
			{
				screens.remove(currScreen);
				i--;
			}
			else
			{
				if (i < screensLen-1)
				{
					if (currScreen.persistentUpdate)
						currScreen.update();
				}
				else
				{
					currScreen.update();
				}
			}

			i++;
		}

		// Allow each manager to process events before calling update.
		for (m in managers)
		{
			if (m.active)
				m.update();
		}
	}

	inline public static function render (g:Graphics)
	{
		// render from back to front (index 0 to last)
		screensLen = screens.length;
		for (i in 0 ... screensLen)
		{
			currScreen = screens[i];

			if (i < screensLen-1)
			{
				if (currScreen.persistentRender)
					currScreen.render(g);
			}
			else
			{
				currScreen.render(g);
			}
		}
	}

	inline public static function addScreen (screen:WynScreen)
	{
		if (screens.indexOf(screen) == -1)
		{
			// add to list to immediately update/render the screen
			screens.push(screen);

			// begin opening
			screen.open();
		}
	}

	inline public static function removeScreen (screen:WynScreen)
	{
		if (screens.indexOf(screen) != -1)
		{
			// begin closing
			screen.close();
		}
	}

	inline public static function addManager (manager:WynManager)
	{
		managers.push(manager);
	}
}