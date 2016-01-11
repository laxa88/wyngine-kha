package wyn;

import kha.System;
import kha.Image;
import kha.Scheduler;
import kha.Framebuffer;
import kha.Scaler;
import kha.graphics2.Graphics;
import kha.graphics2.ImageScaleQuality;
import wyn.manager.WynManager;

class Wyngine
{
	var backbuffer:Image;
	var g:Graphics;

	public static var onResize:Void->Void;
	public static var gameWidth(default, null):Int = 0;
	public static var gameHeight(default, null):Int = 0;
	public static var screenOffsetX(default, null):Int = 0;
	public static var screenOffsetY(default, null):Int = 0;
	public static var gameScale(default, null):Float = 1; // this value will adjust according to khanvas dimensions
	public static var dt(default, null):Float = 0;
	public static var bgColor:Int = 0xff6495ed; // cornflower

	static var currTime:Float = 0;
	static var prevTime:Float = 0;
	static var screens:Array<WynScreen> = [];
	static var screensToAdd:Array<WynScreen> = [];
	static var managers:Array<WynManager> = [];
	static var currScreen:WynScreen;
	static var screensLen:Int = 0;



	public function new (width:Int, height:Int)
	{
		backbuffer = Image.createRenderTarget(width, height);
		g = backbuffer.g2;
		g.imageScaleQuality = ImageScaleQuality.High;

		gameWidth = width;
		gameHeight = height;
		currTime = Scheduler.time();

		setupHtml();

		setupAndroid();
	}

	function setupHtml ()
	{
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

			var wyn = 'background:#ff69b4;color:#ffffff';
			var black = 'background:#ffffff;color:#000000';
			var kha = 'background:#2073d0;color:#fdff00';
			js.Browser.console.log('%cMade with %c wyngine %c\nPowered by %c kha ', black, wyn, black, kha);

		#end
	}

	function setupAndroid ()
	{
		System.notifyOnApplicationState(function () {
			// foreground
			trace("onForeground");
		}, function () {
			// resume
			trace("onResume");
		}, function () {
			// pause
			trace("onPause");
		}, function () {
			// background
			trace("onBackground");
		}, function () {
			// shutdown
			trace("onShutdown");
		});
	}

	static public function refreshGameScale ()
	{
		// always reset before rescaling
		screenOffsetX = 0;
		screenOffsetY = 0;

		var khanvasW = System.pixelWidth;
		var khanvasH = System.pixelHeight;
		// var ratioW = gameWidth / khanvasW;
		// var ratioH = gameHeight / khanvasH;
		// var ratio = Math.min(ratioW, ratioH);
		// gameScale = ratio;

		var screenRatioW = khanvasW / gameWidth;
		var screenRatioH = khanvasH / gameHeight;
		gameScale = Math.min(screenRatioW, screenRatioH);
		var w = gameWidth * gameScale;
		var h = gameHeight * gameScale;

		if (screenRatioW > screenRatioH)
		{
			screenOffsetX = Math.floor((khanvasW/gameScale - gameWidth)/2);
			// gameOffsetX = Math.floor((khanvasW - w) / 2 / zoom);
		}
		else
		{
			screenOffsetY = Math.floor((khanvasH/gameScale - gameHeight)/2);
			// gameOffsetY = Math.floor((khanvasH - h) / 2 / zoom);
		}

		// trace("khanvas : " + khanvasW + "," + khanvasH);
		// trace("game    : " + gameWidth + "," + gameHeight);
		// trace("ratio : " + screenRatioW + " , " + screenRatioH);
		// trace("w/h :   " + w + " , " + h);
		// trace("offset  : " + screenOffsetX + " , " + screenOffsetY);
		// trace("final scale : " + " , " + gameScale);
	}

	public function update ()
	{
		// Update delta time
		prevTime = currTime;
		currTime = Scheduler.time();
		dt = currTime - prevTime;

		// Add and init any screens that were previously added
		while (screensToAdd.length > 0)
		{
			var nextScreen = screensToAdd.shift();
			nextScreen.open();
			screens.push(nextScreen);
		}

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

	public function render (framebuffer:Framebuffer)
	{
		g.begin(true, bgColor); // cornflower

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

		g.end();

		framebuffer.g2.begin(true, 0xFFFFFFFF);
		Scaler.scale(backbuffer, framebuffer, System.screenRotation);
		framebuffer.g2.end();
	}

	static public function addScreen (screen:WynScreen)
	{
		if (screens.indexOf(screen) == -1)
		{
			// add to list to immediately update/render the screen
			screensToAdd.push(screen);
		}
	}

	static public function removeScreen (screen:WynScreen)
	{
		if (screens.indexOf(screen) != -1)
		{
			// begin closing
			screen.close();
		}
	}

	static public function addManager (manager:WynManager)
	{
		managers.push(manager);
	}
}