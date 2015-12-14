package wyn;

import kha.Image;
import kha.Color;
import kha.Assets;
import kha.Blob;
import kha.math.FastVector2;
import haxe.xml.Fast;
import haxe.Utf8;

/**
	Tip on how to generate Bitmap font, for Windows AND Mac:
	- use BMFont.exe (www.angelcode.com/products/bmfont/)
	- For mac, install Wine (easily install via Brew)
	- My setup for BMFont:
		- go to Options > Font Settings
		- Load font (make sure the font is installed)
		- Leave everything as default
		- go to Options > Export Options
		- CHECK Force offsets to zero (quirk: if unchecked, letter kernings may get weird)
		- Make sure texture size is big enough, so that all letters fit in one graphic (mine is 512x512)
		- Bit depth = 32
		- Channel - A = glyph, R/G/B = one
		- Presets - White text with alpha
		- Font description - XML (required for WynBitmapText to parse data)
		- Textures - PNG
	- Once done setup, just click Options > Save bitmap font as...
	- Copy the generated PNG and FNT file to your kha assets folder and use normally.
 */

typedef Font = {
	var size:Int;
	var lineHeight:Int;
	var spaceWidth:Int;
	var image:Image;
	var letters:Map<Int, Letter>;
}

typedef Letter = {
	var id:Int;
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
	var xoffset:Int;
	var yoffset:Int;
	var xadvance:Int;
	var kernings:Map<Int, Int>;
}

typedef Line = {
	var text:String;
	var width:Int;
}

typedef Options = {
	@:optional var color:Color;
	@:optional var halign:Int;
	@:optional var valign:Int;
}

class WynBitmapText extends WynSprite
{
	// Based on RafaelOliveira's BitmapText for kha:
	// https://github.com/RafaelOliveira/BitmapText/blob/master/lib/bitmapText/BitmapText.hx

	// compile-time variables
	public static inline var HALIGN_LEFT:Int = 0;
	public static inline var HALIGN_MIDDLE:Int = 1;
	public static inline var HALIGN_RIGHT:Int = 2;

	public static inline var VALIGN_TOP:Int = 0;
	public static inline var VALIGN_CENTER:Int = 1;
	public static inline var VALIGN_BOTTOM:Int = 2;

	static var spaceCharCode:Int = " ".charCodeAt(0);

	// Stores a list of all bitmap fonts into a dictionary
	static var fontCache:Map<String, Font>;
	
	public var text:String = "";
	var _prevText:String = "";
	var _cursor:FastVector2 = new FastVector2();

	public var font(default, null):Font;
	public var halign:Int = HALIGN_LEFT;
	public var valign:Int = VALIGN_TOP;
	public var trimEnds:Bool = true; // trims trailing space characters
	public var trimAll:Bool = true; // trims ALL space characters (including mid-sentence)



	/**
	 * Loads the bitmap font from cache. Remember to call loadFont first before
	 * creating new WynBitmapTexts.
	 */
	public function new (str:String, fontName:String, x:Float=0, y:Float=0, w:Int=200, h:Int=100, ?option:Options)
	{
		super(x, y, w, h);

		if (fontCache != null && fontCache.exists(fontName))
		{
			text = str;

			font = fontCache.get(fontName);
			createEmptyImage(w, h, true);

			if (option != null)
			{
				if (option.color != null)
					color = option.color;

				if (option.halign != null)
					halign = option.halign;

				if (option.valign != null)
					valign = option.valign;
			}
		}
		else
		{
			// If the fontCache or fontName doesn't exist, fail silently!
			trace('Failed to init WynBitmapText with "${fontName}"');
		}
	}

