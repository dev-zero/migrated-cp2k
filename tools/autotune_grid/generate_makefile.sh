#!/bin/bash
#
#   generate_makefile.sh
#
#   Generate a makefile to generate all combination optimisations of collocate and integrate
#
#

source config.in




FC_OPT_FLAGS="$FCFLAGS" 

(
echo FC_comp=$FC_comp
echo FCFLAGS=$FCFLAGS
echo FC_tune=\$\(FC_comp\) \$\(FCFLAGS\)
) > config.mk

# Write a makefile to generate all different combinations

(

echo -e "########## DO NOT EDIT THIS FILE "

echo -e "include config.mk"

echo -e "FILES=kinds.F basic_types.F util.F l_utils.F cube_utils.F  orbital_pointers.F qs_interactions.F \n"

echo -e "OBJ_FILES=\$(FILES:.F=.o)\n"
echo -e "default: all"

echo -e "kinds.o:"
echo -e "\t\$(FC_tune) -c kinds.F"
echo -e "basic_types.o: kinds.o"
echo -e "\t\$(FC_tune) -c basic_types.F"
echo -e "util.o: basic_types.o"
echo -e "\t\$(FC_tune) -c util.F"
echo -e "l_utils.o: util.o"
echo -e "\t\$(FC_tune) -c l_utils.F"
echo -e "cube_utils.o: l_utils.o"
echo -e "\t\$(FC_tune) -c cube_utils.F"
echo -e "orbital_pointers.o: cube_utils.o"
echo -e "\t\$(FC_tune) -c orbital_pointers.F"
echo -e "qs_interactions.o: orbital_pointers.o"
echo -e "\t\$(FC_tune) -c qs_interactions.F"

echo -e "objfiles: \$(OBJ_FILES)"

echo -e "libtest.a: objfiles "
echo -e "\tar r libtest.a \$(OBJ_FILES)"


) > $makefile_name

echo -e """
include ../config.mk

collocate_fast.o:
	\$(FC_tune) -I../ -c collocate_fast.F -o collocate_fast.o
integrate_fast.o:
	\$(FC_tune) -I../ -c integrate_fast.F -o integrate_fast.o
qs_collocate_density.o:
	\$(FC_tune)  -I../ -c qs_collocate_density.F -o qs_collocate_density.o 
qs_integrate_potential.o:
	\$(FC_tune)  -I../ -c qs_integrate_potential.F  -o qs_integrate_potential.o
main.o: qs_collocate_density.o qs_integrate_potential.o integrate_fast.o collocate_fast.o
	\$(FC_tune)  -I../ -c main.F  -o main.o
test.x: main.o qs_integrate_potential.o qs_collocate_density.o integrate_fast.o collocate_fast.o
	\$(FC_tune) qs_collocate_density.o qs_integrate_potential.o   collocate_fast.o integrate_fast.o  main.o ../libtest.a   -o test.x
""" > makefile_case

#7  ! generate up to l = l_max_a + l_max_b 
#1  ! use the best of three timings
Ncomb=$(( 2**$Nopt ))
TARGETS_EXE=""
TARGETS_RUN=""

# For each value of l and iopt
for l in `seq 0 $lmax`; do
# First optimisation starts at ONE (all_options[0] is not initialised and generate does not produces valid code)
for iopt in `seq 1 $Ncomb`;do
TARGETS_EXE="gen_${l}_${iopt}.exists $TARGETS_EXE"
TARGETS_RUN="run_${l}_${iopt}_0.exists  run_${l}_${iopt}_1.exists $TARGETS_RUN"
DIRECTORIES="out_${l}_${iopt} $TMPBASE/TMP_${l}_${iopt} $DIRECTORIES"

icollo=1
is_icollo_1=""
is_icollo_0=""

if [[ $icollo -eq 1 ]]; then
   is_icollo_1="echo -1;"
fi

if [[ $icollo -eq 0 ]]; then
   is_icollo_0="echo -1;"
fi

# Makefile entries for this case
echo -e """
gen_${l}_${iopt}.exists: libtest.a generate.x
\t-mkdir out_${l}_${iopt}
\t(${is_icollo_1} echo -e \"${l}\"; yes ${iopt} | head -n $((${l}+1)); ${is_icollo_0}) > generate_${l}_${iopt}.in
\t./generate.x < generate_${l}_${iopt}.in
\t(${is_icollo_0} echo -e  \"${l}\"; yes ${iopt} | head -n $((${l}+1)); ${is_icollo_1}) > generate_${l}_${iopt}.in
\t./generate.x < generate_${l}_${iopt}.in
\t-rm generate_${l}_${iopt}.in
\tcp qs_collocate_density.F qs_integrate_potential.F main.F out_${l}_${iopt}/
\tcp makefile_case out_${l}_${iopt}/Makefile
\t-mkdir out_${l}_${iopt}/TMP_${l}_${iopt}
\tmake -C out_${l}_${iopt} test.x  TMPDIR=out_${l}_${iopt}/TMP_${l}_${iopt}
\t-rm -Rf out_${l}_${iopt}/TMP_${l}_${iopt}
\ttouch gen_${l}_${iopt}.exists
""" >> $makefile_name

