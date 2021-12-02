# Need cabal, graphviz, java, jq, curl
pandoc-crossref: pandoc
	cabal install pandoc-crossref
pandoc:
	cabal install pandoc
plantuml.jar:
	curl -s https://api.github.com/repos/plantuml/plantuml/releases/latest |\
	jq -r .assets[].browser_download_url |\
	tail -n1 |\
	xargs curl -sLo plantuml.jar

.SUFFIXES: .html .md .tikz .svg .gv .puml
.md.html:
	pandoc -F pandoc-crossref -NCst html5 metadata.yaml ${.IMPSRC} >${.TARGET}
.puml.svg: plantuml.jar
	java -jar plantuml.jar ${.IMPSRC} -tsvg
.gv.svg:
	dot -Tsvg -Gsize=4,6\! -Gdpi=100 ${.IMPSRC} >${.TARGET}
