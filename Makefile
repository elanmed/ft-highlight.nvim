.PHONY: dev clean test test-file lint format docs deploy

dev:
	mkdir -p ~/.local/share/nvim/site/pack/dev/start/ft-highlight.nvim
	stow -d .. -t ~/.local/share/nvim/site/pack/dev/start/ft-highlight.nvim ft-highlight.nvim

clean:
	rm -rf ~/.local/share/nvim/site/pack/dev

test:
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()"

test-file:
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run_file('$(FILE)')"

lint:
	# https://luals.github.io/#install
	lua-language-server --check=./lua --checklevel=Error

format:
	# https://github.com/JohnnyMorganz/StyLua#usage
	stylua .

docs:
	mkdir -p ./doc
	./deps/ts-vimdoc.nvim/scripts/docgen.sh README.md doc/ft-highlight.txt ft-highlight
	nvim --headless -c "helptags doc/" -c "qa"

deploy: test lint format docs
