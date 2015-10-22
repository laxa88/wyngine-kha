package wy;

import kha.graphics2.Graphics;

class WyPool<T:WyObject> extends WyObject
{
	/**
	* At the moment, pools are never cleared explicitly.
	* I assume you'll manually cleanup all the array's items
	* from outside, then set this instance to null.
	*
	* NOTES:
	* There is no group-level methods for the following yet, because
	* I don't need it at the time of writing:
	* - init
	* - kill
	* - revive
	* - destroy
	* - clear
	*/

	public var _items:Array<T>;
	public var length(default,null):Int;
	public var existCount(get,null):Int;
	// public var aliveCount(get,null):Int;
	// public var activeCount(get,null):Int;
	// public var visibleount(get,null):Int;

	public function new ()
	{
		super();
		
		_items = [];
		length = 0;
		collisionType = WynCollisionType.GROUP;
	}

	/**
	* Updates all items in list that EXIST and are ACTIVE
	*/
	public override function update (dt:Float)
	{
		// update all items inside
		for (item in _items)
		{
			if (item != null && item._exists && item._active)
				item.update(dt);
		}
	}

	/**
	* Renders all items in list that EXIST and are VISIBLE
	*/
	public override function render (g:Graphics)
	{
		for (item in _items)
		{
			if (item != null && item._exists && item._visible)
				item.render(g);
		}
	}

	/**
	* At the moment, there is no max capacity.
	*/
	public function add (o:T):T
	{
		// don't do anything if item is invalid
		if (o == null)
			return null;

		// Don't add to the list if already exists
		if (_items.indexOf(o) >= 0)
			return o;

		_items.push(o);

		// never decrease, the pool should always increase to avoid GC... I think
		length++;

		// return the object for further use, if needed		
		return o;
	}

	/**
	* In HaxeFlixel, you can choose to do hard-remove (splicing)
	* or soft-remove (setting index to null). Since I don't know
	* what's the difference, I'll just do soft-removes because
	* that's the default for HaxeFlixel.
	*/
	public function remove (o:T):T
	{
		var index:Int = _items.indexOf(o);

		// failed to remove
		if (index < 0)
			return null;

		// remove success
		_items[index] = null;

		// return the object for further use, if needed
		return o;
	}

	override public function collide (other:WyObject, ?callback:Dynamic->Dynamic->Void) : Bool
	{
		var hit:Bool = false;

		if (Std.is(other, WyPool))
		{
			// NOTES:
			// - For each item in this list, if at least one of them
			// collide with the other list, then hit = true.
			// - Each item in this list will do a callback if it hits
			// the other list.
			for (o1 in _items)
			{
				if (!o1._active || !o1._alive)
					continue;

				var otherPool:WyPool<T> = cast other;
				var otherItems:Array<T> = cast otherPool._items;
				for (o2 in otherItems)
				{
					if (!o2._active || !o2._alive)
						continue;

					if (o1.collide(o2, callback))
						hit = true;
				}
			}
		}
		else
		{
			// TODO wypool collide with single objects
			Wy.log("TODO");
		}

		return hit;
	}

	/**
	* kill all items, but not itself!
	*/
	override public function kill ()
	{
		for (item in _items)
			item.kill();
	}

	/**
	* Returns first item available for pooling (!exist).
	* 
	* According to HaxeFlixel, they use base class as iterator
	* for performance reasons. But I'm not gonna do that until
	* there's evident performance issues. :o
	*/
	public function getFirstAvailable ():T
	{
		for (item in _items)
		{
			if (item != null && !item._exists)
				return item;
		}

		return null;
	}

	/**
	* Returns first item that exists, opposite of getFirstAvailable.
	*/
	public function getFirstExist ():T
	{
		for (item in _items)
		{
			if (item != null && item._exists)
				return item;
		}

		return null;
	}

	/**
	* Returns first item that is alive.
	*
	* In HaxeFlixe, this is handy for checking for "dead"
	* characters that still exist in the game.
	*/
	public function getFirstAlive ():T
	{
		for (item in _items)
		{
			if (item != null && item._exists && item._alive)
				return item;
		}

		return null;
	}

	/**
	* Returns first item that is dead, opposite of getFirstAlive.
	*/
	public function getFirstDead ():T
	{
		for (item in _items)
		{
			if (item != null && item._exists && !item._alive)
				return item;
		}

		return null;
	}

	private inline function get_existCount () : Int
	{
		var count:Int = 0;
		for (i in 0 ... length)
		{
			if (_items[i] != null && _items[i]._exists)
				count++;
		}
		return count;
	}
}