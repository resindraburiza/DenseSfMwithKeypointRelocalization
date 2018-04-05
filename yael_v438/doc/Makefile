

all: sphinx_html 




# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
PAPER         =
BUILDDIR      = _build

# Internal variables.
PAPEROPT_a4     = -D latex_paper_size=a4
PAPEROPT_letter = -D latex_paper_size=letter
ALLSPHINXOPTS   = -d $(BUILDDIR)/doctrees $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) .

clean: 
	rm -fr html $(BUILDDIR) latex *.aux *.toc *.log *~


sphinx_help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  sphinx_html       to make standalone HTML files"
	@echo "  sphinx_latexpdf   to make LaTeX files and run them through pdflatex"

sphinx_html: 
	$(SPHINXBUILD) -b html $(ALLSPHINXOPTS) $(BUILDDIR)/html
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/html."


sphinx_latexpdf:
	$(SPHINXBUILD) -b latex $(ALLSPHINXOPTS) $(BUILDDIR)/latex
	@echo "Running LaTeX files through pdflatex..."
	make -C $(BUILDDIR)/latex all-pdf
	mv $(BUILDDIR)/latex/Yael.pdf .
	@echo "pdflatex finished; the output file is Yael.pdf."


publish: 
	scp -r ./_build/html/* scm.gforge.inria.fr:/home/groups/yael/htdocs
