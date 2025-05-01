.PHONY: test

install:
	luarocks --lua-version=5.1 install moonscript --local
	luarocks --lua-version=5.1 install busted --local

test: 
	busted
