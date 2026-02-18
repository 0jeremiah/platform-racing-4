# Platform Racing 4 Client

## Build on macOS
```
ln -s /Applications/Godot.app/Contents/MacOS/Godot /usr/local/bin/godot
godot --headless --verbose --export-release "Web" $PWD/build/web/index.html
```

## Add GDScript MCP Server to Claude
Install: https://github.com/tkmct/godot-doc-mcp
```
claude mcp add --transport stdio godot-docs \
  --env GODOT_DOC_DIR=/path/to/godot-doc-mcp/doc \
  -- npx --prefix /path/to/godot-doc-mcp tsx /path/to/godot-doc-mcp/server/src/cli.ts
```