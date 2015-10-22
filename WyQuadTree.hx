package wy;

import kha.Color;
import kha.Rectangle;
import kha.graphics2.Graphics;

/**
 * Taken from here:
 * http://gamedevelopment.tutsplus.com/tutorials/quick-tip-use-quadtrees-to-detect-likely-collisions-in-2d-space--gamedev-374
 *
 * TODO
 * - recycle quadtrees instead of using new() every time we split
 */

class WyQuadTree
{
	public var DEBUG:Bool = true;
	public var MAX_OBJECTS:Int = 10;
	public var MAX_LEVELS:Int = 5;

	var level:Int;
	var objects:Array<WyObject>;
	var bounds:Rectangle;
	var nodes:Array<WyQuadTree>;
	var allObjects:Array<WyObject>; // master list for main quad checking

	/**
	 * @param 	level 		Node level. Topmost is 0.
	 * @param 	bounds 		Bounds of this QuadTree.
	 */
	public function new (level:Int, bounds:Rectangle)
	{
		this.level = level;
		this.objects = [];
		this.bounds = bounds;
		this.nodes = [null, null, null, null];
		this.allObjects = [];
	}

	/**
	 * Clears the quadtree and all its nodes.
	 */
	public function clear ()
	{
		objects = [];
		allObjects = [];

		for (i in 0 ... nodes.length)
		{
			if (nodes[i] != null)
			{
				// clear the node quadtree
				nodes[i].clear();
				nodes[i] = null;
			}
		}
	}

	/**
	 * Splits this quadtree into 4 nodes.
	 */
	function split ()
	{
		// smaller node's width/height
		var sw:Int = Std.int(bounds.width/2);
		var sh:Int = Std.int(bounds.height/2);
		var x:Int = Std.int(bounds.x);
		var y:Int = Std.int(bounds.y);

		/**
		 * Note: the node indices are ordered as such:
		 * 1 0
		 * 2 3
		 */
		nodes[0] = new WyQuadTree(level+1, new Rectangle(x+sw, y, sw, sh));
		nodes[1] = new WyQuadTree(level+1, new Rectangle(x, y, sw, sh));
		nodes[2] = new WyQuadTree(level+1, new Rectangle(x, y+sh, sw, sh));
		nodes[3] = new WyQuadTree(level+1, new Rectangle(x+sw, y+sh, sw, sh));
	}

	/**
	 * Returns which node index an item belongs in.
	 * If it cannot fit exactly in one node (exists in
	 * two or more nodes), returns -1.
	 */
	public function getIndex (object:WyObject)
	{
		var item:Rectangle = object._hitbox;

		var index:Int = -1;
		var midX:Float = bounds.x + (bounds.width / 2);
		var midY:Float = bounds.y + (bounds.height / 2);

		var topQuad:Bool = (item.y < midY && item.y + item.height < midY);
		var botQuad:Bool = (item.y > midY);

		if (item.x < midX && item.x + item.width < midX)
		{
			if (topQuad)
				index = 1;
			else if (botQuad)
				index = 2;
		}
		else if (item.x > midX)
		{
			if (topQuad)
				index = 0;
			else if (botQuad)
				index = 3;
		}

		return index;
	}

	/**
	 * Inserts an item into one of the quad tree's nodes.
	 * - If node exceeds MAX_OBJECTS
	 * 	- split into 4 quadtree nodes
	 * 	- add the item into that node instead.
	 */
	public function insert (object:WyObject)
	{
		// try to add to master list
		if (level == 0)
		{
			if (allObjects.indexOf(object) == -1)
				allObjects.push(object);
		}

		// If this quadtree has sub-quadtree nodes:
		if (nodes[0] != null)
		{
			var index:Int = getIndex(object);
			if (index != -1)
			{
				// add this object into the subnode
				nodes[index].insert(object);
				return;
			}
		}

		// If we reached here, that means we couldn't
		// add the object into the sub-quadtree, or there
		// is no sub-quadtree.
		objects.push(object);

		// If this quadtree has too many items:
		if (objects.length > MAX_OBJECTS && level < MAX_LEVELS)
		{
			// split into 4 quadtree nodes if there isn't any yet.
			if (nodes[0] == null)
				split();

			// for every item in THIS quadtree, distribute them
			// into the quadtree nodes
			var i:Int = 0;
			while (i < objects.length)
			{
				var index:Int = getIndex(objects[i]);
				if (index != -1)
				{
					nodes[index].insert(objects[i]);
					objects.splice(i,1); // removes from index i, inclusive i

					// NOTE: don't increment i because we modified
					// the object array by splicing
				}
				else
					i++;
			}
		}
	}

	/**
	 * Returns all the objects that collide with item, into returnObj
	 */
	public function retrieve (returnObj:Array<Dynamic>, item:WyObject) : Array<Dynamic>
	{
		// Which node does this item belong to? We'll recursively
		// run through this quadtree and return all other items
		// that also belong within this node.
		var index:Int = getIndex(item);

		// If this item belongs in sub quadtree, dive
		// into the node and check again
		if (index != -1 && nodes[0] != null)
			returnObj = nodes[index].retrieve(returnObj, item);

		// If this quadtree has no sub quadtrees, then we've
		// reached the last node. Add all its objects in this
		// quad into returnObj, and return it recursively.
		var result = returnObj.concat(objects);

		return result;
	}

	/**
	 * This will draw boxes for checking if collision works
	 *
	 * NOTE:
	 * - At level zero, you should not see the debug box because
	 * it's the whole screen anyway.
	 *
	 * - If the debug squares aren't showing, make sure to use
	 * clear() AFTER rendering, in which case, use clear() before
	 * you start processing (so the quadtree data lingers til it renders).
	 */
	public function drawDebug (g:Graphics)
	{
		if (!DEBUG)
			return;

		// draw this quadtree
		g.color = Color.Yellow;
		g.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);

		// recursively draw subnodes
		for (i in 0 ... 4)
		{
			if (nodes[i] != null)
				nodes[i].drawDebug(g);
		}
	}

	public function process (?callback:WyObject->WyObject->Void) : Bool
	{
		var hit:Bool = false;
		var returnObjs:Array<WyObject>;

		for (o1 in allObjects)
		{
			// Note: the list may contain duplicates
			returnObjs = [];
			returnObjs = cast retrieve(returnObjs, o1);

			if (returnObjs.length > 0)
			{
				for (o2 in returnObjs)
				{
					if (o1 != o2)
						hit = o1.collide(o2, callback);
				}
			}
		}

		return hit;
	}
}