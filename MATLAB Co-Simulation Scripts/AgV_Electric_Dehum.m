%% AgV Greenhouse Co-Simulation with EnergyPlus and MLE+ (Electric Dehumidification Mode)
% Simulates electric dehumidification-based greenhouse performance across 925 locations

% Define input/output file paths (customize these before running)
inputFile = 'YOUR_FEED_CSV_FILE_NAME'; % <- Path to location list (site IDs, epw filenames, etc.)
weatherDir = fullfile('YOUR_BASE_DIRECTORY', 'TMY', 'epw_2014_2023'); % <- Edit this to point to your .epw files
idfFileName = 'YOUR_IDF_FILE_NAME'; % <- EnergyPlus model (.idf)
outputExcel = 'YOUR_OUTPUT_EXCEL_FILE_NAME'; % <- Output spreadsheet

% Read site info: SiteID, State, County, WeatherFile, etc.
testList = readmatrix(inputFile, 'FileType', 'spreadsheet', ...
    'Range', 'A2:M926', 'OutputType', 'string');

for j = 1:925
    %% Site-specific Setup
    weatherFile = char(fullfile(weatherDir, testList(j,12)));
    locationName = char(strcat(testList(j,1), " ", testList(j,3)));
    
    disp(['Running simulation for: ', locationName]); % Tracking

    %% Initialize EnergyPlus co-simulation
    ep = mlep;
    ep.idfFile = idfFileName;
    ep.epwFile = weatherFile;
    endTime = 365 * 24 * 3600; % One year in seconds
    ep.initialize;

    nRows = ceil(endTime / ep.timestep);
    logmat = zeros(nRows + 1, 59); % One extra for initialization
    iLog = 1;

    % Start simulation
    ep.start;

    % Initialize controls and storage
    VentCom = 0; DHCom = 0;
    SumCount = 10; AvgCount = 4;
    Hoursum = zeros(1, SumCount);
    Houravg = zeros(1, AvgCount);
    HourOP = zeros(8760, SumCount + AvgCount);

    t = 0;

    while t < endTime
        u = [VentCom, DHCom];
        y = ep.step(u);
        t = ep.time;

        logmat(iLog,:) = [t, y(:)'];
        iLog = iLog + 1;

        %% Greenhouse Controls
        GHRH = y(11);        % Greenhouse Relative Humidity
        InTemp = y(10);      % Indoor Temperature
        OutsideRH = y(52);   % Outside RH

        if GHRH > 70
            if OutsideRH > 70
                DHCom = 1; VentCom = 0;
            else
                DHCom = 0; VentCom = 1;
            end
        else
            DHCom = 0; VentCom = 0;
        end
        if InTemp < 15
            VentCom = 0;
        end

        %% Energy and Water Use Aggregation
        HGas   = sum(y(12:18)) / 1e6;
        HFan   = sum(y(19:25)) / 3600000;
        CElec  = sum(y(26:33)) / 3600000;
        CFan   = sum(y(34:41)) / 3600000;
        VentFan = y(50) / 3600000;
        Light   = y(51) / 3600000;
        DHElec  = sum(y(53:55)) / 3600000;
        CH2O    = sum(y(42:49));              % Evap water (m3)
        DHH2O   = sum(y(56:58)) / 1000;       % Extracted water (m3)
        GenElec = sum(y(1:8)) / 3600000;      % PV Generation

        % Collect hourly data
        if t > 0 && rem(t,3600) == 0
            Houravg = Houravg + [y(9), y(52), y(10), y(11)];
            Hoursum = Hoursum + [GenElec, HGas, HFan, CElec, CFan, CH2O, VentFan, Light, DHElec, DHH2O];
            Hourresults = [Houravg / 6, Hoursum];
            HourOP(t/3600,:) = Hourresults;
            Houravg(:) = 0; Hoursum(:) = 0;
        else
            Houravg = Houravg + [y(9), y(52), y(10), y(11)];
            Hoursum = Hoursum + [GenElec, HGas, HFan, CElec, CFan, CH2O, VentFan, Light, DHElec, DHH2O];
        end
    end

    %% Monthly Output Summary (8760 hours total)
    idx = [0, 744, 1416, 2160, 2880, 3624, 4344, 5088, 5832, 6552, 7296, 8016, 8760];
    MonthsExp = [];
    for m = 1:12
        avgVals = mean(HourOP(idx(m)+1:idx(m+1),1:4),1);
        sumVals = sum(HourOP(idx(m)+1:idx(m+1),5:end),1);
        MonthsExp = [MonthsExp, avgVals, sumVals];
    end

    %% Export to Excel
    outputRange = strcat("F", string(j+2), ":FQ", string(j+2));
    writematrix(MonthsExp, outputExcel, ...
        'FileType', 'spreadsheet', ...
        'Sheet', 'TMYList', ...
        'Range', outputRange);

    ep.stop;
    clc; % Clear for next site
end

disp("All electric dehumidification-based AgV greenhouse simulations completed.");