	/**
	 * Do this first before creating new WynBitmapText, because we
	 * need to process the font data before using.
	 */
	public static function loadFont (fontName:String, fontImage:Image, fontData:Blob)
	{
		// NOTE: You can't do ${fontName} using double-quotes! ("")
		// You have to use single quotes! ('')

		// We'll store each letter's data into a dictionary here later.
		var letters = new Map<Int, Letter>();

		// Rafael's version of the code below
		// var xml = new haxe.xml.Fast(Xml.parse(data.toString()).firstElement());

		// For readability sake, I've written them seperately
		var blobString:String = fontData.toString();
		var fullXml:Xml = Xml.parse(blobString);
		var fontNode:Xml = fullXml.firstElement();
		var data = new Fast(fontNode);

		// If the font file doesn't have a " " character,
		// this will be a default spacing for it.
		var spaceWidth = 8;

		// NOTE: Each of these attributes are in the .fnt XML data.
		var chars = data.node.chars;
		for (char in chars.nodes.char)
		{
			var letter:Letter = {
				id: Std.parseInt(char.att.id),
				x: Std.parseInt(char.att.x),
				y: Std.parseInt(char.att.y),
				width: Std.parseInt(char.att.width),
				height: Std.parseInt(char.att.height),
				xoffset: Std.parseInt(char.att.xoffset),
				yoffset: Std.parseInt(char.att.yoffset),
				xadvance: Std.parseInt(char.att.xadvance),
				kernings: new Map<Int, Int>()
			}

			// NOTE on xadvance:
			// http://www.angelcode.com/products/bmfont/doc/file_format.html
			// xadvance is the padding before the next character
			// is rendered. Spaces may have no width, so we assign
			// them here specifically for use later. Otherwise,
			// every other letter data has no spaceWidth value.
			if (letter.id == spaceCharCode)
				spaceWidth = letter.xadvance;

			// Save the letter's data into the dictioanry
			letters.set(letter.id, letter);
		}

		// If this fnt XML has kerning data for each letter,
		// process them here. Kernings are UNIQUE padding
		// between each letter to create a pleasing visual.
		// As an idea, Bevan.ttf has about 1000+ kerning data.
		if (data.hasNode.kernings)
		{
			var kernings = data.node.kernings;
			var letter:Letter;
			for (kerning in kernings.nodes.kerning)
			{
				var firstId = Std.parseInt(kerning.att.first);
				var secondId = Std.parseInt(kerning.att.second);
				var amount = Std.parseInt(kerning.att.amount);

				letter = letters.get(firstId);
				letter.kernings.set(secondId, amount);
			}
		}

		// Create the dictionary if it doesn't exist yet
		if (fontCache == null)
			fontCache = new Map<String, Font>();

		// Create new font data
		var font:Font = {
			size: Std.parseInt(data.node.info.att.size), // this original size this font's image was exported as
			lineHeight: Std.parseInt(data.node.common.att.lineHeight), // original vertical padding between texts
			spaceWidth: spaceWidth, // remember, this is only for space character
			image: fontImage, // the font image sheet
			letters: letters // each letter's data
		}

		// Add this font data to dictionary, finally.
		fontCache.set(fontName, font);
	}

	override public function update ()
	{
		super.update();

		// Don't proceed if font not loaded
		if (font == null)
			return;

		// Only redraw the text if the text changed,
		// to save on draw calls.
		if (text != _prevText)
		{
			updateText();
			_prevText = text;
		}
	}

