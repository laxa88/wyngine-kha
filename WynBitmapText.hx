package wyn;

import kha.graphics2.Graphics;
import kha.Image;
import kha.Color;
import kha.Loader;
import kha.Blob;
import kha.math.FastVector2;
import haxe.xml.Fast;
import haxe.Utf8;

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
	@:optional var size:Int;
	@:optional var lineHeight:Int;
	@:optional var color:Color;
	@:optional var bgColor:Color;
	@:optional var align:Int;
}

class WynBitmapText extends WynSprite
{
	// Based on RafaelOliveira's BitmapText for kha:
	// https://github.com/RafaelOliveira/BitmapText/blob/master/lib/bitmapText/BitmapText.hx

	// TODO
	// cater for newlines - \n and \r characters

	// compile-time variables
	public static inline var ALIGN_LEFT:Int = 0;
	public static inline var ALIGN_MIDDLE:Int = 1;
	public static inline var ALIGN_RIGHT:Int = 2;
	static var spaceCharCode:Int = " ".charCodeAt(0);

	// Stores a list of all bitmap fonts into a dictionary
	static var fontCache:Map<String, Font>;
	
	public var text:String = "";
	var _prevText:String = "";
	var _cursor:FastVector2 = new FastVector2();

	// TODO - add getter/setter logic
	public var font(default, null):Font;
	public var size(default, null):Int;
	public var lineHeight(get, set):Int;
	public var align:Int = ALIGN_LEFT;
	public var trim:Bool = true; // trims trailing space characters



	/**
	 * Loads the bitmap font from Loader. Make sure you added it in project.kha.
	 * TODO: options parameter
	 */
	public function new (str:String, fontName:String, x:Int=0, y:Int=0, w:Int=200, h:Int=100)
	{
		super(x, y, w, h);

		text = str;

		if (fontCache != null && fontCache.exists(fontName))
		{
			font = fontCache.get(fontName);
			size = font.size;
			createEmptyImage(w, h);
		}
		else
		{
			loadFont(fontName);

			// Try to assign again once we're done loading font.
			if (fontCache != null && fontCache.exists(fontName))
			{
				font = fontCache.get(fontName);
				size = font.size;
				image = Image.createRenderTarget(w, h);
			}
			else
			{
				trace('Failed to init WynBitmapText with "${fontName}"');
			}
		}
	}

	public static function loadFont (fontName:String)
	{
		// NOTE: You can't do ${fontName} using double-quotes! ("")
		// You have to use single quotes! ('')

		var image = Loader.the.getImage('${fontName}.png');
		var data = Loader.the.getBlob('${fontName}.fnt');

		if (image != null && data != null)
			processFont(fontName, image, data);
		else
			trace('font "${fontName}" not found!');
	}

	inline static function processFont (fontName:String, image:Image, fntData:Blob)
	{
		// We'll store each letter's data into a dictionary here later.
		var letters = new Map<Int, Letter>();

		// Rafael's version of the code below
		// var xml = new haxe.xml.Fast(Xml.parse(data.toString()).firstElement());

		// For readability sake, I've written them seperately
		var blobString:String = fntData.toString();
		var fullXml:Xml = Xml.parse(blobString);
		var fontNode:Xml = fullXml.firstElement();
		var data = new Fast(fontNode);

		// what's this for?
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
			image: image, // the font image sheet
			letters: letters // each letter's data
		}

		// Add this font data to dictionary, finally.
		fontCache.set(fontName, font);
	}

	override public function update (dt:Float)
	{
		super.update(dt);

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

		image.g2.begin(true, Color.fromValue(0x00000000));
		image.g2.color = color;

		for (line in lines)
		{
			// NOTE:
			// Based on image.width and each line.width, we just
			// offset the starting cursor.x to make it look like
			// it's aligned to the correct side.
			switch (align)
			{
				case ALIGN_LEFT: _cursor.x = 0;
				case ALIGN_RIGHT: _cursor.x = image.width - line.width;
				case ALIGN_MIDDLE: _cursor.x = (image.width/2) - (line.width/2);
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

		// split words by spaces
		// E.g. "This is a word"
		// becomes ["this", "is", "a", "sentence"]
		var words = text.split(' ');
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
		var isBreakLine = false;
		var isLastWord = false;

		// Update the length of the words (inclusive of spaces)
		// E.g. ["this", " ", "is", " ", "a", " ", "sentence"] = 7
		wordsLen = words.length;

		for (i in 0 ... wordsLen)
		{
			// If we reached the last word, flag it.
			if (i == (wordsLen-1))
				isLastWord = true;

			// If this is a proper word, process it. Otherwise,
			// just add the values and move on.
			if (words[i] != " ")
			{
				var thisWord = words[i];
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
					}
				}
			}
			else
			{
				// For space characters, since they have no width,
				// we have to manually add the .spaceWidth value.
				currWord = " ";
				currWordWidth = font.spaceWidth;
			}

			// Check if the total width of the character needs to be wrapped.
			// If it's not a new line break, then add current word to
			// the line and move on. Otherwise, we'll use the current word
			// in the next line.
			if (currLineWidth + currWordWidth < image.width)
			{
				currLineText += currWord; // Add the word to the full line
				currLineWidth += currWordWidth; // Update the full width of the line
			}
			else
			{
				isBreakLine = true;
			}

			// If we reached the last word or reached a line break,
			// finalize current line and add it to the linesArray array.
			if (isBreakLine || isLastWord)
			{
				// Add current line to the final array.
				linesArray.push({
					text: currLineText,
					width: currLineWidth
				});

				// If this is NOT the last word, but it's a line break:
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
						// Ignore the space; Reset the current
						// word and move to next line.
						currLineText = "";
						currLineWidth = 0;
					}

					// Trim the end of current line
					if (trim) trimLastLine(linesArray);

					isBreakLine = false;
				}
				else if (isBreakLine)
				{
					// If this is the last word and is a line break, then
					// add the last word to the next line, then finalise.

					if (trim) trimLastLine(linesArray);

					linesArray.push({
						text: currWord,
						width: currWordWidth
					});
				}
			}

			// move to next word
			currWord = "";
			currWordWidth = 0;
		}

		return linesArray;
	}

	/**
	 * Trims the line - removes spaces from the end of the text.
	 */
	function trimLastLine (lines:Array<Line>)
	{
		// Get last char. I'm writing 4 lines for readability sake.
		var lastLine:Line = lines[lines.length - 1];
		var i = lastLine.text.length-1;
		var char:String = lastLine.text.charAt(i);

		// If the last character is a space, remove it,
		// and reduce the width of the line.
		while (char == " ")
		{
			// Remove this space character
			lastLine.text = lastLine.text.substr(0, lastLine.text.length-1);
			lastLine.width -= font.spaceWidth;

			// Move one character backwards and check again
			i--;
			char = lastLine.text.charAt(i);
		}

		// Trim from the front as well
		char = lastLine.text.charAt(0);
		while (char == " ")
		{
			lastLine.text = lastLine.text.substr(1);
			lastLine.width -= font.spaceWidth;

			char = lastLine.text.charAt(0);
		}
	}

	override public function render (g:Graphics)
	{
		super.render(g);
	}

	override public function destroy ()
	{
		super.destroy();

		// TODO
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