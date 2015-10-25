package wyn;

import kha.Color;
import kha.Rectangle;
import kha.graphics2.Graphics;

/**
 * v1: Taken from here:
 * http://gamedevelopment.tutsplus.com/tutorials/quick-tip-use-quadtrees-to-detect-likely-collisions-in-2d-space--gamedev-374
 *
 * v2: Influence by HaxeFlixel:
 * allow group-group, single-group, or single-single comparisons.
 *
 * TODO
 * - recycle quadtrees instead of using new() every time we split
 */

class WynQuadTree
{
	public static inline var DEBUG:Bool = false;
	public static inline var LIST_A:Int = 0;
	public static inline var LIST_B:Int = 1;
	public static inline var MAX_OBJECTS:Int = 10;
	public static inline var MAX_LEVELS:Int = 6;

	public var active:Bool;

	var _nodes:Array<WynQuadTree>;
	var _level:Int;
	var _listA:Array<WynObject>;
	var _listB:Array<WynObject>;
	var _quadTop:Float;
	var _quadRight:Float;
	var _quadBottom:Float;
	var _quadHalfWidth:Float;
	var _quadHalfHeight:Float;
	var _quadMidX:Float;
	var _quadMidY:Float;

	// Reusable variables across all quadtrees.
	private static var _qtPool:Array<WynQuadTree>;
	private static var _list:Int;
	private static var _useBothLists:Bool;
	private static var _callback:WynObject->WynObject->Void;
	private static var _object:WynObject;
	private static var _objectLeft:Float;
	private static var _objectTop:Float;
	private static var _objectRight:Float;
	private static var _objectBottom:Float;
	private static var _quadLeft:Float;
	private static var _listI:Array<WynObject>; // reusable for execute() purposes only



	/**
	 * Let reset() do the rest.
	 */
	public function new (level:Int, x:Float, y:Float, w:Float, h:Float)
	{
		// Reset variables once
		reset(level, x, y, w, h);
	}

	/**
	 * Entry point for a new pooled quadtree
	 */
	public function reset (level:Int, x:Float, y:Float, w:Float, h:Float)
	{
		this.active = true;

		_level = level;
		_nodes = [null, null, null, null];
		_quadLeft = x;
		_quadTop = y;
		_quadRight = x + w;
		_quadBottom = y + h;
		_quadHalfWidth = w/2;
		_quadHalfHeight = h/2;
		_quadMidX = _quadLeft + _quadHalfWidth;
		_quadMidY = _quadTop + _quadHalfHeight;
	}

	/**
	 * This is usually only called once -- on the root quadtree,
	 * after we're done executing collision checks.
	 */
	public function destroy ()
	{
		// Recursively destroy child quadtrees
		for (i in 0 ... _nodes.length)
		{
			if (_nodes[i] != null)
			{
				_nodes[i].destroy();
				_nodes[i] = null;
			}
		}

		// Reset variables
		active = false;

		_level = 0;
		_nodes = [null, null, null, null];
		_listA = [];
		_listB = [];

		// Clear static variables.
		_useBothLists = false;
		_object = null;
		_listI = null;
		_callback = null;
	}

	/**
	 * Step 1 of using quadtrees - get an available quadtree.
	 */
	public static function recycle (level:Int, x:Float, y:Float, w:Float, h:Float) : WynQuadTree
	{
		if (_qtPool == null)
			_qtPool = [];

		// Use pooled quadtrees
		for (i in 0 ... _qtPool.length)
		{
			if (!_qtPool[i].active)
			{
				_qtPool[i].reset(level, x, y, w, h);
				return _qtPool[i];
			}
		}

		// If none available, create new ones
		var quadtree = new WynQuadTree(level, x, y, w, h);
		_qtPool.push(quadtree);
		return quadtree;
	}

	/**
	 * Step 2 of using quadtrees - load items.
	 */ 
	public function load (o1:WynObject, o2:WynObject=null, callback:WynObject->WynObject->Void)
	{
		// By default, add all members from first list.
		add(o1, LIST_A);

		// Flag if we're using members from second list.
		if (o2 != null)
		{
			// If we're comparing two lists, we take each
			// item from LIST_A and compare them to each
			// item in LIST_B using the quadtrees
			add(o2, LIST_B);
			_useBothLists = true;
		}
		else
		{
			// If we're only comparing one list, then compare
			// the items within itself.
			_useBothLists = false;
		}

		// Assign a callback each time a collision occurs.
		_callback = callback;
	}

