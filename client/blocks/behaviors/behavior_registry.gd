class_name BehaviorRegistry
## Central registry for all tile behaviors

static func lookup(name: String) -> Callable:
	match name:
		"push":
			return Callable(MovementBehaviors, "push")
		"freeze":
			return Callable(MovementBehaviors, "freeze")
		_:
			return Callable(MovementBehaviors, "freeze")
