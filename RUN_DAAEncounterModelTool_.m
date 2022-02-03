function [filename]=RUN_DAAEncounterModelTool_(inifile)
        % Copyright 2018 - 2020, MIT Lincoln Laboratory
    % SPDX-License-Identifier: X11
    %% Inputs
    % Using trajectories sampled from an Uncorrelated encounter model
    
    % Setup input parameter (.ini) file
    %parameterFile = [getenv('AEM_DIR_DAAENC') filesep 'Example_Inputs' filesep 'FWMEVsFWME.ini'];
    parameterFile = [getenv('AEM_DIR_DAAENC') filesep 'My_Inputs' filesep inifile];
    
    
    %% Generate Uncorrelated Encounters
    generateDAAEncounterSet(parameterFile);
    
    %% Get ready to plot encouters
    % Read in encounter set parameters
    iniSettings = ini2struct(parameterFile);
    
    % Grab encounter ids
    encIds = iniSettings.encIds;
    
    % Read in saved encounters
    s = load([getenv('AEM_DIR_DAAENC') filesep  iniSettings.saveDirectory filesep 'scriptedEncounters.mat']);
    
    %% Simulate encounters
    % Iterate
    for i = encIds
        % Get encounter
        sample = s.samples(i);
        
        % Encounter initial conditions
        ic1 = [0,sample.v_ftps(1),sample.n_ft(1),sample.e_ft(1),sample.h_ft(1),sample.heading_rad(1),sample.pitch_rad(1),sample.bank_rad(1),sample.a_ftpss(1)];
        ic2 = [0,sample.v_ftps(2),sample.n_ft(2),sample.e_ft(2),sample.h_ft(2),sample.heading_rad(2),sample.pitch_rad(2),sample.bank_rad(2),sample.a_ftpss(2)];
        
        % Events (dynamic controls)
        event1 = sample.updates(1).event;
        event2 = sample.updates(2).event;
        
        % Simulate dynamics
        % Dynamic constraints
        % v_low,v_high,dh_ftps_min,dh_ftps_max,qmax,rmax
        dyn1 = [1.7 1116 -10000 10000 deg2rad(3), 1000000];
        dyn2 = [1.7 1116 -10000 10000 deg2rad(3), 1000000];
        results = run_dynamics_fast(ic1,event1,dyn1,ic2,event2,dyn2,sample.runTime_s);
    
        % modified code start
        result1 = results(1);
        table1 = struct2table(result1);
        result2 = results(2);
        table2 = struct2table(result2);
        [filepath,inifilename,ext] = fileparts(parameterFile);
        date = [datetime('now')];
        datestring = datestr(date, 'dd_mmm_yyyy_HH_MM_SS_FFF');
    
        filename = append(inifilename, '_');
        filename = append(filename, datestring);
        outputfile1 = [getenv('AEM_DIR_DAAENC') filesep 'Output_Tables' filesep 'Ownship' filesep filename];
        writetable(table1, outputfile1)
    
        outputfile2 = [getenv('AEM_DIR_DAAENC') filesep 'Output_Tables' filesep 'Intruder' filesep filename];
        writetable(table2, outputfile2)
        % modified code end
    end

end