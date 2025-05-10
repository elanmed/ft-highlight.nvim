.PHONY: dev test test_file clean clean-dev

dev:
	mkdir -p ~/.local/share/nvim/site/pack/dev/start/ft-highlight.nvim
	stow -d .. -t ~/.local/share/nvim/site/pack/dev/start/ft-highlight.nvim ft-highlight.nvim

test:
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()"

test_file:
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run_file('$(FILE)')"

clean: clean-dev

clean-dev:
	rm -rf ~/.local/share/nvim/site/pack/dev
