TEXMFLOCAL = $(shell kpsewhich --var-value TEXMFLOCAL)
STRIPTARGET = musixlmd.sty
DOCTARGET = musixlmd
PDFTARGET = $(addsuffix .pdf,$(DOCTARGET))
DVITARGET = $(addsuffix .dvi,$(DOCTARGET))
LATEXENGINE := lualatex
LOGSUFFIXES = .aux .log .toc .mx1 .mx2 .bcf .bbl .blg .idx .ind .ilg .out .run.xml .glo .gls .hd

define move
	$(foreach tempsuffix,$(LOGSUFFIXES),$(call movebase,$1,$(tempsuffix)))
	
endef
define movebase
	if [ -e $(addsuffix $2,$1) ]; then mv $(addsuffix $2,$1) ./logs; fi
	
endef

all: $(STRIPTARGET) $(PDFTARGET)
strip: $(STRIPTARGET)
doc: $(PDFTARGET)

.PHONY: install clean cleanstrip cleanall cleandoc movelog


musixlmd.tex: musixlmd.dtx musixlmd-tex.ins
	pdflatex musixlmd.ins

musixlmd.sty: musixlmd.dtx musixlmd.ins
	pdflatex musixlmd.ins

.SUFFIXES: .dtx .dvi .pdf

ifeq ($(LATEXENGINE),lualatex)
.dtx.pdf:
	lualatex $<
	if [ -e $(basename $<).idx ]; then makeindex -s gind.ist $(basename $<); fi
	if [ -e $(basename $<).glo ]; then makeindex -s gglo.ist -o $(addsuffix .gls,$(basename $<)) $(addsuffix .glo,$(basename $<)); fi
	lualatex -synctex=1 $<

else
%.dvi: %.dtx
	uplatex $<
	if [ -e $(basename $<).idx ]; then makeindex -s gind.ist $(basename $<); fi
	if [ -e $(basename $<).glo ]; then makeindex -s gglo.ist -o $(addsuffix .gls,$(basename $<)) $(addsuffix .glo,$(basename $<)); fi
	uplatex -synctex=1 $<

%.pdf: %.dvi
	dvipdfmx $<
endif

install: $(STRIPTARGET) $(PDFTARGET)
	mkdir -p $(TEXMFLOCAL)/tex/platex/bellMacros
	install $(STRIPTARGET) $(TEXMFLOCAL)/tex/platex/bellMacros
	mkdir -p $(TEXMFLOCAL)/doc/platex/bellMacros
	install $(PDFTARGET) $(TEXMFLOCAL)/doc/platex/bellMacros

movelog:
	mkdir -p ./logs
	$(foreach temp,$(DOCTARGET),$(call move,$(temp)))

clean:
	rm -f \
	$(addsuffix .idx,$(DOCTARGET)) \
	$(addsuffix .ind,$(DOCTARGET)) \
	$(addsuffix .ilg,$(DOCTARGET)) \
	$(addsuffix .glo,$(DOCTARGET)) \
	$(addsuffix .gls,$(DOCTARGET)) \
	$(addsuffix .aux,$(DOCTARGET)) \
	$(addsuffix .hd, $(DOCTARGET)) \
	$(addsuffix .toc,$(DOCTARGET)) \
	$(addsuffix .mx1,$(DOCTARGET)) \
	$(addsuffix .log,$(DOCTARGET))

cleanall:
	rm -f $(PDFTARGET) \
	$(DVITARGET) \
	$(STRIPTARGET) \
	make clean

makelog:
	git log --graph --date=short --all --pretty="format:(%C(yellow)%h) %C(cyan)%ad \"%C(green)%an\"%C(reset)%x09%C(red)%d%C(reset) %s" 1> "log_all.gitlog"
	git log --graph --date=short       --pretty="format:(%C(yellow)%h) %C(cyan)%ad \"%C(green)%an\"%C(reset)%x09%C(red)%d%C(reset) %s" 1> "log.gitlog"
