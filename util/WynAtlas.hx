package wyn.util;

import kha.Assets;
import kha.Image;
import kha.Blob;
import wyn.component.Region;
import haxe.xml.Fast;

class WynAtlas
{
	static var atlasDict:Map<String, AtlasData> = new Map<String, AtlasData>();

	public static function loadAtlasShoebox (atlasName:String, atlas:Image, xml:Blob)
	{
		var blobString:String = xml.toString();
		var fullXml:Xml = Xml.parse(blobString);
		var firstNode:Xml = fullXml.firstElement(); // <TextureAtlas>
		var data = new Fast(firstNode);

		var subTexturesDict = new Map<String, Region>();
		var subTexturesArr = new Array<Region>();

		for (st in data.nodes.SubTexture)
		{
			var region:Region = {
				x: Std.parseInt(st.att.x),
				y: Std.parseInt(st.att.y),
				w: Std.parseInt(st.att.width),
				h: Std.parseInt(st.att.height)
			};

			subTexturesDict.set(st.att.name, region);
			subTexturesArr.push(region);

			// trace("loaded : " + st.att.name);
		}

		var atlasData:AtlasData = {
			atlas: atlas,
			name: atlasName,
			regionMap: subTexturesDict,
			regionArr: subTexturesArr
		};

		atlasDict.set(atlasName, atlasData);
	}

	public static function getRegionByName (atlasName:String, subTextureName:String) : Region
	{
		if (atlasDict.exists(atlasName))
		{
			var atlasData:AtlasData = atlasDict.get(atlasName);
			if (atlasData.regionMap.exists(subTextureName))
				return atlasData.regionMap.get(subTextureName);
		}

		trace("getRegionByName not found : " + atlasName + " , " + subTextureName);
		return null;
	}

	public static function getRegionsByName (atlasName:String, subTextureNames:Array<String>) : Array<Region>
	{
		if (atlasDict.exists(atlasName))
		{
			var arr:Array<Region> = [];
			var atlasData:AtlasData = atlasDict.get(atlasName);

			for (name in subTextureNames)
			{
				if (atlasData.regionMap.exists(name))
					arr.push(atlasData.regionMap.get(name));
				else
					trace("subTexture not found : " + name);
			}

			return arr;
		}

		trace("getRegionByNames not found : " + atlasName);
		return null;
	}

	public static function getRegionByIndex (atlasName:String, index:Int) : Region
	{
		if (atlasDict.exists(atlasName))
		{
			var atlasData:AtlasData = atlasDict.get(atlasName);
			return atlasData.regionArr[index];
		}

		trace("getRegionByIndex not found : " + atlasName + " , " + index);
		return null;
	}
}