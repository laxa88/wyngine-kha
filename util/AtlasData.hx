package wyn.util;

import kha.Image;
import wyn.component.Region;

typedef AtlasData = {
	var atlas:Image;
	var name:String;
	var regionMap:Map<String, Region>;
	var regionArr:Array<Region>;
}