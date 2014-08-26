cd /data/mrsproc/PROCESS_Bernhard/Make_Basis_jmrui_to_basis
chmod 755 ./*.sh
chmod 755 ./*.m
#make_basis.sh -i "./mI_7T.txt ./asp_7T.txt naa_7T.txt" -o ./out -a 13.3333333

#make_basis.sh -i ./met_sim_30000Hz/tx -o ./out -a 1.333333 -r ./met_sim_30000Hz/tx/dss_7T.txt

make_basis.sh -i ./met_sim_30000Hz/fid_varTE -o ./outx -a 0.0 -r ./met_sim_30000Hz/fid_varTE/dss.txt

