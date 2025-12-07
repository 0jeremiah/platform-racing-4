# Tile Behaviors

This directory contains all tile behaviors organized by category.

## Structure

```
behaviors/
├── movement.gd          # Movement behaviors (push, freeze)
├── physics.gd           # Physics behaviors (bounce)
├── damage.gd            # Damage behaviors (explode)
└── behavior_registry.gd # Central registry for all behaviors
```

## Adding a New Behavior

1. Choose the appropriate category file (or create a new one)
2. Add a static function following this signature:

```gdscript
static func my_behavior(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, params: Dictionary) -> void:
	# Your logic here
```

3. Register it in `behavior_registry.gd`:

```gdscript
_registry["my_behavior"] = Callable(YourCategoryBehaviors, "my_behavior")
```

4. Add to the category list in `get_behaviors_by_category()`

## Behavior Categories

### Movement (`movement.gd`)
Controls how players move when interacting with tiles.
- `push_direction` - Push in any direction
- `push_up`, `push_down`, `push_left`, `push_right` - Directional pushes
- `freeze` - Ice effect (sliding)

### Physics (`physics.gd`)
Physics-based interactions.
- `bounce` - Bounce players back with configurable force

### Damage (`damage.gd`)
Behaviors that damage or affect player health.
- `explode` - Mine explosion with knockback and hitstun

## Usage

Behaviors are called through the registry:

```gdscript
BehaviorRegistry.call_behavior("bounce", player, tile_map_layer, coords, {"bounciness": 0.2})
```

The registry automatically initializes on first use.
