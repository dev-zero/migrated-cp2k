.SUFFIXES: .F .d .o

CP2KHOME  = $(HOME)/CP2K
ARCH      = $(shell $(CP2KHOME)/tools/get_arch_code)
VERSION   = sopt
SMAKE     = gmake -r
PMAKE     = $(SMAKE) -j 1
LIB1      = fftsg

### Dependent variables ###

ARCHDIR      = $(CP2KHOME)/arch
MAINEXEDIR   = $(CP2KHOME)/exe
MAINLIBDIR   = $(CP2KHOME)/lib
MAINOBJDIR   = $(CP2KHOME)/obj
SRCDIR       = $(CP2KHOME)/src
FORPAR       = $(CP2KHOME)/tools/forpar.x -chkint
SFMAKEDEPEND = $(CP2KHOME)/tools/sfmakedepend -m int -s -f
MACHINEDEFS  = $(ARCHDIR)/$(ARCH).$(VERSION)
PROG         = $(EXEDIR)/cp2k.$(VERSION)
EXEDIR       = $(MAINEXEDIR)/$(ARCH)
LIBDIR       = $(MAINLIBDIR)/$(ARCH)
OBJDIR       = $(MAINOBJDIR)/$(ARCH)
VPATH        = $(SRCDIR)
MAKEFILE     = $(SRCDIR)/Makefile
OBJECTDEFS   = $(SRCDIR)/OBJECTDEFS
LIB1_ARCHIVE = $(LIBDIR)/$(VERSION)/lib$(LIB1).a

### Definition of the multiple targets ###

VERSION_TARGETS = sopt sdbg popt pdbg
CLEAN_TARGETS   = sopt/clean sdbg/clean popt/clean pdbg/clean\
                  sopt/realclean sdbg/realclean popt/realclean pdbg/realclean

### Master rules ###

$(VERSION_TARGETS):
	cd $(EXEDIR) || mkdir -p $(EXEDIR)
	cd $(OBJDIR)/$@ || mkdir -p $(OBJDIR)/$@
	$(SMAKE) -C $(OBJDIR)/$@ -f $(MAKEFILE) VERSION=$@ dependencies
	$(PMAKE) -C $(OBJDIR)/$@ -f $(MAKEFILE) VERSION=$@ all

$(LIB1_ARCHIVE):
	cd $(LIBDIR)/$(VERSION) || mkdir -p $(LIBDIR)/$(VERSION)
	$(PMAKE) -C $(SRCDIR)/lib -f $(MAKEFILE) VERSION=$(VERSION) $(LIB1)
	$(SMAKE) -C $(SRCDIR)/lib -f $(MAKEFILE) clean

$(CLEAN_TARGETS):
	$(SMAKE) -C $(OBJDIR)/$(@D) -f $(MAKEFILE) VERSION=$(@D) $(@F)

include $(OBJECTDEFS)

include $(MACHINEDEFS)

OBJECTS = $(OBJECTS_GENERIC) $(OBJECTS_ARCHITECTURE)

LIB1_OBJECTS = ctrig.o fftpre.o fftrot.o fftstp.o mltfftsg.o

DEPENDENCIES = $(OBJECTS:.o=.d)

LIBRARIES = $(LIBS) -L$(LIBDIR)/$(VERSION) -l$(LIB1)

### Slave rules ###

dependencies: $(DEPENDENCIES)

all: lib$(LIB1) $(PROG)

lib$(LIB1): $(LIB1_ARCHIVE)

$(LIB1): $(LIB1_OBJECTS)
	$(AR) $(LIB1_ARCHIVE) $(LIB1_OBJECTS)

$(PROG): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $(PROG) $(OBJECTS) $(LIBRARIES)

%.o: %.F
	$(FC) -c $(FCFLAGS) $<

%.d: %.F
	$(CPP) $(CPPFLAGS) $< $*.f
	$(FORPAR) $*.f
	$(PERL) $(SFMAKEDEPEND) $*.d $*.f
	@rm -f $*.f $*.d.old

parallel_include.o: parallel_include.F
	$(FC_fixed) -c $(FCFLAGS) $<

parallel_include.d: parallel_include.F
	$(CPP) $(CPPFLAGS) $< $*.f
	$(FORPAR) -fix $*.f
	$(PERL) $(SFMAKEDEPEND) $*.d $*.f
	@rm -f $*.f $*.d.old

clean:
	rm -f *.o *.mod F*.f

realclean: clean
	rm -f $(PROG) *.d *.int *~ *.lst

distclean:
	rm -rf $(MAINEXEDIR) $(MAINLIBDIR) $(MAINOBJDIR)

### Load the automatically generated rules of sfmakedepend ###

include $(wildcard *.d)
