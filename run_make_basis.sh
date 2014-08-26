#chmod 755 ./*.sh
#chmod 755 ./*.m

#make_basis.sh -i $mydir/PROCESS/Basis_Sets/Basis_Set_0.033333ms_neu/jmrui_InOutput/TextFiles/invivo -o $mydir/PROCESS/Basis_Sets/Basis_Set_0.033333ms_neu_Gilbert/LCM_output/invivo -a "0.0 1.3 1.633333 1.966666 2.3 2.633333 2.966666 3.3 3.633333 3.966666 4.3 4.633333"  -r $mydir/PROCESS/Basis_Sets/Basis_Set_0.033333ms_neu/jmrui_InOutput/TextFiles/invivo/dss_7T_2.txt -s 9.0 -e -0.2

make_basis.sh -i $mydir/PROCESS/Basis_Sets/Basis_Set_0.033333ms_WithLacAc/jmrui/Output -o $mydir/PROCESS/Basis_Sets/Basis_Set_0.033333ms_WithLacAc/LCModelOutput \
-a "0.0 1.3 1.633333 1.966666 2.3 2.633333 2.966666 3.3 3.633333 3.966666 4.3 4.633333"  -r $mydir/PROCESS/Basis_Sets/Basis_Set_0.033333ms_WithLacAc/jmrui/Output/dss.txt -s 9.0 -e -0.2