	/**
	 * This internal method resolves grouped objects (if it is)
	 * recursively and adds each single object into the smallest
	 * quadtree quadrant that it can fit. This is slightly different
	 * from the typical quadtree -- it'll traverse as deep as possible
	 * as long as it can fit completely into the smallest quadrant.
	 * This probably is a performance boost, because it won't create
	 * unnecessary quadtrees when the current node needs to be split.
	 */
	function add (objectOrGroup:WynObject, list:Int)
	{
		// Store reference once, which will be used
		// for the rest of this scope anyway.
		_list = list;

		// Resolve this object type first
		var group = WynGroup.resolveGroup(objectOrGroup);

		// If this is a group, add every of its members into
		// quadtree list, or if its members are groups too,
		// do a recursive add().
		if (group != null)
		{
			// Iterate the group and add each member
			var members:Array<WynObject> = group.members;

			for (member in members)
			{
				group = WynGroup.resolveGroup(member);
				if (group != null)
				{
					// If this object's members are also groups, then
					// call this recursively until we reach single objects
					add(group, list);
				}
				else
				{
					// Finally, this is a single object, so add it to the quadtree's list.

					// Explicitly cast this member as a WynObject, because we
					// don't care for other types such as WynSprite or WynText.
					_object = cast (member, WynObject);
					if (_object.exists)
					{
						_objectLeft = _object.x;
						_objectTop = _object.y;
						_objectRight = _object.x + _object.width;
						_objectBottom = _object.y + _object.height;
						addObject();
					}
				}
			}
		}
	}

	/**
	 * A more readable version of HaxeFlixel's addObject()
	 */
	public function addObject ()
	{
		// If we reached the deepest possible leaf, add the object finally.
		if (_level == MAX_LEVELS)
		{
			addToList();
			return;
		}

		// If the object overlaps the whole quadrant, then no point checking.
		// Add the object to this quadtree.
		if ((_objectLeft<=_quadLeft) && (_objectRight>=_quadRight) &&
			(_objectTop<=_quadTop) && (_objectBottom>=_quadBottom))
		{
			addToList();
			return;
		}

		// Otherwise, try to insert the object completely inside a quadrant.
		var topQuad:Bool = (_objectBottom < _quadMidY);
		var botQuad:Bool = (_objectTop > _quadMidY);
		var leftQuad:Bool = (_objectRight < _quadMidX);
		var rightQuad:Bool = (_objectLeft > _quadMidX);

		if (topQuad && rightQuad)
		{
			if (_nodes[0] == null)
				_nodes[0] = recycle(_level+1, _quadMidX, _quadTop, _quadHalfWidth, _quadHalfHeight);
			_nodes[0].addObject();
			return;
		}
		if (topQuad && leftQuad)
		{
			if (_nodes[1] == null)
				_nodes[1] = recycle(_level+1, _quadLeft, _quadTop, _quadHalfWidth, _quadHalfHeight);
			_nodes[1].addObject();
			return;
		}
		if (botQuad && leftQuad)
		{
			if (_nodes[2] == null)
				_nodes[2] = recycle(_level+1, _quadLeft, _quadMidY, _quadHalfWidth, _quadHalfHeight);
			_nodes[2].addObject();
			return;
		}
		if (botQuad && rightQuad)
		{
			if (_nodes[3] == null)
				_nodes[3] = recycle(_level+1, _quadMidX, _quadMidY, _quadHalfWidth, _quadHalfHeight);
			_nodes[3].addObject();
			return;
		}

		// If none of the above conditions are met, it means the object
		// overlaps 2, 3 or 4 quadrants simultaneously. For every quad
		// that it overlaps, add to those quadtrees each. Typically,
		// we should reach MAX_LEVELS eventually.
		var overlapsRight = (_objectRight>_quadMidX) && (_objectLeft<_quadRight);
		var overlapsLeft = (_objectRight>_quadLeft) && (_objectLeft<_quadMidX);
		var overlapsTop = (_objectBottom>_quadTop) && (_objectTop<_quadMidY);
		var overlapsBottom = (_objectBottom>_quadMidY) && (_objectTop<_quadBottom);

		if (overlapsTop && overlapsLeft)
		{
			if (_nodes[1] == null)
				_nodes[1] = recycle(_level+1, _quadLeft, _quadTop, _quadHalfWidth, _quadHalfHeight);
			_nodes[1].addObject();
		}
		if (overlapsTop && overlapsRight)
		{
			// object exists in top-right
			if (_nodes[0] == null)
				_nodes[0] = recycle(_level+1, _quadMidX, _quadTop, _quadHalfWidth, _quadHalfHeight);
			_nodes[0].addObject();
		}
		if (overlapsBottom && overlapsLeft)
		{
			// object exists in bottom-right
			if (_nodes[2] == null)
				_nodes[2] = recycle(_level+1, _quadLeft, _quadMidY, _quadHalfWidth, _quadHalfHeight);
			_nodes[2].addObject();
		}
		if (overlapsBottom && overlapsRight)
		{
			if (_nodes[3] == null)
				_nodes[3] = recycle(_level+1, _quadMidX, _quadMidY, _quadHalfWidth, _quadHalfHeight);
			_nodes[3].addObject();
		}
	}

