package wyn;

import haxe.xml.Fast;
import kha.Blob;
import kha.Loader;

// Stopped here
// - clean up xml reading
// - find out if can dynamically reload resource

class WynFile
{
	public static function loadFile (filename:String)
	{
		// This is used for loading custom data files, like
		// JSON or text files
		// var data:Blob = Loader.the.getBlob(filename);

		// var foo:Array<String> = Std.string(data).split("\n");

		// Wy.log("Done load file : " + data);
		// Wy.log("Done load file : " + foo[0]);


		// // for testing only
		// var data2:Blob = Loader.the.getBlob("dataxml");
		// var xml:Xml = Xml.parse(data2.toString());
		// var fast:Fast = new Fast(xml.firstElement());
		// Wy.log("# : " + fast.att.myAttr);
		// var catalog = fast.node.catalog;
		// for (item in catalog.nodes.item) {
		// 	Wy.log(item.innerData);
		// }
	}

	public static function reloadFile ()
	{
		// Loader.the.initProject();
		// loadFile("");

		// Loader.the.loadProject(function () {
		// 	Wy.log("reloaded!");
		// 	loadFile("");
		// });

		// Loader.the.loadFiles(function () {
		// 	Wy.log("reloaded!");
		// 	loadFile("");
		// }, true);
	}
}