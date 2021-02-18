build:
	mkdir -p bin/html/
	touch bin/.gdignore
	godot --export HTML5 bin/html/index.html
	cd bin/html/ && zip ../gwj30.zip *