	/**
	 * This method is only called when an object reaches the
	 * last possible leaf in the quadtree.
	 */
	public function addToList ()
	{
		// Add object to this quad's list
		if (_list == LIST_A)
			_listA.push(_object);
		else if (_list == LIST_B)
			_listB.push(_object);

		// If we called this method WHILE the quad has children anyway,
		// it probably means the object overlaps the quad completely; Thus
		// all of this quad's children should also contain the object.
		for (i in 0 ... 4)
		{
			if (_nodes[i] != null)
				_nodes[i].addToList();
		}
	}

	/**
	 * Step 3 of using quadtrees - process all collisions.
	 */
	public function execute () : Bool
	{
		var hit:Bool = false;

		// Reusable variables for comparing
		// var list1:Array<WynObject>;
		// var list2:Array<WynObject>;
		var len1:Int;
		// var len2:Int;

		// If this quadtree has items, check for collisions.
		if (_listA.length > 1)
		{
			len1 = _listA.length;

			for (index1 in 0 ... len1)
			{
				// Reset second list every loop
				_listI = null;

				// Set target object to be compared to
				_object = _listA[index1];

				// Do we compare listA to listA, or listA to listB?
				if (_useBothLists)
				{
					_listI = _listB;
				}
				else
				{
					if (_listA.length > index1+1)
						_listI = _listA.slice(index1+1); // shallow copy from index 1 to end of array
				}

				// HaxeFlixel does some stuff that I can't understand via
				// overlapNode(), so here's my own attempt at collision
				// checking.
				if (_object != null && _object.exists)
				{
					// Let another function handle the interaction
					// between _object and _listI
					if (overlapNode())
						hit = true;
				}
			}
		}

		// Recursively call the execute() for every valid quadtree.
		for (i in 0 ... 4)
		{
			if (_nodes[i] != null)
				_nodes[i].execute();
		}

		// If at least one of the above compared list items
		// overlapped, then this will return true.
		return hit;
	}

	/**
	 * Collision logic goes here. TBH it's complicated but caters
	 * to a lot of use cases. For now, we don't need those, so I'll
	 * default to simple rect checks.
	 *
	 * TODO:
	 * - upgrade to HaxeFlixel version, which considers large
	 * movement displace between current and last-position of objects,
	 * where they use objectHull for collision checks.
	 * - upgrade to HaxeFlixel version, which also caters
	 * for object separation logic (checks immovable, separates)
	 * 
	 */
	function overlapNode () : Bool
	{
		var hit:Bool = false;
		var len2:Int = _listI.length;
		var o2:WynObject;

		for (i in 0 ... len2)
		{
			o2 = _listI[i];

			// Don't compare to self
			if (_object == o2)
				continue;

			// Don't compare with others that don't exist
			if (!o2.exists)
				continue;

			// Compare now (copied from kha.Rectangle)
			var hitHoriz:Bool;
			var hitVert:Bool;

			if (_object.x < o2.x)
				hitHoriz = o2.x < (_object.x + _object.width);
			else
				hitHoriz = _object.x < (o2.x + o2.width);

			if (_object.y < o2.y)
				hitVert = o2.y < (_object.y + _object.height);
			else
				hitVert = _object.y < (o2.y + o2.height);

			hit = hitHoriz && hitVert;
		}

		return hit;
	}
}