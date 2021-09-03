%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% program to read out .txt-files given by make_basis.sh, convert to .RAW and create basis.in file %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear variables;close all;



%% 1. read out info from info-file

     

run ./tmp/InitialParameters.m

% if a whole directory should be processed, then find out all the paths of all the .txt-files in this directory and save them as cell array.
if (numel(strfind(in_file{1} ,'.txt'))==0)
    txt_files = dir(sprintf('%s/*.txt', in_file{1}));                               %in_file{1} is the input-directory; sprintf makes ./in_dir/*.txt; dir(directory/*.txt) gives a struct array with fields: name date ...
    in_file = strcat(sprintf('%s/', in_file{1}), cellstr(char(txt_files.name)));    %creates cell array with metabolite names. 
    clear txt_files                                                                 %txt_files.name is something strange, char(s1, s2,...) makes a character array (ie just a string) out of this 
                                                                                    %so that it has the form ./directory/file.txt
% otherwise save the paths of the .txt-files given by user to make_basis.sh
else
    out_dir = sprintf('%s',in_file{file_no});
end

total_delays = numel(acq_delay);
total_files = numel(in_file);





%% 2. Replace the file-list names with their LCModel-names 

     
%%%%%% destroy the reference-file within the in_file if it is contained there or any file with a name containing dss %%%%%%%
match_ref_log = logical(logical(cellfun(@numel,regexpi(in_file, ref_TMS_file))) + logical(cellfun(@numel,regexpi(in_file, 'dss'))));
if(~isequal(match_ref_log,zeros(1,size(in_file,2))))
    in_file(match_ref_log) = [];
    total_files = total_files-sum(match_ref_log);
end


%%%%%%% get all the names of the metabolites and replace the input with their standard names (eg make Ala out of ala_7T and so on) %%%%%%%%
metabo_seekndestroy = struct( ...
'search', ...
{'acetate','act','ala','alphaglucose','asp','betaglucose','cho','(?<!p)cr','ethanolamine','gaba','glc(?!_)','gln','glu(?!c)','gly','gpc','GSH','Glutathione','ins','lac','lip_c','mI' ,'mm3','mm4','naa(?!g)','naag','pch','pcr','scyllo','tau','fat','water','MM_meas','TwoHG','2HG'}, ...
'replace', ...
{'Act'    ,'Act','Ala','Glc'         ,'Asp','Glc_B'   ,'Cho','Cr'      ,'ETA','GABA','Glc'     ,'Gln','Glu'     ,'Gly','GPC','GSH','GSH'        ,'Ins','Lac','Lip_c','Ins','mm3','mm4','NAA'     ,'NAAG','PCh','PCr','Scyllo','Tau','fat','water','MM_meas','TwoHG','TwoHG'});
% (?<!p)cr means that if a 'p' is before the 'cr' it is no match, only if it's just 'cr'it is counted as a match. ("look behind from current position", see matlab internet help > regexp > lookaround operators), 
% the same for naa where naag is not counted as match (look ahead)
% alphaglucose = Glc, because betaglucose can hardly be detected in vivo


metabo_dummy = regexpi(in_file, '/\w*\.txt', 'match');    % regexpi(s1,s2,'match') searches for string s2 within  string s1, and gives those parts that matches, /\w* means: search for string starting with / followed
metabo_dummy = regexprep([metabo_dummy{:}],'/','');
metabo_dummy = regexprep(metabo_dummy,'.txt','');

metabo_names = metabo_dummy;                         % by any number or any char; \ is an escape symbol, means that . should not treated as regul expre but as literal char. so this searches for 'anything/anything.txt'


for search_dummy = 1:size({metabo_seekndestroy.search},2)
    fprintf('\nSearching for ... %s',metabo_seekndestroy(search_dummy).search)
    match_log = logical(cellfun(@numel,regexpi(metabo_names, metabo_seekndestroy(search_dummy).search)));
    % regexpi: searches all the metabo_names for the strings in metabo_seekndestroy.search; then the numel-function is done for every cell of the array; a logical array is made out of that, giving the cells with matches
    %if match_log is [0 0 ... 0] then metabo_names{match_log} = ... gives a problem.
    if(sum(match_log)>1)
        fprintf('\n\nError: The search-string %s was found twice in your text-files, namely as %s and %s.\nAborting Program\n',metabo_seekndestroy(search_dummy).search,metabo_names{match_log})
        quit force
    else
        if(~isequal(match_log,zeros(1,size(metabo_names,2))))     
            metabo_names{match_log} = metabo_seekndestroy(search_dummy).replace;
        end
    end
end



%% 3. Get info from first .txt-file


first_txt_fid = fopen(in_file{1},'r');
tline = fgetl(first_txt_fid);
while ~strcmp(tline, 'Signal and FFT')
    if(numel(strfind(tline, 'PointsInDataset:'))>0)
        total_points = str2num(strrep(tline, 'PointsInDataset: ', ''));
    elseif(numel(strfind(tline, 'SamplingInterval:'))>0)
        delta_t = str2num(strrep(tline, 'SamplingInterval: ', ''))/1000;   %/1000 so that the unit is s
    elseif(numel(strfind(tline, 'TransmitterFrequency:'))>0)
        hzpppm = str2num(strrep(tline, 'TransmitterFrequency: ', ''))/1000000;   % [MHz]
    end
    tline = fgetl(first_txt_fid);
end
fclose(first_txt_fid);

if(~exist('vecSizeOfOutput','var'))
    vecSizeOfOutput = total_points;
end
if(exist('dwelltimeOfOutput_ms','var'))
	delta_t_Output = dwelltimeOfOutput_ms/1000;
else
	delta_t_Output = delta_t * total_points/vecSizeOfOutput;
end
if(delta_t_Output ~= delta_t || vecSizeOfOutput ~= total_points)
	OldGrid = 0:delta_t:(delta_t*(total_points-1));
	NewGrid = 0:delta_t_Output:(delta_t_Output*(vecSizeOfOutput-1));
end
save('./tmp/BasisCalTestings.mat', 'hzpppm', 'delta_t','delta_t_Output', 'total_points','vecSizeOfOutput', 'out_dir', 'acq_delay');
    

% for fileno = 1:numel(in_file)
% 
%     [CurData,CurjMRUIInfo] = io_readjmrui(in_file{fileno});
%     test = io_writejmrui(CurData,CurjMRUIInfo,['./tmp' regexprep(in_file{fileno},regexprep(in_file{fileno},'/[^/]*$',''),'')]);
% end


%%




%% 4. Write that part of makebasis.in that is equal for all metabolites
    

for delay_no = 1:total_delays
    mkdir(sprintf('%s/%.6fms',out_dir,acq_delay(delay_no)));
    makebasis_out = sprintf('%s/%.6fms/makebasis_%.6f.in', out_dir, acq_delay(delay_no), acq_delay(delay_no));
    makebasis_fid = fopen(makebasis_out,'w');
    
    fprintf(makebasis_fid, ' $seqpar\n seq=''FID''\n');                                                              %says which sequence is used
    fprintf(makebasis_fid,' echot=%.6f\n', acq_delay(delay_no));
    fprintf(makebasis_fid, ' $end\n fwhmba=0.020\n\n');                                                              %FWHM of basis peaks (singlets?) in ppm
    
    fprintf(makebasis_fid, ' $NMALL\n');
    fprintf(makebasis_fid,' HZPPPM=%8.4f\n', hzpppm);
    fprintf(makebasis_fid,' DELTAT=%10.9f\n', delta_t_Output);
    fprintf(makebasis_fid,' nunfil=%d\n', vecSizeOfOutput-round(acq_delay(delay_no)/(1000*delta_t_Output)));                   %1 point is 1000delta_t ms --> 1 ms is 1/(1000delta_t) points. -> acq_delay ms are acq_del/(1000delta_t) p
    fprintf(makebasis_fid,' FILBAS=''%s/fid_%.6fms.basis''\n', out_dir, acq_delay(delay_no));   %path where basis-file should be created
    fprintf(makebasis_fid,' FILPS=''%s/fid_%.6fms.ps''\n', out_dir, acq_delay(delay_no));
    fprintf(makebasis_fid,' AUTOSC=.false.\n');                                                                      %Autoscaling: scales the individual metabos automatically
    %fprintf(makebasis_fid,' AUTOPH=.TRUE.\n');
    fprintf(makebasis_fid,' IDBASI=''FID TE=%.6f (April 2011)''\n', acq_delay(delay_no));
    fprintf(makebasis_fid,' ppmst=%3.1f  ppmend=%3.1f\n $END\n\n\n', ppm_start, ppm_end);                                                    %area of ppm for which LCM creates the basis-metabos            
    
    fclose(makebasis_fid);
end



%% 5. Write .RAW-files and the metabolite-dependend part of makebasis.in


%read data of the reference.txt file that is used for all .RAW-files
data_ref_txt = importdata(sprintf('%s',ref_TMS_file), '\t');
if(exist('NewGrid','var'))
	
	% If our new grid e.g. is much shorter in time, we would get strong gibbs-ringing because we measure so shortly, and the FID is not decayed. In this case, let the new data decay the same
	% as the old.
	if(max(NewGrid) ~= max(OldGrid))
		[Maxima,peakloc] = findpeaks(data_ref_txt.data(:,1));
		times = (peakloc-1)*delta_t;
		ExpFitty = fit(times,Maxima,'exp1');
		a = coeffvalues(ExpFitty); a = -1/a(2);
		ExpAddDecay = repmat(transpose(exp(- (0:delta_t_Output:max(NewGrid))/max(NewGrid) *(max(OldGrid)-max(NewGrid))/a)),[1 2]);
	end
	
    data_ref_txt2 = transpose(interp1(OldGrid,data_ref_txt.data(:,1),NewGrid));
    data_ref_txt2(:,2) = interp1(OldGrid,data_ref_txt.data(:,2),NewGrid);
	if(exist('ExpAddDecay','var'))
		data_ref_txt2 = data_ref_txt2 .* ExpAddDecay;									% Additionally decay data, so that we get same gibbs-ringing artifact than before 
	end
    data_ref_txt2(:,3) = interp1(OldGrid,data_ref_txt.data(:,3),NewGrid);
    data_ref_txt2(:,4) = interp1(OldGrid,data_ref_txt.data(:,4),NewGrid);
    data_ref_txt.data = data_ref_txt2; clear data_ref_txt2    
elseif(vecSizeOfOutput > total_points)
        error('Error: vecSizeOfOutput > total_points.')
end

%%%%%%%% write .RAW-data and that parts of makebasis.in that contain info of each metabolite %%%%%%%
for file_no = 1:total_files
 
    data_met_txt = importdata(sprintf('%s', in_file{file_no}), '\t');       %imports data from the in_file and gives an cell array with one struct for each metabolite
    degzer = data_met_txt.textdata(logical(cellfun(@numel,regexpi(data_met_txt.textdata, 'ZeroOrder'))));
    degzer = str2double(strrep(strtrim(degzer),'ZeroOrderPhase: ', ''));
    BeginTime = data_met_txt.textdata(logical(cellfun(@numel,regexpi(data_met_txt.textdata, 'BeginTime'))));
    BeginTime = str2double(strrep(strtrim(BeginTime),'BeginTime: ', ''));
    if(strcmp(metabo_names{file_no},'MM_meas'))
        data_met_txt.data = data_met_txt.data/1000;
    end
    
    
    % Assuming vecSizeOfOutput < total_points
    if(exist('NewGrid','var'))
        data_met_txt2 = transpose(interp1(OldGrid,data_met_txt.data(:,1),NewGrid));
        data_met_txt2(:,2) = interp1(OldGrid,data_met_txt.data(:,2),NewGrid);
		if(exist('ExpAddDecay','var'))
			data_met_txt2 = data_met_txt2 .* ExpAddDecay;
		end
        data_met_txt2(:,3) = interp1(OldGrid,data_met_txt.data(:,3),NewGrid);
        data_met_txt2(:,4) = interp1(OldGrid,data_met_txt.data(:,4),NewGrid);
        data_met_txt.data = data_met_txt2; clear data_met_txt2
    end
    
    for delay_no = 1:total_delays
        
        BeginTime_AD = BeginTime + acq_delay(delay_no)/1000;
        degppm = hzpppm * BeginTime_AD * 360 * 0;
        %%%%%%% write .RAW-file %%%%%%%
        raw_out = sprintf('%s/%.6fms/%s_%.6f.RAW', out_dir, acq_delay(delay_no), metabo_names{file_no}, acq_delay(delay_no));
        raw_fid = fopen(raw_out,'w');                                                       %'w' = open or create file for writing, discard content; w+: same but read and write
        % write some header info to RAW-file
        fprintf(raw_fid, ' $NMID\n');                                                       %tramp is a factor in order to scale the spectrum of the metabolite. it is not important when using autoscaling.
        fprintf(raw_fid, ' ID=%s_%.6f.RAW\n',metabo_names{file_no},acq_delay(delay_no));	%volume gives the voxel size in ml. It is not important when using autoscaling; see also LCM-manual pages 90ff.
        fprintf(raw_fid, ' fmtdat=''(2e14.5)''\n tramp=1.0\n volume=1.0\n $END\n');  
        % writing data in the format 2e14.5
        % if condition for MM inclusion - this implementation should be
        % correct for acq delays bigger than 1.3, however, this should be
        % double tested (now the acquisition delay for mm biger than 1.3ms is the difference see elseif part)
        if acq_delay(delay_no)<=1.3 && strcmp(metabo_names{file_no},'MM_meas')
            trunc_points = 0; 
        elseif acq_delay(delay_no)>1.3 && strcmp(metabo_names{file_no},'MM_meas')
            trunc_points = round((acq_delay(delay_no)-acq_delay(delay_no-1))/(1000*delta_t_Output));
        else
            trunc_points = round(acq_delay(delay_no)/(1000*delta_t_Output));                                                   %1 point means delta_t_Output ms. so x ms are x/delta_t_Output points.
        end
        

        %adds the reference data so that for every metabolite there is the reference peak as well in the spectrum for LCM processing; but LCM has a problem when the real part of the ref peak is negative everywhere;
        %so the reference peak get not truncated at the beginning (then it would get a phase 1st order and could be totally negative) but at the end; then it gets added to the metabo FID that gets truncated at the 
        %beginning. If one would not truncate the ref FID but add the trunc metabo FID to the (trunc_point+1). point of the ref peak, this would be equal to setting the metabo FID at the beginning to zero which leads
        %to shit.
        data_trunc = data_met_txt.data(trunc_points+1:end,1:2)+data_ref_txt.data(1:vecSizeOfOutput-trunc_points,1:2);  %only writes columns 1 (real FID-data) and 2 (imaginary FID-data) (col3,4 = spectra) 
        
        data_trunc(:,2) = (-1)*data_trunc(:,2);                                             %multiplying the imaginary part of FID results in flipping the spectrum (eg when the reference peak is right to         
        data_trunc=[(data_trunc(:,1))';data_trunc(:,2)'];                                   %some other peak after multiplying it is on the left.) Why is this needed to be done??
                                                                                            %fprintf writes arrays from left to right!!!!  so this [data_trunc(:,1))' ...
        fprintf(raw_fid, '%14.5e%14.5e\n', data_trunc);                                                                                              
        fclose(raw_fid);  
        clear data_trunc 
        
        %%%%%%% write metabolite-info to makebasis.in-file %%%%%%%
        makebasis_out = sprintf('%s/%.6fms/makebasis_%.6f.in', out_dir, acq_delay(delay_no), acq_delay(delay_no));
        makebasis_fid = fopen(makebasis_out,'a');               % 'a' = open or create file, append data/text to file
        fprintf(makebasis_fid, ' $NMEACH\n'); 
        fprintf(makebasis_fid, ' filraw=''%s/%.6fms/%s_%.6f.RAW''\n',out_dir,acq_delay(delay_no),metabo_names{file_no},acq_delay(delay_no));
        fprintf(makebasis_fid, ' METABO=''%s''\n',metabo_names{file_no});
        if strcmp(metabo_names{file_no},'MM_meas')
            degzer = 0;
            fprintf(makebasis_fid, ' DEGZER=%3.1f\n',degzer);       %Zero order phase of MM
        else
            fprintf(makebasis_fid, ' DEGZER=%3.1f\n',degzer);       %Zero order phase of metabo
        end
        
        fprintf(makebasis_fid, ' DEGPPM=%3.1f\n',degppm);       %First order phase of metabo 
        
%         if(strcmp(metabo_names{file_no}, 'PCh'))                %PCh has different concentration in this simulation
%             fprintf(makebasis_fid, ' CONC=0.385\n');               % 0.385
%         else
            fprintf(makebasis_fid, ' CONC=1.\n');
%        end
        if strcmp(metabo_names{file_no},'MM_meas')
        %fprintf(makebasis_fid, ' XTRASH = -0.175\n');           % manually tuned shift for MM
	fprintf(makebasis_fid, ' XTRASH = -0.094\n'); 
        else
        fprintf(makebasis_fid, ' XTRASH = -0.0005\n');           % Extra Shift: Shifts All Data by e.g. -0.05 ppm
        end
        fprintf(makebasis_fid, ' concsc=1.,  fwhmsm=.0\n');     %concsc= concentration of the standard (reference), fwhmsm gibts nirgends im LCM Manual !!?? Hat Provencher dazugeschrieben???
        fprintf(makebasis_fid, ' PPMAPP=0.1, -.4\n');  
        %PPMAPP is the apparent (unreferenced) ppm-axis that contains referencing peak. If DSS (TMS) is the marker for the metabolite, then PPMAPP = 0.1, -0.4 is typically sufficient to bracket the peak.
        fprintf(makebasis_fid, ' $END\n\n');                    %at the end of makebasis.in there has to be a new line after $END, otherwise LCM doesn't create anything for the last metabolite!
        fclose(makebasis_fid);   
    end
    
    
    clear data_met_txt
end



