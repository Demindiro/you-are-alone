build: build-html build-linux build-osx build-windows


build-html: mkdir-bin
	godot --export HTML5 bin/html/index.html
	cd bin/html/ && zip ../gwj30.zip *


build-linux: mkdir-bin
	godot --export Linux bin/linux/you-are-alone
	cd bin/linux/ && tar czvf ../you-are-alone-linux.tar.xz *


build-osx: mkdir-bin
	godot --export OSX bin/osx/you-are-alone.zip
	cp bin/osx/you-are-alone.zip bin/you-are-alone-osx.zip


build-windows: mkdir-bin
	godot --export Windows bin/windows/you-are-alone.exe
	cd bin/windows/ && zip ../you-are-alone-windows.zip *


mkdir-bin:
	mkdir -p bin/html/
	mkdir -p bin/linux/
	mkdir -p bin/osx/
	mkdir -p bin/windows/
	touch bin/.gdignore


clean:
	rm -rf bin/
