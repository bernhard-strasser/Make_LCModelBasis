chmod 755 ./*.sh
chmod 755 ./*.m

make_basis.sh -i ./met_sim_30000Hz/txt -o ./out -a "1.333333 1.666666 2.0 2.333333 2.666666 3.0 3.333333 3.666666 4.0 4.333333 4.666666 5.0 5.333333 5.666666 6.0 7.333333 7.666666 8.0 8.333333 8.666666 9.0 9.333333 9.666666 10.0"  -r ./met_sim_30000Hz/txt/dss_7T.txt


#make_basis.sh -i ./met_sim_30000Hz/txt -o ./out -a 4.0  -r ./met_sim_30000Hz/txt/dss_7T.txt

#not working: 7.666666 4.0
#8.0 8.333333 8.666666 9.0 9.333333 9.666666 10.0"
#make_basis.sh -i ./met_sim_30000Hz/fid_varTE -o ./outx -a 1.333333333 -r ./met_sim_30000Hz/fid_varTE/dss.txt

