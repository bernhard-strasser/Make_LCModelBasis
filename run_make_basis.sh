#chmod 755 ./*.sh
#chmod 755 ./*.m

#make_basis.sh -i $mydir/PROCESS/Basis_Sets/Basis_Set_0.033333ms_neu/jmrui_InOutput/TextFiles/invivo -o $mydir/PROCESS/Basis_Sets/Basis_Set_0.033333ms_neu_Gilbert/LCM_output/invivo -a "0.0 1.3 1.633333 1.966666 2.3 2.633333 2.966666 3.3 3.633333 3.966666 4.3 4.633333"  -r $mydir/PROCESS/Basis_Sets/Basis_Set_0.033333ms_neu/jmrui_InOutput/TextFiles/invivo/dss_7T_2.txt -s 9.0 -e -0.2

#./make_basis.sh -i $mydir/PROCESS/Basis_Sets/Basis_Set_0.033333ms_WithLacAc/jmrui/Output -o $mydir/PROCESS/Basis_Sets/Basis_Set_0.033333ms_WithLacAc_PChConc1_222/LCModelOutput \
#-a "0.0 2.4 3.5 4.6"  -r $mydir/PROCESS/Basis_Sets/Basis_Set_0.033333ms_WithLacAc/jmrui/Output/dss.txt -s 9.0 -e -0.2


#./make_basis.sh -i $mydir/PROCESS/Basis_Sets/Basis_Set_0.033333ms_WithLacAc/jmrui/Output -o $mydir/PROCESS/Basis_Sets/Basis_Set_0.033333ms_WithLacAc_PChConc1_CalibTest2/LCModelOutput \
#-a "0.0"  -r $mydir/PROCESS/Basis_Sets/Basis_Set_0.033333ms_WithLacAc/jmrui/Output/dss.txt -s 9.0 -e -0.2





#./make_basis.sh -i /mokka1/projects/MRSI_Projects/Basis_Sets/Basis_Set_0.033333ms_WithLacAc_PChConc1_NoNAAGGluMoiety/jmrui/Output \
#-o /mokka1/projects/MRSI_Projects/Basis_Sets/Basis_Set_0.033333ms_WithLacAc_PChConc1_NoNAAGGluMoiety_narrow/LCModelOutput \
#-a "0.0"  -r /mokka1/projects/MRSI_Projects/Basis_Sets/Basis_Set_0.033333ms_WithLacAc_PChConc1_NoNAAGGluMoiety/jmrui/Output/dss.txt -s 4.2 -e 0.2




./make_basis.sh -i /mokka1/projects/MRSI_Projects/Basis_Sets/Basis_Set_0.033333ms_WithLacAc_PChConc1_NoNAAGGluMoiety_CorrectedGABA/jmrui/Output \
-o /mokka1/projects/MRSI_Projects/Basis_Sets/Basis_Set_0.033333ms_WithLacAc_PChConc1_NoNAAGGluMoiety_CorrectedGABA/LCModelOutput_DeGraafGABA_ChangedLipc \
-a "0.0"  -r /mokka1/projects/MRSI_Projects/Basis_Sets/Basis_Set_0.033333ms_WithLacAc_PChConc1_NoNAAGGluMoiety_CorrectedGABA/jmrui/Output/dss.txt -s 4.2 -e -0.2
