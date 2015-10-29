package wyn;

import kha.graphics2.Graphics;

class WynGroup<T:WynObject> extends WynObject
{
	/**
	 * WynGroup is basically a WynObject that doubles
	 * as an object pooler.
	 */

	public var members(default, null):Array<T> = [];
	public var length(default, null):Int = 0;
	public var existCount(get, null):Int;
	public var aliveCount(get, null):Int;
	public var activeCount(get, null):Int;
	public var visibleCount(get, null):Int;



	public function new ()
	{
		super();

		objectType = WynObject.GROUP;
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

	/**
	 * Like HaxeFlixel - only use this if you want to delete
	 * this completely. If you just want to disable, use kill();
	 */
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
	 * Handle for all child members before handling self.
	 * Note: There is no custom revive() code, because
	 * reviving this group should not automatically
	 * revive its child members. Do that manually.
	 */
	override public function kill ()
	{
		for (m in members)
			m.kill();

		super.kill();
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
	 * Use this method to get an available object from pool
	 * to be reused. This should be the most commonly used.
	 *
	 * TODO - provide a class parameter like FlxTypedGroup to create
	 * new instances when the pool has been exhausted.
	 *
	 * TODO - cater for
	 */
	public function recycle () : T
	{
		var member:WynObject = cast getFirstAvailable();

		// Automatically revive for reuse
		if (member != null)
			member.revive();

		return cast member;
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

	/**
	 * Helper function to iterate something through all the members.
	 * Same as forEach, but checks whether the member is explicitly
	 * of a certain type.
	 */
	public function forEachOfType<K> (objectClass:Class<K>, func:K->Void)
	{
		for (o in members)
		{
			if (o != null && Std.is(o, objectClass))
				func(cast o);
		}
	}

	/**
	 * Helper function to iterate something through all the members.
	 * Similar to HaxeFlixel.
	 */
	public function forEachExists (func:T->Void)
	{
		for (o in members)
		{
			if (o != null && o.exists)
				func(cast o);
		}
	}
	public function forEachAlive (func:T->Void)
	{
		for (o in members)
		{
			if (o != null && o.alive)
				func(cast o);
		}
	}
	public function forEachDead (func:T->Void)
	{
		for (o in members)
		{
			if (o != null && !o.alive)
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

	/**
	 * This is used by quadtrees (or anything else relevant in Wyngine).
	 * Returns a group if the objectType is a group, otherwise null.
	 * TODO handle tiles
	 */
	public inline static function resolveGroup (objectOrGroup:WynObject) : WynGroup<WynObject>
	{
		var group:WynGroup<WynObject> = null;

		if (objectOrGroup.objectType == WynObject.GROUP)
			group = cast objectOrGroup;

		return group;
	}



	private function get_existCount () : Int
	{
		var count:Int = 0;
		for (i in 0 ... length)
		{
			if (members[i].exists)
				count++;
		}
		return count;
	}

	private function get_aliveCount () : Int
	{
		var count:Int = 0;
		for (i in 0 ... length)
		{
			if (members[i].alive)
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