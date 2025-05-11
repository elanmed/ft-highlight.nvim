.PHONY: dev test test-file docs clean clean-dev

dev:
	mkdir -p ~/.local/share/nvim/site/pack/dev/start/ft-highlight.nvim
	stow -d .. -t ~/.local/share/nvim/site/pack/dev/start/ft-highlight.nvim ft-highlight.nvim

test:
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()"

test-file:
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run_file('$(FILE)')"

docs: 
	./deps/ts-vimdoc.nvim/scripts/docgen.sh README.md doc/ft-highlight.txt ft-highlight

clean: clean-dev

clean-dev:
	rm -rf ~/.local/share/nvim/site/pack/dev
