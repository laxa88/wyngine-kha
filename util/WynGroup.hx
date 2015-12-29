package wyn.util;

class WynGroup<T:WynObject>
{
	// NOTE: Can be used as a container to handle multiple WynObject,
	// or used primarily for object pooling.

	public var members(default, null):Array<T> = [];
	public var length(default, null):Int = 0;
	public var enabledCount(get, null):Int;
	public var activeCount(get, null):Int;
	public var visibleCount(get, null):Int;

	public function new ()
	{

	}

	public function add (o:T) : T
	{
		// What were you thinking?
		if (o == null)
		{
			trace("Cannot add null object to pool");
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
		var index:Int = members.indexOf(o);

		if (index < 0)
			return null;

		// Nulls the space in members array.
		members[index] = null;

		// Return for chaining; You can destroy/kill it from here.
		return o;
	}

	public function recycle () : T
	{
		var member:T = getFirstAvailable();

		// Automatically revive for reuse
		if (member != null)
			member.revive();

		return member;
	}

	public function kill ()
	{
		// great for returning all pool items 
		for (m in members)
			m.kill();
	}

	public function getFirstAvailable () : T
	{
		for (o in members)
		{
			if (o != null && !o.active)
				return o;
		}

		return null;
	}

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

	public function getFirstEnabled () : T
	{
		for (o in members)
		{
			if (o != null && o.active)
				return o;
		}

		return null;
	}

	/**
	 * Helper function to iterate something through all the members.
	 * This includes ALL members regardless active or not. Great for
	 * using at the beginning of a game reset.
	 * Similar to HaxeFlixel.
	 */
	public function forEach (func:T->Void)
	{
		for (o in members)
		{
			if (o != null)
				func(cast o);
		}
	}

	public function forEachEnabled (func:T->Void)
	{
		for (o in members)
		{
			if (o != null && o.enabled)
				func(cast o);
		}
	}

	public function forEachActive (func:T->Void)
	{
		for (o in members)
		{
			if (o != null && o.active)
				func(cast o);
		}
	}

	public function forEachVisible (func:T->Void)
	{
		for (o in members)
		{
			if (o != null && o.visible)
				func(cast o);
		}
	}



	private function get_enabledCount () : Int
	{
		var count:Int = 0;
		for (i in 0 ... length)
		{
			if (members[i].enabled)
				count++;
		}
		return count;
	}

	private function get_activeCount () : Int
	{
		var count:Int = 0;
		for (i in 0 ... length)
		{
			if (members[i].active)
				count++;
		}
		return count;
	}

	private function get_visibleCount () : Int
	{
		var count:Int = 0;
		for (i in 0 ... length)
		{
			if (members[i].visible)
				count++;
		}
		return count;
	}
}