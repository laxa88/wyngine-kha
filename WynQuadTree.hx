package wyn;

import kha.Color;

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
	public static inline var LIST_A:Int = 0;
	public static inline var LIST_B:Int = 1;
	public static var MAX_OBJECTS:Int = 10;
	public static var MAX_LEVELS:Int = 5;
	public static var ID_COUNTER:Int=0;
	public var id:Int; // for debugging
	public var active:Bool;

	var _nodes:Array<WynQuadTree>;
	var _level:Int;
	public var _listA:Array<WynObject>;
	public var _listB:Array<WynObject>;
	var _quadLeft:Float;
	var _quadTop:Float;
	var _quadRight:Float;
	var _quadBottom:Float;
	var _quadHalfWidth:Float;
	var _quadHalfHeight:Float;
	var _quadMidX:Float;
	var _quadMidY:Float;

	// For collision checks, considering with offsets
	private static var o1X:Float = 0;
	private static var o1Y:Float = 0;
	private static var o1W:Float = 0;
	private static var o1H:Float = 0;
	private static var o2X:Float = 0;
	private static var o2Y:Float = 0;
	private static var o2W:Float = 0;
	private static var o2H:Float = 0;

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
	private static var _listI:Array<WynObject>; // reusable for execute() purposes only



	/**
	 * Let reset() do the rest.
	 */
	public function new (level:Int, x:Float, y:Float, w:Float, h:Float, ?parent:WynQuadTree)
	{
		// Reset variables once
		reset(level, x, y, w, h, parent);

		id = ++ID_COUNTER;
	}

	/**
	 * Step 1 of using quadtrees - get an available quadtree.
	 */
	public static function recycle (level:Int, x:Float, y:Float, w:Float, h:Float, ?parent:WynQuadTree) : WynQuadTree
	{
		if (_qtPool == null)
			_qtPool = [];

		// Use pooled quadtrees
		for (i in 0 ... _qtPool.length)
		{
			if (!_qtPool[i].active)
			{
				_qtPool[i].reset(level, x, y, w, h, parent);
				return _qtPool[i];
			}
		}

		// If none available, create new ones
		var quadtree = new WynQuadTree(level, x, y, w, h, parent);
		_qtPool.push(quadtree);
		return quadtree;
	}

	/**
	 * Entry point for a new pooled quadtree
	 */
	public function reset (level:Int, x:Float, y:Float, w:Float, h:Float, ?parent:WynQuadTree)
	{
		this.active = true;

		_level = level;
		_nodes = [null, null, null, null];
		_listA = [];
		_listB = [];
		_quadLeft = x;
		_quadTop = y;
		_quadRight = x + w;
		_quadBottom = y + h;
		_quadHalfWidth = w/2;
		_quadHalfHeight = h/2;
		_quadMidX = _quadLeft + _quadHalfWidth;
		_quadMidY = _quadTop + _quadHalfHeight;

		// Copy the parent quadtree's children, if there's any.
		// This ensures that objects previously added in the parent
		// quadtree is is carried down to the children.
		// Cases where this may happen are when an object is too large
		// and added to the parent quadrant without going another level
		// deeper.

		if (parent != null)
		{
			// Shallow copy the parrent list's objects
			if (parent._listA != null)
				_listA = parent._listA.slice(0);

			if (parent._listB != null)
				_listB = parent._listB.slice(0);
		}
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
				// Filter out by only processing only necessary members
				if (member.exists)
					add(member, list);
			}
		}
		else
		{
			// Finally, this is a single object, so add it to the quadtree's list.
			// Make sure we only check for objects that exist!

			if (objectOrGroup.exists)
			{
				// Cast member as WynObject or WynSprite accordingly,
				// because other types don't matter.

				_object = cast (objectOrGroup, WynObject);
				_objectLeft = _object.x + _object.offset.x;
				_objectTop = _object.y + _object.offset.y;

				if (_object.hitboxType == WynObject.HITBOX)
				{
					_objectRight = _objectLeft + _object.width;
					_objectBottom = _objectTop + _object.height;
				}
				else if (_object.hitboxType == WynObject.HITCIRCLE)
				{
					_objectRight = _objectLeft + _object.radius*2;
					_objectBottom = _objectTop + _object.radius*2;
				}

				addObject();
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
				_nodes[0] = WynQuadTree.recycle(_level+1, _quadMidX, _quadTop, _quadHalfWidth, _quadHalfHeight, this);
			_nodes[0].addObject();
			return;
		}
		if (topQuad && leftQuad)
		{
			if (_nodes[1] == null)
				_nodes[1] = WynQuadTree.recycle(_level+1, _quadLeft, _quadTop, _quadHalfWidth, _quadHalfHeight, this);
			_nodes[1].addObject();
			return;
		}
		if (botQuad && leftQuad)
		{
			if (_nodes[2] == null)
				_nodes[2] = WynQuadTree.recycle(_level+1, _quadLeft, _quadMidY, _quadHalfWidth, _quadHalfHeight, this);
			_nodes[2].addObject();
			return;
		}
		if (botQuad && rightQuad)
		{
			if (_nodes[3] == null)
				_nodes[3] = WynQuadTree.recycle(_level+1, _quadMidX, _quadMidY, _quadHalfWidth, _quadHalfHeight, this);
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
				_nodes[1] = WynQuadTree.recycle(_level+1, _quadLeft, _quadTop, _quadHalfWidth, _quadHalfHeight, this);
			_nodes[1].addObject();
		}
		if (overlapsTop && overlapsRight)
		{
			// object exists in top-right
			if (_nodes[0] == null)
				_nodes[0] = WynQuadTree.recycle(_level+1, _quadMidX, _quadTop, _quadHalfWidth, _quadHalfHeight, this);
			_nodes[0].addObject();
		}
		if (overlapsBottom && overlapsLeft)
		{
			// object exists in bottom-right
			if (_nodes[2] == null)
				_nodes[2] = WynQuadTree.recycle(_level+1, _quadLeft, _quadMidY, _quadHalfWidth, _quadHalfHeight, this);
			_nodes[2].addObject();
		}
		if (overlapsBottom && overlapsRight)
		{
			if (_nodes[3] == null)
				_nodes[3] = WynQuadTree.recycle(_level+1, _quadMidX, _quadMidY, _quadHalfWidth, _quadHalfHeight, this);
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
		{
			_listA.push(_object);
		}
		else if (_list == LIST_B)
		{
			_listB.push(_object);
		}

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
		var len1:Int;

		// If this quadtree has items, check for collisions.
		if (_listA.length > 0)
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
					_listI = _listB.slice(0);
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
					if (overlapNode())
						hit = true;
				}
			}
		}

		// Recursively call the execute() for every valid quadtree.
		for (i in 0 ... 4)
		{
			if (_nodes[i] != null)
				hit = hit || _nodes[i].execute();
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
		// If this is null, that means there's nothing
		// else to compare with.

		if (_listI == null)
			return false;

		var hit:Bool = false;
		var thisHit:Bool = false;
		var len2:Int = _listI.length;

		for (i in 0 ... len2)
		{
			var _object2:WynObject = _listI[i];

			thisHit = _object.collide(_object2);
			if (thisHit)
			{
				hit = thisHit;

				if (_callback != null)
					_callback(_object, _object2);
			}
		}

		return hit;
	}

	/**
	 * Visually draw the quadtree. In normal cases, you'll use
	 * quadtree.execute() then quadtree.destroy() after you're done.
	 * To make sure that this appears, you'll need to swap the two
	 * method call's order so that the quadtree's quad data is retained
	 * for render() to be able to draw the trees.
	 */
	public function drawTrees (c:WynCamera)
	{
		var g = c.buffer.g2;
		
		g.color = Color.Pink;
		g.drawRect(_quadLeft, _quadTop, _quadHalfWidth*2, _quadHalfHeight*2);

		for (i in 0 ... 4)
		{
			if (_nodes[i] != null)
				_nodes[i].drawTrees(c);
		}
	}
}