	function updateText ()
	{
		// Wrap and break the lines by width.
		var lines = processText();

		// Reset cursor position
		_cursor = new FastVector2();

		image.g2.begin(true, 0x00000000);
		image.g2.color = color;

		switch (valign)
		{
			case VALIGN_TOP: _cursor.y = 0;
			case VALIGN_CENTER: _cursor.y = (imageHeight/2) - (lines.length*font.lineHeight/2);
			case VALIGN_BOTTOM: _cursor.y = imageHeight - font.lineHeight;
		}

		for (line in lines)
		{
			// NOTE:
			// Based on image.width and each line.width, we just
			// offset the starting cursor.x to make it look like
			// it's aligned to the correct side.
			switch (halign)
			{
				case HALIGN_LEFT: _cursor.x = 0;
				case HALIGN_RIGHT: _cursor.x = image.width - line.width;
				case HALIGN_MIDDLE: _cursor.x = (image.width/2) - (line.width/2);
			}

			var lineText:String = line.text;
			var lineTextLen:Int = lineText.length;

			for (i in 0 ... lineTextLen)
			{
				var char = lineText.charAt(i); // get letter
				var charCode = Utf8.charCodeAt(char, 0); // get letter id
				var letter = font.letters.get(charCode); // get letter data

				// If the letter data exists, then we will render it.
				if (letter != null)
				{
					if (letter.id != spaceCharCode)
					{
						// If the letter is NOT a space, then render it.
						var renderX = _cursor.x + letter.xoffset * scale;
						var renderY = _cursor.y + letter.yoffset * scale;
						var renderW = letter.width * scale;
						var renderH = letter.height * scale;

						image.g2.drawScaledSubImage(
							font.image,
							letter.x,
							letter.y,
							letter.width,
							letter.height,
							renderX,
							renderY,
							renderW,
							renderH);

						if (Wyngine.DEBUG_DRAW)
							image.g2.drawRect(renderX, renderY, renderW, renderH);

						// Add kerning if it exists. Also, we don't have to
						// do this if we're already at the last character.
						if (i != lineTextLen)
						{
							// Get next char's code
							var charNext = lineText.charAt(i+1);
							var charCodeNext = Utf8.charCodeAt(charNext, 0);

							// If kerning data exists, adjust the cursor position.
							if (letter.kernings.exists(charCodeNext))
							{
								_cursor.x += letter.kernings.get(charCodeNext) * scale;
							}
						}

						// Move cursor to next position, with padding.
						_cursor.x += letter.xadvance * scale;
					}
					else
					{
						// If this is a space character, move cursor
						// without rendering anything.
						_cursor.x += font.spaceWidth * scale;
					}
				}
				else
				{
					Wyngine.log("letter data doesn't exist");
				}

				// Don't render anything if the letter data doesn't exist.
			}

			// After we finish rendering this line, move on to
			// the next line.
			_cursor.y += font.lineHeight * scale;
		}

		image.g2.end();
	}

