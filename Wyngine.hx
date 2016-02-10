package wyn;

import kha.Assets;
import kha.System;
import kha.ScreenRotation;
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

	static var active:Bool = true;
	static var visible:Bool = true;

	public static inline var FIT_NONE:Int = 0;
	public static inline var FIT_WIDTH:Int = 1;
	public static inline var FIT_HEIGHT:Int = 2;

	public static var IS_MOBILE:Bool = false;
	public static var imageQuality:ImageScaleQuality = ImageScaleQuality.High;
	public static var onResize:Void->Void;
	public static var oriWidth(default, null):Int = 0;
	public static var oriHeight(default, null):Int = 0;
	public static var gameWidth(default, null):Int = 0;
	public static var gameHeight(default, null):Int = 0;
	public static var screenOffsetX(default, null):Int = 0;
	public static var screenOffsetY(default, null):Int = 0;
	public static var gameScale(default, null):Float = 1; // this value will adjust according to khanvas dimensions
	public static var dt(default, null):Float = 0;
	public static var bgColor:Int = 0xff6495ed; // cornflower
	public static var frameBgColor:Int = 0xFFFFFFFF;

	static var currTime:Float = 0;
	static var prevTime:Float = 0;
	static var screens:Array<WynScreen> = [];
	static var screensToAdd:Array<WynScreen> = [];
	static var managers:Array<WynManager> = [];
	static var currScreen:WynScreen;
	static var screensLen:Int = 0;



	public function new (width:Int, height:Int, fitMode:Int=FIT_NONE)
	{
		// NOTE:
		// oriWidth/oriHeight are the original size of the game (without stretching to fit the mobile screens)
		// gameWidth/gameHeight is the actual screen size of the game (after applying fitMode)

		oriWidth = width;
		oriHeight = height;

		#if js

			setupHtml();

			if (IS_MOBILE)
			{
				// Due to varying mobile screen sizes, we usually 
				// would stretch the screen.
				setupScreen(width, height, fitMode);
			}
			else
			{
				// Don't fit to desktop browsers
				setupScreen(width, height, FIT_NONE);
			}

		#elseif (sys_ios || sys_android_native || sys_android)

			// Due to varying mobile screen sizes, we usually 
			// would stretch the screen.
			setupScreen(width, height, fitMode);

		#else

			// For desktop games, there's no need to stretch
			setupScreen(width, height, FIT_NONE);

		#end

		backbuffer = Image.createRenderTarget(gameWidth, gameHeight);
		g = backbuffer.g2;

		currTime = Scheduler.time();

		// Delay initialisation
		Scheduler.addTimeTask(function () {

			refreshGameScale();

		}, 1);
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

				Scheduler.addTimeTask(function () {

					refreshGameScale();
					if (onResize != null)
						onResize();

				}, 0.1);
			});

			var wyn = 'background:#ff69b4;color:#ffffff';
			var black = 'background:#ffffff;color:#000000';
			var kha = 'background:#2073d0;color:#fdff00';
			js.Browser.console.log('%cMade with %c wyngine %c\nPowered by %c kha ', black, wyn, black, kha);

			IS_MOBILE = untyped __js__("(function(a){if(/(android|bb\\d+|meego).+mobile|avantgo|bada\\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\\.(browser|link)|vodafone|wap|windows ce|xda|xiino|android|ipad|playbook|silk/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\\-(n|u)|c55\\/|capi|ccwa|cdm\\-|cell|chtm|cldc|cmd\\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\\-s|devi|dica|dmob|do(c|p)o|ds(12|\\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\\-|_)|g1 u|g560|gene|gf\\-5|g\\-mo|go(\\.w|od)|gr(ad|un)|haie|hcit|hd\\-(m|p|t)|hei\\-|hi(pt|ta)|hp( i|ip)|hs\\-c|ht(c(\\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\\-(20|go|ma)|i230|iac( |\\-|\\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\\/)|klon|kpt |kwc\\-|kyo(c|k)|le(no|xi)|lg( g|\\/(k|l|u)|50|54|\\-[a-w])|libw|lynx|m1\\-w|m3ga|m50\\/|ma(te|ui|xo)|mc(01|21|ca)|m\\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\\-2|po(ck|rt|se)|prox|psio|pt\\-g|qa\\-a|qc(07|12|21|32|60|\\-[2-7]|i\\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\\-|oo|p\\-)|sdk\\/|se(c(\\-|0|1)|47|mc|nd|ri)|sgh\\-|shar|sie(\\-|m)|sk\\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\\-|v\\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\\-|tdg\\-|tel(i|m)|tim\\-|t\\-mo|to(pl|sh)|ts(70|m\\-|m3|m5)|tx\\-9|up(\\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\\-|your|zeto|zte\\-/i.test(a.substr(0,4))){return true}else{return false}})(navigator.userAgent||navigator.vendor||window.opera);");

		#end
	}

	function setupScreen (width:Int, height:Int, fitMode:Int)
	{
		// NOTE:
		// Assume game screen is portrait, 420x940, but mobile screen is 768x1024.
		// Since target ratio is 3:4, the game screen will be resized to 705x940.
		// (940 / 4 * 3 = 705)
		// This means the game's width is stretched by ~68%, so you will have to
		// accomodate the extra dead space.

		// Another example:
		// Game screen is landscape, 320x240, mobile screen is 640x360.
		// target ratio is 16:9, so game screen is resized to 320x180.
		// This means game's height is shrunk by ~25%.

		if (fitMode != FIT_NONE)
		{
			// var windowW = kha.SystemImpl.khanvas.width;
			// var windowH = kha.SystemImpl.khanvas.height;
			var windowW = js.Browser.window.innerWidth;
			var windowH = js.Browser.window.innerHeight;

			if (fitMode == FIT_WIDTH)
			{
				// landscape
				var ratioH = width / windowW;
				height = Math.floor(windowH * ratioH);
			}
			else if (fitMode == FIT_HEIGHT)
			{
				// portrait
				var ratioW = height / windowH;
				width = Math.floor(windowW * ratioW);
			}
		}

		// this is the final size which can be used for your game.
		gameWidth = width;
		gameHeight = height;
	}

	static public function refreshGameScale ()
	{
		// This function ensures that when the game screen's buffer size does
		// not fit the actual screen size, we calculate the offset so that the
		// world position stays in sync.

		// Example:
		// Assume original screen size is 400x200, but screen size is 100x100
		// the buffer image will be 400x200 but scaled to fit into the 100x100,
		// causing a letterbox effect (top and bottom has 50px empty space),
		// and thus screenOffsetY will be 50.

		// always reset before rescaling
		screenOffsetX = 0;
		screenOffsetY = 0;

		var khanvasW = System.pixelWidth;
		var khanvasH = System.pixelHeight;

		var screenRatioW = khanvasW / gameWidth;
		var screenRatioH = khanvasH / gameHeight;
		gameScale = Math.min(screenRatioW, screenRatioH);
		var w = gameWidth * gameScale;
		var h = gameHeight * gameScale;

		if (screenRatioW > screenRatioH)
		{
			screenOffsetX = Math.floor((khanvasW/gameScale - gameWidth)/2);
		}
		else
		{
			screenOffsetY = Math.floor((khanvasH/gameScale - gameHeight)/2);
		}
	}

	public function update ()
	{
		// Make sure prev/curr time is updated to prevent time skips
		prevTime = currTime;
		currTime = Scheduler.time();

		if (!active)
			return;

		// Update delta time if we didn't return
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

		// Events will always trigger first, and we want screens
		// to react to the changes before the manager processes them.
		for (m in managers)
		{
			if (m.active)
				m.update();
		}
	}

	public function render (framebuffer:Framebuffer)
	{
		if (!visible)
			return;

		g.begin(true, bgColor); // cornflower

		g.imageScaleQuality = imageQuality;

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

		framebuffer.g2.begin(true, frameBgColor);
		framebuffer.g2.imageScaleQuality = imageQuality;
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