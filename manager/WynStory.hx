package wyn.manager;

class WynStory extends WynManager
{
	public static var instance:WynStory;
	var stories:Map<String, StoryData>;
	var toRemove:Array<String>;

	public function new () : Void
	{
		super();

		instance = this;

		reset();
	}

	override public function update () : Void
	{
		for (story in stories)
		{
			story.elapsed += Wyngine.dt;
			var delay = story.events[story.eventIndex].delay;

			// If reached delay time, execute next event and loop if necessary
			if (story.elapsed >= delay)
			{
				var event = story.events[story.eventIndex];

				event.event(); // run the event
				story.elapsed -= delay; // reset the elapsed counter
				story.eventIndex++; // move to next event

				if (story.eventIndex >= story.events.length)
				{
					if (story.loop < 0) {
						story.eventIndex = 0; // negative = infinite loop, repeat from first event
					}
					else if (story.loop == 0) {
						toRemove.push(story.name); // no repeat; remove this story
					}
					else {
						story.loopCounter++;
						if (story.loopCounter > story.loop) {
							toRemove.push(story.name); // only remove if loopCounter reached max loop
						}
						else {
							story.eventIndex = 0;
						}
					}
				}
			}
		}

		if (toRemove.length > 0)
		{
			for (name in toRemove) {
				stories.remove(name);
			}
			toRemove = [];
		}
	}

	override public function reset () : Void
	{
		super.reset();

		stories = new Map<String, StoryData>();
		toRemove = [];
	}



	public static function addStory (uniqueName:String, events:Array<EventData>, loop:Int=-1)
	{
		var story:StoryData = {
			name: uniqueName,
			eventIndex: 0,
			events: events,
			elapsed: 0,
			loopCounter : 0,
			loop: loop // default = -1, infinite loop
		};

		instance.stories.set(uniqueName, story);
	}
}