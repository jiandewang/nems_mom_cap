# User must customize the following two make variables
INSTALLDIR=/home/$(USER)/OCN-INSTALLS/MOM5_$(installdate)

NEMSMOMDIR=/home/Anthony.Craig/mom/exec/zeus
#NEMSMOMDIR=/home/Fei.Liu/github/mom/exec/zeus
#NEMSMOMDIR=/home/Gerhard.Theurich/OCN-INSTALLS/mom/exec/zeus


#installdate := latest
installdate := $(shell date '+%Y-%m-%d-%H-%M-%S')

ifneq ($(origin ESMFMKFILE), environment)
$(error Environment variable ESMFMKFILE was not set.)
endif
include         $(ESMFMKFILE)
ESMF_INC        = $(ESMF_F90COMPILEPATHS)
ESMF_LIB        = $(ESMF_F90LINKPATHS) $(ESMF_F90LINKRPATHS) $(ESMF_F90ESMFLINKLIBS)
UTILINCS        = -I$(NEMSMOMDIR)/lib_FMS -I$(NEMSMOMDIR)/lib_ocean -I.

.SUFFIXES: .F90

%.o : %.F90
	$(ESMF_F90COMPILER) -c $(ESMF_F90COMPILEOPTS) $(UTILINCS) $(ESMF_F90COMPILEPATHS) $(ESMF_F90COMPILEFREECPP) $(ESMF_F90COMPILECPPFLAGS) $<
mom_cap.o : time_utils.o

.PRECIOUS: %.o

PWDDIR := $(shell pwd)

MAKEFILE = makefile

LIBRARY  = libmom.a

MODULES  = mom_cap.o time_utils.o

all default:
	@gmake -f $(MAKEFILE) $(LIBRARY)

$(LIBRARY): $(MODULES)
	$(AR) $(ARFLAGS) $@ $?

install: $(LIBRARY)
	rm -f mom5.mk.install
	@echo "# ESMF self-describing build dependency makefile fragment" > mom5.mk.install
	@echo "# src location Zeus: $pwd" >> mom5.mk.install
	@echo  >> mom5.mk.install
	@echo "ESMF_DEP_FRONT     = mom_cap_mod" >> mom5.mk.install
	@echo "ESMF_DEP_INCPATH   = $(INSTALLDIR)" >> mom5.mk.install
	@echo "ESMF_DEP_CMPL_OBJS = " >> mom5.mk.install
	@echo "ESMF_DEP_LINK_OBJS = $(INSTALLDIR)/libmom.a $(INSTALLDIR)/lib_ocean.a $(INSTALLDIR)/lib_FMS.a" >> mom5.mk.install
	mkdir -p $(INSTALLDIR)
	cp -f $(NEMSMOMDIR)/lib_ocean/lib_ocean.a $(INSTALLDIR)
	cp -f $(NEMSMOMDIR)/lib_FMS/lib_FMS.a $(INSTALLDIR)
	cp -f libmom.a mom_cap_mod.mod $(INSTALLDIR)
	cp -f mom5.mk.install $(INSTALLDIR)/mom5.mk

clean:
	$(RM) -f $(LIBRARY) *.f90 *.o *.mod *.lst depend
