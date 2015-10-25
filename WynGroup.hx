package wyn;

import kha.graphics2.Graphics;

class WynGroup<T:WynObject> extends WynObject
{
	/**
	 * WynGroup is basically a WynObject that doubles
	 * as an object pooler.
	 */

	public var members(default, null):Array<T>;
	public var length(default, null):Int = 0;



	public function new ()
	{
		super();

		members = [];
		objectType = WynObjectType.GROUP;
	}

	override public function update (dt:Float)
	{
		super.update(dt);

		// Instead of doing "for (o in members)", we use a single
		// storage variable for looping, to keep things casted to
		// the root class (WynObject).
		var i:Int = 0;
		var o:WynObject = null;
		
		while (i < length)
		{
			o = members[i++];

			if (o != null && o.exists && o.active)
				o.update(dt);
		}
	}

	override public function render (g:Graphics)
	{
		super.render(g);

		// Instead of doing "for (o in members)", we use a single
		// storage variable for looping, to keep things casted to
		// the root class (WynObject).
		var i:Int = 0;
		var o:WynObject = null;
		
		while (i < length)
		{
			o = members[i++];

			if (o != null && o.exists && o.visible)
				o.render(g);
		}
	}

	override public function destroy ()
	{
		super.destroy();

		if (members != null)
		{
			// Instead of doing "for (o in members)", we use a single
			// storage variable for looping, to keep things casted to
			// the root class (WynObject).
			var i:Int = 0;
			var o:WynObject = null;

			while (i < length)
			{
				o = members[i++];
				if (o != null)
					o.destroy();
			}

			// cleanup
			members = null;
		}
	}

	/**
	 * Adds item to the group pool
	 */
	public function add (o:T) : T
	{
		// What were you thinking?
		if (o == null)
		{
			Wyngine.log("Cannot add null object to WynGroup");
			return null;
		}

		// Don't add same object twice.
		if (members.indexOf(o) >= 0)
			return o;

		// Look for null items and add it there
		var index:Int = getFirstNull();
		if (index != -1)
		{
			members[index] = o;

			// manually update the member length
			if (index >= length)
				length = index + 1;

			// Return for chaining
			return o;
		}
		
		// If the member array is full, add new ones
		members.push(o);
		length++;

		// Return for chaining
		return o;
	}

	/**
	 * Removes item from pool. For now, it nulls
	 * the array element rather than splicing, so that
	 * we can reuse the space when we use add() later.
	 */
	public function remove (o:T) : T
	{
		if (members == null)
			return null;

		var index:Int = members.indexOf(o);

		if (index < 0)
			return null;

		// Nulls the space in members array.
		members[index] = null;

		// Return for chaining; You can destroy it from here.
		return o;
	}

	/**
	 * Returns first member that doesn't exist (regardless of active/alive/visible).
	 * This should be frequently used in pooling! Start here!
	 */
	public function getFirstAvailable () : T
	{
		for (o in members)
		{
			if (o != null && !o.exists)
				return o;
		}

		return null;
	}

	/**
	 * Returns first index occurance of a null element in member array,
	 * usually used for filling in destroyed elements in members.
	 */
	public function getFirstNull () : Int
	{
		var i:Int = 0;

		while (i < length)
		{
			if (members[i] == null)
				return i;
			i++;
		}

		return -1;
	}

	/**
	 * Get first member that exists (regardless of active/alive/visible).
	 */
	public function getFirstExist () : T
	{
		for (o in members)
		{
			if (o != null && o.exists)
				return o;
		}

		return null;
	}

	/**
	 * Returns first member that exists, and is alive.
	 */
	public function getFirstAlive () : T
	{
		for (o in members)
		{
			if (o != null && o.exists && o.alive)
				return o;
		}

		return null;
	}

	/**
	 * Returns first member that exists, and is dead.
	 */
	public function getFirstDead ():T
	{
		for (o in members)
		{
			if (o != null && o.exists && !o.alive)
				return o;
		}

		return null;
	}

	/**
	 * This is used by quadtrees (or anything else relevant in Wyngine).
	 * Returns a group if the objectType is a group, otherwise null.
	 * TODO handle tiles
	 */
	public inline static function resolveGroup (objectOrGroup:WynObject) : WynGroup<WynObject>
	{
		var group:WynGroup<WynObject> = null;

		if (objectOrGroup.objectType == WynObjectType.GROUP)
			group = cast objectOrGroup;

		return group;
	}
}