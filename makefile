master = main
git_sha = $(shell git describe --always --tags --long --dirty | tee git-sha)

all: $(master).pdf

%.pdf: | %.tex
	echo $(git_sha)
	@echo "Generate the figures..."
	bash scripts/generate-figures.sh
	@echo "First compilation..."
	pdflatex -shell-escape $(master).tex
	@echo "Making glossary..."
	makeindex -t $(master).glg -o $(master).gls -s $(master).ist $(master).glo
	@echo "Making nomenclature..."
	makeindex $(master).nlo -s nomencl.ist -o $(master).nls
	@echo "Making bibliography..."
	bibtex tex/intro.aux
	bibtex tex/methodology.aux
	bibtex tex/sota.aux
	bibtex tex/cp-integration.aux
	bibtex tex/awp.aux
	bibtex tex/awp-components.aux
	bibtex tex/bwp.aux
	bibtex tex/bwp-components.aux
	bibtex tex/cp-maps-math-models.aux
	bibtex tex/awp-eqn.aux
	bibtex tex/bwp-eqn.aux
	bibtex tex/uncertainties.aux
	@echo "Making index..."
	makeindex $(master).idx
	@echo "Second compilation..."
	pdflatex -shell-escape $(master).tex # interaction=nonstopmode
	@echo "Making index..."
	makeindex $(master).idx
	@echo "Third compilation..."
	pdflatex -shell-escape $(master).tex
	@echo "Forth compilation..."
	pdflatex -shell-escape $(master).tex
	mv $(master).pdf $(master)-tmp.pdf
	mutool clean $(master)-tmp.pdf $(master).pdf
	rm -f $(master)-tmp.pdf
#	cp $(master).pdf $(master)-$(git_sha).pdf
clean:
	-find . -name \*.aux -delete
	-rm -vf $(addprefix $(master).,acr aux bbl blg brf glg glo gls)
	-rm -vf $(addprefix $(master).,fax idx ilg ind ist lof loh loi)
	-rm -vf $(addprefix $(master).,lot nav out snm tns toc nlo nls)
	-rm -vf tex/*.bbl tex/*.blg tex/*.aux
	-find . -name auto -type d -print0 | xargs -0 rm -Rf
	-find . -name \*~ -delete

distclean: clean
	-rm -vf $(addprefix $(master).,pdf log)
	-rm -vf git-sha
