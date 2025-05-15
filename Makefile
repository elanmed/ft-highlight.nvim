.PHONY: dev test test-file docs lint deploy clean

dev:
	mkdir -p ~/.local/share/nvim/site/pack/dev/start/ft-highlight.nvim
	stow -d .. -t ~/.local/share/nvim/site/pack/dev/start/ft-highlight.nvim ft-highlight.nvim

clean:
	rm -rf ~/.local/share/nvim/site/pack/dev

test:
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()"

test-file:
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run_file('$(FILE)')"

docs: 
	./deps/ts-vimdoc.nvim/scripts/docgen.sh README.md doc/ft-highlight.txt ft-highlight

lint: 
	# https://luals.github.io/#install
	lua-language-server --check=./lua --checklevel=error

deploy: test lint docs
