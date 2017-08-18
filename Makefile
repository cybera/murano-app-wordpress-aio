all: zip import

zip:
	rm ca.cybera.WordPressAIO.zip || true
	zip -r ca.cybera.WordPressAIO.zip *

import:
	murano package-import --is-public --exists-action u ca.cybera.WordPressAIO.zip
