#################################################################################
#######  Create .basis-files for LCModel fitting out of jmRUI-txt-files   #######
#################################################################################

######### This program creates .RAW-files out of simulated .txt-files using jmRUI and files for LCM-procession (makebasis.in-files). These files get then processed by LCM which creates .basis and .ps-files.
######### The .basis-files can then be used as a basis in LCM for metabolite fitting. You can change the acquisition delay (for a FID-sequence).


######### You can either parse the name of the directory with all the .txt-files or give the program all the names with the .txt-files.
######### Make sure that there are no other txt-files in the folder you give to  the program except the ones that should be included to the basis set and the TMS-reference-file.
######### If you give individual .txt-files to the program or several acq-delays, put them in qoutation marks ".
######### The .txt-files have to include the metabolite names in their names. The program searches for:
######### 'ala','asp','cho','cr','gaba','glc','gln','glu','gly','gpc','lac','lip_c','mI','ins','mm3','mm4','naa','naag','pch','pcr','scyllo','tau' (case-insensitive)

echo -e "\n\n   START"

#1.
############# DEFINE ARGUMENTS/PARAMETER OPTIONS ####################

in_flag=0
out_flag=0
acq_delay_flag=0
reference_TMS_flag=0

in_file="./"
out_dir="./basis_files"
acq_delay=0

while getopts 'i:o:a:r:' OPTION
do
	case $OPTION in
	  i)	in_flag=1
			in_file="$OPTARG"
			;;
	  o)	out_flag=1
			out_dir="$OPTARG"
			;;
	  a)	acq_delay_flag=1
			acq_delay="$OPTARG"
			;;
	  r)	reference_TMS_flag=1
			reference_TMS_file="$OPTARG"
			;;
	  ?)	printf "Usage: %s: [-i input_file or input_directory] (default: ./*.txt) [-o output_dir] (default: ./basis_files)  [-a acq_delay] (default=0)\n" $(basename $0) >&2
			exit 2
			;;
	esac
done
shift $(($OPTIND - 1))

#if [ $reference_TMS_flag -eq 0 ]; then					###Setting default for reference TMS file
#	#length_first_file=`expr "$in_file" : '.txt'`
#	#echo "length: $length_first_file"
#	echo "infile: $in_file"
#	echo ""
#	xxx=${in_file%%txt*.txt}
#	echo -e "trunc: $xxx\n"

#	dummy1='/*.'
#	dummy2='/dss.txt'
#	xxy=${xxx/##$dummy1/$dummy2}
#	echo $xxy
##	first_file=`${in_file:1:$length_first_file}`
##	echo "first_file: $first_file"
#	#reference_TMS_file=${in_file/*.mnc/${ms}_CORR.mnc}
#fi


#2.
################## WRITE INFO TO tmp.txt  ########################
echo -e "\nWrite user input to temp file!"
rm -r tmp
mkdir tmp
tmp="./tmp/metabo_info.txt"

#write info to parameter file#
touch $tmp			
chmod 755 $tmp   ### 755 = user: write read exec   group: read exec    world: read exec
echo ${in_file} >  $tmp
echo ${out_dir} >>  $tmp
echo ${reference_TMS_file} >> $tmp
echo ${acq_delay} >>  $tmp
echo "END" >>  $tmp

#3.
############ READ OUT INPUT.txt-FILES, SAVE THEM AS .RAW-FILES AND WRITE makebasis.in  ############
echo -e "\n\nRead out input.txt-files, create .RAW-files and write makebasis.in"

rm -r $out_dir
m78 -nodisplay -nojvm < make_basis_txt2raw.m

echo -e "\n\nLCmodel processing started!\n"

OutDir_list=$(find $out_dir/*ms -type d)

for out_sub_dir in $OutDir_list ; do
	echo "Processing $out_sub_dir"
	$HOME/.lcmodel/bin/makebasis < $out_sub_dir/makebasis*.in
done


#rm -r ./tmp
echo -e "\n\n   END"