#echo -e """
#gen_${l}_${iopt}: libtest.a
#
#""" >> /dev/null # $makefile_name #/dev/null

icollo=0
 echo -e """
run_${l}_${iopt}_${icollo}.exists: gen_${l}_${iopt}.exists
\techo -e \"        ${icollo}\\\\n        T\\\\n        ${l}    0    0    0\\\\n        ${Nrun}\" > out_${l}_${iopt}/run_${l}_${iopt}_T_${icollo}.in
\ttest -f out_${l}_${iopt}/out_test_${l}_${iopt}_T_${icollo} || ./out_${l}_${iopt}/test.x < out_${l}_${iopt}/run_${l}_${iopt}_T_${icollo}.in >  out_${l}_${iopt}/out_test_${l}_${iopt}_T_${icollo}
\techo -e \"        ${icollo}\\\\n        F\\\\n        ${Nrun}\" > out_${l}_${iopt}/run_${l}_${iopt}_F_${icollo}.in
\ttest -f out_${l}_${iopt}/out_test_${l}_${iopt}_F_${icollo} || ./out_${l}_${iopt}/test.x < out_${l}_${iopt}/run_${l}_${iopt}_F_${icollo}.in >  out_${l}_${iopt}/out_test_${l}_${iopt}_F_${icollo}
\ttouch run_${l}_${iopt}_${icollo}.exists
 """ >> $makefile_name

icollo=1
 echo -e """
run_${l}_${iopt}_${icollo}.exists: run_${l}_${iopt}_0.exists
\techo -e \"        ${icollo}\\\\n        T\\\\n        ${l}    0    0    0\\\\n        ${Nrun}\" > out_${l}_${iopt}/run_${l}_${iopt}_T_${icollo}.in
\ttest -f out_${l}_${iopt}/out_test_${l}_${iopt}_T_${icollo} ||./out_${l}_${iopt}/test.x < out_${l}_${iopt}/run_${l}_${iopt}_T_${icollo}.in >  out_${l}_${iopt}/out_test_${l}_${iopt}_T_${icollo}
\techo  -e \"        ${icollo}\\\\n        F\\\\n        ${Nrun}\" > out_${l}_${iopt}/run_${l}_${iopt}_F_${icollo}.in
\ttest -f out_${l}_${iopt}/out_test_${l}_${iopt}_F_${icollo} || ./out_${l}_${iopt}/test.x < out_${l}_${iopt}/run_${l}_${iopt}_F_${icollo}.in >  out_${l}_${iopt}/out_test_${l}_${iopt}_F_${icollo}
\ttouch run_${l}_${iopt}_${icollo}.exists
 """ >> $makefile_name


done
done

(
echo -e "all: libgrid.a \n\n"
echo -e "generate.x:\n\t$FC_comp -target=native -c options.f90 \n\t$FC_comp -target=native -c generate.f90  \n\t$FC_comp -target=native options.o generate.o -o generate.x"
echo -e "all_gen: generate.x $TARGETS_EXE\n\n"
echo -e "all_run: $TARGETS_RUN\n\n"
echo -e "clean: \n\trm -Rf $DIRECTORIES *.exists generate.x *.o libtest.a out_best *.mod \n\n"

echo -e """
gen_best: all_gen all_run generate.x
\tbash get_results.sh
\t-mkdir out_best
\t./generate.x best < generate_best
\tcp qs_collocate_density.F qs_integrate_potential.F main.F out_best/
\tcp makefile_case out_best/Makefile
\t-mkdir out_best/TMP_best
\tmake -C out_best test.x
\t-rm -Rf out_best/TMP_best
"""

echo -e """

xyz_to_vab.o:
\tmake -C xyz_to_vab
\tcp xyz_to_vab/xyz_to_vab_optimised.o .

libgrid.a: gen_best xyz_to_vab.o
\tar r libgrid.a out_best/collocate_fast.o out_best/integrate_fast.o xyz_to_vab_optimised.o
"""


) >> $makefile_name
