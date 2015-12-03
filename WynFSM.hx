package wyn;

class WynFSM
{
	var currentState:State;

	public function new ()
	{
	}

	public function switchState (newState:State)
	{
		if (currentState != null)
			currentState.endState(this);

		currentState = newState;

		if (currentState != null)
			currentState.beginState(this);
	}

	public function update (dt:Float)
	{
		if (currentState != null)
			currentState.updateState(this, dt);
	}

	public function render (c:WynCamera)
	{
		if (currentState != null)
			currentState.renderState(this, c);
	}
}

interface State
{
	public function beginState (fsm:WynFSM):Void;
	public function updateState (fsm:WynFSM, dt:Float):Void;
	public function renderState (fsm:WynFSM, c:WynCamera):Void;
	public function endState (fsm:WynFSM):Void;
}