	/**
	 * This method basically helps wrap your text automatically
	 * based on its width.
	 */
	function processText () : Array<Line>
	{
		// Array of lines that will be returned.
		var linesArray = new Array<Line>();

		// Test the regex here: https://regex101.com/
		var trim1 = ~/^ +| +$/g; // removes all spaces at beginning and end
		var trim2 = ~/ +/g; // merges all spaces into one space
		var fullText = text;
		if (trimAll)
		{
			fullText = trim1.replace(fullText, ""); // remove trailing spaces first
			fullText = trim2.replace(fullText, " "); // merge all spaces into one
		}
		else if (trimEnds)
		{
			fullText = trim1.replace(fullText, "");
		}

		// split words by spaces
		// E.g. "This is a sentence"
		// becomes ["this", "is", "a", "sentence"]
		var words = fullText.split(' ');
		var wordsLen = words.length;
		var j = 1;

		// Add a space word in between every word.
		// E.g. ["this", "is", "a", "sentence"]
		// becomes ["this", " ", "is", " ", "a", " ", "sentence"]
		for (i in 0 ... wordsLen)
		{
			if (i != (wordsLen-1))
			{
				words.insert(i+j, ' ');
				j++;
			}
		}

		// Reusable variables
		var char:String;
		var charCode:Int;
		var letter:Letter;
		var currLineText = "";
		var currLineWidth = 0;
		var currWord = "";
		var currWordWidth = 0;
		var isBreakFirst = false;
		var isBreakLater = false;
		var isLastWord = false;
		var reg = ~/[\n\r]/; // gets first occurence of line breaks
		var i = 0;
		var len = words.length;
		var lastLetterPadding = 0;

		while (i < words.length)
		{
			var thisWord = words[i];
			lastLetterPadding = 0;

			// If newline character exists, split the word for further
			// checking in the subsequent loops.
			if (reg.match(thisWord))
			{
				var splitIndex = reg.matchedPos();
				var splitWords = reg.split(thisWord);
				var firstWord = splitWords[0];
				var remainder = splitWords[1];

				// Replace current word with the splitted word
				words[i] = thisWord = firstWord;

				// Insert the remainder of the word into next index
				// and we'll check it again later.
				words.insert(i+1, remainder);

				// Flag to break AFTER we process this word.
				isBreakLater = true;
			}
			else if (i == words.length-1)
			{
				// If the word need not be split, then check if this
				// is the last word. If yes, then we can finalise this
				// line at the end.
				isLastWord = true;
			}

			// If this is a non-space word, let's process it.
			if (thisWord != " ")
			{
				for (charIndex in 0 ... thisWord.length)
				{
					char = thisWord.charAt(charIndex);
					charCode = Utf8.charCodeAt(char, 0);

					// Get letter data based on the charCode key
					letter = font.letters.get(charCode);

					// If the letter data exists, append it to the current word.
					// Then add the letter's padding to the overall word width.
					// If the letter data doesn't exist, then just skip without
					// altering the currWord or currWordWidth.
					if (letter != null)
					{
						currWord += char;
						currWordWidth += letter.xadvance;

						// If this is the last letter for the line, remember
						// the padding so that we can add to the currLineWidth later.
						lastLetterPadding = letter.width - letter.xadvance;
					}
				}
			}
			else
			{
				// For space characters, usually they have no width,
				// we have to manually add the .spaceWidth value.
				currWord = " ";
				currWordWidth = font.spaceWidth;
			}

			// After adding current word to the line, did it pass
			// the text width? If yes, flag to break. Otherwise,
			// just update the current line.
			if (currLineWidth + currWordWidth < image.width)
			{
				currLineText += currWord; // Add the word to the full line
				currLineWidth += currWordWidth; // Update the full width of the line
			}
			else
			{
				isBreakFirst = true;
			}

			// If we need to break the line first, add the
			// current line to the array first, then add the
			// current word to the next line.
			if (isBreakFirst || isLastWord)
			{
				// Add padding so the last letter doesn't get chopped off
				currLineWidth += lastLetterPadding;

				// Add current line (sans current word) to array
				linesArray.push({
					text: currLineText,
					width: currLineWidth
				});

				// If this isn't the last word, then begin the next
				// line with the current word.
				if (!isLastWord)
				{
					// If current word is a proper word:
					if (currWord != " ")
					{
						// Next line begins with the current word
						currLineText = currWord;
						currLineWidth = currWordWidth;
					}
					else
					{
						// Ignore spaces; Reset the next line.
						currLineText = "";
						currLineWidth = 0;
					}

					isBreakFirst = false;
				}
				else if (isBreakFirst)
				{
					// If this is the last word, then just push it
					// to the next line and finish up.
					linesArray.push({
						text: currWord,
						width: currWordWidth
					});
				}

				// trim the text at start and end of the last line
				if (trimAll) trim1.replace(linesArray[linesArray.length-1].text, "");
			}

			// If we need to break the line AFTER adding the current word
			// to the current line, do it here.
			if (isBreakLater)
			{
				// Add padding so the last letter doesn't get chopped off
				currLineWidth += lastLetterPadding;

				// add current line to array, whether it has already
				// previously been broken to new line or not.

				linesArray.push({
					text: currLineText,
					width: currLineWidth
				});

				// Start next line afresh.
				currLineText = "";
				currLineWidth = 0;

				isBreakLater = false;
			}

			// move to next word
			currWord = "";
			currWordWidth = 0;

			// Move to next iterator.
			i++;
		}

		return linesArray;
	}

	override public function render (c:WynCamera)
	{
		super.render(c);
	}

	override public function destroy ()
	{
		super.destroy();

		font = null;
		_cursor = null;
	}



	private function get_lineHeight () : Int
	{
		return font.lineHeight;
	}
	private function set_lineHeight (val:Int) : Int
	{
		return (font.lineHeight = val);
	}
}