%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% program to read out .txt-files given by make_basis.sh, convert to .RAW and create basis.in file %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear variables;close all;




%% 1. Load File with all the info

load('./tmp/BasisCalTestings.mat')
acq_delay = acq_delay(1);
out_dir_Calib = [out_dir '/BasisCalibrationTest'];

    
%% 4. Write CalibTest.control
    


mkdir(out_dir_Calib);
CalibTest_out = sprintf('%s/CalibTest.control', out_dir_Calib);
CalibTest_fid = fopen(CalibTest_out,'w');



fprintf(CalibTest_fid, ' $LCMODL\n');
fprintf(CalibTest_fid, ' BASCAL=T\n');
fprintf(CalibTest_fid, ' CHBCAL=''GPC''\n');
fprintf(CalibTest_fid, ' NCALIB=1\n');
fprintf(CalibTest_fid, ' CHCALI(1)=''PCh''\n');
fprintf(CalibTest_fid, ' PPMST=3.45\n');
fprintf(CalibTest_fid, ' HZPPPM=%8.4f, DELTAT=%10.9f, NUNFIL=%d\n', hzpppm, delta_t, total_points-round(acq_delay/(1000*delta_t)));
fprintf(CalibTest_fid, ' OWNER=''MR Exzellenzzentrum, Radiodiagnostik, MUW''\n');
fprintf(CalibTest_fid, ' TITLE=''CalibTest''\n');
fprintf(CalibTest_fid, ' FILBAS=''%s/fid_%6fms.basis''\n', out_dir, acq_delay);
fprintf(CalibTest_fid, ' NEACH=99\n');
fprintf(CalibTest_fid, ' FILPS=''%s/CalibrationTest_%6fms.ps''\n', out_dir_Calib, acq_delay);
fprintf(CalibTest_fid, ' FILRAW=''%s/%6fms/PCh_%6f.RAW''\n', out_dir, acq_delay, acq_delay);
fprintf(CalibTest_fid, ' $END\n');




fclose(CalibTest_fid);




