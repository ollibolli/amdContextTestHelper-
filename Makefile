test: 
	./node_modules/.bin/mocha \
	--reporter list \
	--recursive \
	--compilers coffee:coffee-script \
	--require coffee-script \
	--ui bdd \
	--timeout 5000 \
	./test/
	
.PHONY: test