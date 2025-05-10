.PHONY: install test clean clean-rocks clean-dev packadd

install:
	luarocks --lua-version=5.1 install moonscript --local
	luarocks --lua-version=5.1 install busted --local

test: 
	eval $(luarocks path --lua-version 5.1 --bin) && busted

clean: clean-rocks clean-dev

clean-dev:
	rm -rf ~/.local/share/nvim/site/pack/dev

clean-rocks: 
	rm -rf ~/.luarocks/bin/busted
	rm -rf ~/.luarocks/bin/moonscript

dev:
	mkdir -p ~/.local/share/nvim/site/pack/dev/start/ft-highlight.nvim
	stow -d .. -t ~/.local/share/nvim/site/pack/dev/start/ft-highlight.nvim ft-highlight.nvim
