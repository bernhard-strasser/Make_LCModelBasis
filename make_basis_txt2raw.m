%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% program to read out .txt-files given by make_basis.sh, convert to .RAW and create basis.in file %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;close all;

     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1.  %%%%%%%%% read out info from info-file %%%%%%%%%
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%cd /data/mrsproc/PROCESS_Bernhard/Make_Basis_jmrui_to_basis %just for testing
info_fid = fopen('./tmp/metabo_info.txt','r');
% read out first line of in_file, which are the input-files or ./directory/*.txt
in_file = {fscanf(info_fid,'%s',1)};


% if a whole directory should be processed, then find out all the paths of all the .txt-files in this directory and save them as cell array.
if (numel(strfind(in_file{1} ,'.txt'))==0)
    txt_files = dir(sprintf('%s/*.txt', in_file{1}));   % in in_file{1} is the input-directory; sprintf makes ./in_dir/*.txt; dir(directory/*.txt) gives a struct array with fields name date bytes isdir datenum
                                                        %creates cell array with metabolite names. replaces .txt with nothing
    in_file = strcat(sprintf('%s/', in_file{1}), cellstr(char(txt_files.name)));    %txt_files.name is a string-array (or something other strange?), char(s1, s2,...) creates a string array out of this 
    clear txt_files
    total_files = numel(in_file);                                                  %strange stuff (or like here out of s1 s2), cellstr makes a cell array of strings, and then it gets concatenated by strcat
    out_dir = fscanf(info_fid,'%s',1);                                                  %so that it has the form ./directory/file.txt

% otherwise save the paths of the .txt-files given by user to make_basis.sh
else
    file_no=1;
    while numel(strfind(in_file{file_no},'.txt'))==1
        file_no=file_no+1;
        in_file = [in_file; fscanf(info_fid,'%s',1)];
    end
    total_files = file_no-1;
    out_dir = sprintf('%s',in_file{file_no});
    in_file(file_no)=[];
end

% get path of reference-file
ref_TMS_file = fscanf(info_fid,'%s',1);

%destroy the reference-file within the in_file if it is contained there
match_ref_log = logical(logical(cellfun(@numel,regexpi(in_file, ref_TMS_file))) + logical(cellfun(@numel,regexpi(in_file, 'dss'))));
if(~isequal(match_ref_log,zeros(1,size(in_file,2))))
    in_file(match_ref_log) = [];
    total_files = total_files-sum(match_ref_log);
end

%%%% get all the names of the metabolites and replace the input with their standard names (eg make Ala out of ala_7T and so on)
metabo_seekndestroy = struct('search', {'ala','asp','cho','(?<!p)cr','gaba','glc','gln','glu','gly','gpc','lac','lip_c','mI','ins','mm3','mm4','naa(?!g)','naag','pch','pcr','scyllo','tau'}, ...
'replace', {'Ala','Asp','Cho','Cr','GABA','Glc','Gln','Glu','Gly','GPC','Lac','Lip_c','Ins','Ins','mm3','mm4','NAA','NAAG','PCh','PCr','Scyllo','Tau'});
% (?<!p)cr means that if a 'p' is before the 'cr' it is no match, only if it's just 'cr'it is counted as a match. ("look behind from current position", see matlab internet help > regexp > lookaround operators), 
% the same for naa where naag is not counted as match (look ahead)

metabo_dummy = regexpi(in_file, '/\w*.txt', 'match');
metabo_names = [metabo_dummy{:}];

for search_dummy = 1:size({metabo_seekndestroy.search},2)
    % regexpi: searches all the metabo_names for the strings in metabo_seekndestroy.search
    match_log = logical(cellfun(@numel,regexpi(metabo_names, metabo_seekndestroy(search_dummy).search)));
    %if match_log is [0 0 ... 0] then metabo_names{match_log} = ... gives a problem.
    if(~isequal(match_log,zeros(1,size(metabo_names,2))))     
        metabo_names{match_log} = metabo_seekndestroy(search_dummy).replace;
    end
end

% get all the acq delays for which the conversion should be done
delay_no = 1;
acq_delay = [{fscanf(info_fid,'%s',1)}];
while ~(strcmp(acq_delay(delay_no),'END'))
    delay_no = delay_no+1;
    acq_delay = [acq_delay; fscanf(info_fid,'%s',1)];
    %str2double(acq_delay
end
total_delays = delay_no-1;
acq_delay(delay_no)=[];
acq_delay = str2double(acq_delay);

fclose(info_fid);


     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2.  %%%%%%%%%%%% read out data from .txt-files and write to .RAW-files and create makebasis.in files %%%%%%%%%%%%%%
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %%%% get header info (time between 2 data points and the field strength B0) from the first .txt-file
    first_txt_fid = fopen(in_file{1},'r');
    tline = fgetl(first_txt_fid);
    while ~strcmp(tline, 'Signal and FFT')
        if(numel(strfind(tline, 'PointsInDataset:'))>0)
            total_points = str2num(strrep(tline, 'PointsInDataset: ', ''));
        elseif(numel(strfind(tline, 'SamplingInterval:'))>0)
            delta_t = str2num(strrep(tline, 'SamplingInterval: ', ''))/1000;   %/1000 so that the unit is ms
        elseif(numel(strfind(tline, 'TransmitterFrequency:'))>0)
            hzpppm = str2num(strrep(tline, 'TransmitterFrequency: ', ''))/1000000;
        end
        tline = fgetl(first_txt_fid);
    end
    fclose(first_txt_fid);

    
    %%%% write that part of makebasis.in that is equal for all metabolites
for delay_no = 1:total_delays
    mkdir(sprintf('%s/%.6fms',out_dir,acq_delay(delay_no)));
    makebasis_out = sprintf('%s/%.6fms/makebasis_%.6f.in', out_dir, acq_delay(delay_no), acq_delay(delay_no));
    makebasis_fid = fopen(makebasis_out,'w');
    
    fprintf(makebasis_fid, ' $seqpar\n seq=''FID''\n');                     %says which sequence is used
    fprintf(makebasis_fid,' echot=%.6f\n', acq_delay(delay_no)); %%%??????????????????????????
    fprintf(makebasis_fid, ' $end\n fwhmba=0.010\n\n');                     %FWHM of basis peaks (singlets?) in ppm
    
    fprintf(makebasis_fid, ' $NMALL\n');
    fprintf(makebasis_fid,' HZPPPM=%8.4f\n', hzpppm);
    fprintf(makebasis_fid,' DELTAT=%10.9f\n', delta_t);
    fprintf(makebasis_fid,' nunfil=%d\n', total_points-round(acq_delay(delay_no)/delta_t));         %/delta_t: 1 point is delta_t ms --> 1 ms is 1/delta_t points.
    fprintf(makebasis_fid,' FILBAS=''%s/%.6fms/fid_%.6fms.basis''\n', out_dir, acq_delay(delay_no), acq_delay(delay_no));
    fprintf(makebasis_fid,' FILPS=''%s/%.6fms/fid_%.6fms.ps''\n', out_dir, acq_delay(delay_no), acq_delay(delay_no));
    fprintf(makebasis_fid,' AUTOSC=.false.\n');
    fprintf(makebasis_fid,' IDBASI=''FID TE=%.6f (April 2011)''\n', acq_delay(delay_no));
    fprintf(makebasis_fid,' ppmst=4.2  ppmend=0.2\n $END\n');
    fclose(makebasis_fid);
end


%read data of the reference.txt file that is used for all .RAW-files
data_ref_txt = importdata(sprintf('%s',ref_TMS_file), '\t', 21);

% write .RAW-data and that parts of makebasis.in that contain info of each metabolite
for file_no = 1:total_files
 
    
    data_met_txt = importdata(sprintf('%s', in_file{file_no}), '\t', 21);       %imports data from the in_file and gives an cell array with one struct for each metabolite
    %data_met_txt.data = data_ref_txt.data + data_met_txt.data;                  %adds the reference data so that for every metabolite there is the reference peak as well in the spectrum for LCM processing
    degzer = data_met_txt.textdata(logical(cellfun(@numel,regexpi(data_met_txt.textdata, 'ZeroOrder'))));
    degzer = str2double(strrep(strtrim(degzer),'ZeroOrderPhase: ', ''));
    degppm = data_met_txt.textdata(logical(cellfun(@numel,regexpi(data_met_txt.textdata, 'BeginTime'))));
    degppm = str2double(strrep(strtrim(degppm),'BeginTime: ', ''));
    
    
    for delay_no = 1:total_delays
        %%%%%%% write .RAW-file %%%%%%%
        raw_out = sprintf('%s/%.6fms/%s_%.6f.RAW', out_dir, acq_delay(delay_no), metabo_names{file_no}, acq_delay(delay_no));
        raw_fid = fopen(raw_out,'w');        %'w' = open or create file for writing, discard content; w+: same but read and write
        % write some header info to RAW-file
        fprintf(raw_fid, ' $NMID\n');                                                       %tramp is a factor in order to scale the spectrum of the metabolite. it is not important when using autoscaling.
        fprintf(raw_fid, ' ID=%s_%.6f.RAW\n',metabo_names{file_no},acq_delay(delay_no));	%volume gives the voxel size in ml. It is not important when using autoscaling; see also LCM-manual pages 90ff.
        % writing data in the format 2e14.5
        fprintf(raw_fid, ' fmtdat=''(2e14.5)''\n tramp=1.0\n volume=1.0\n $END\n');      
        trunc_points = round(acq_delay(delay_no)/delta_t);                                  %1 point means delta_t ms. so x ms are x/delta_t points.
        data_trunc = data_met_txt.data(trunc_points+1:size(data_met_txt.data,1),1:2);       %only writes columns 1 (real FID-data) and 2 (imaginary FID-data) (col3,4 = spectra) and just rows trunc_points+1 until end
        
        %imag = (-1.0)*data_trunc(:,2); 
                
        data_trunc=[(data_trunc(:,1))';(data_trunc(:,2))'];                                 %fwrite writes arrays from left to right!!!! 
        %data_trunc=[(data_trunc(:,1))';imag'];
        
        fprintf(raw_fid, '%14.5e%14.5e\n', data_trunc);                                                                                              
        fclose(raw_fid);     
        %clear data_trunc 
        
        %%%%%%% write metabolite-info to makebasis.in-file %%%%%%%
        makebasis_out = sprintf('%s/%.6fms/makebasis_%.6f.in', out_dir, acq_delay(delay_no), acq_delay(delay_no));
        makebasis_fid = fopen(makebasis_out,'a');    % 'a' = open or create file, append data/text to file
        fprintf(makebasis_fid, '\n\n $NMEACH\n'); 
        fprintf(makebasis_fid, ' filraw=''%s/%.6fms/%s_%.6f.RAW''\n',out_dir,acq_delay(delay_no),metabo_names{file_no},acq_delay(delay_no));
        fprintf(makebasis_fid, ' METABO=''%s''\n',metabo_names{file_no});
        fprintf(makebasis_fid, ' DEGZER=%3.1f\n',degzer);  %Zero order phase of metabo
        fprintf(makebasis_fid, ' DEGPPM=%3.1f\n',degppm);  %First order phase of metabo 
        
        if(strcmp(metabo_names{file_no}, 'PCh'))           %PCh has different concentration in this simulation
            fprintf(makebasis_fid, ' CONC=0.385\n');
        else
            fprintf(makebasis_fid, ' CONC=1.\n');
        end
        
        fprintf(makebasis_fid, ' concsc=1.,  fwhmsm=.0\n');  %concsc= concentration of the standard (reference), fwhmsm gibts nirgends im LCM Manual !!?? Hat Provencher dazugeschrieben???
        fprintf(makebasis_fid, ' PPMAPP=0.1, -.4\n');  
        %PPMAPP is the apparent (unreferenced) ppm-axis that contains referencing peak. If DSS (TMS) is the marker for the metabolite, then PPMAPP = 0.1, -0.4 is typically sufficient to bracket the peak.
        fprintf(makebasis_fid, ' $END'); 
        fclose(makebasis_fid);   
    end
    
    
    clear data_met_txt
end








