all: zip upload

zip:
	rm ca.cybera.WordPressAIO.zip || true
	zip -r ca.cybera.WordPressAIO.zip *

upload:
	murano package-import --is-public --exists-action u ca.cybera.WordPressAIO.zip
