%% Greenhouse Co-Simulation with EnergyPlus and MLE+ (Ventilation Mode)
% Simulates ventilation-based greenhouse performance across 925 locations

% Define input/output file paths (customize these before running)
inputFile = 'YOUR_FEED_CSV_FILE_NAME'; % <- Path to location list (site IDs, epw filenames, etc.)
weatherDir = fullfile('YOUR_BASE_DIRECTORY', 'TMY', 'epw_2014_2023'); % <- Edit this to point to your .epw files
idfFileName = 'YOUR_IDF_FILE_NAME'; % <- EnergyPlus model (.idf)
outputExcel = 'YOUR_OUTPUT_EXCEL_FILE_NAME'; % <- Output spreadsheet

% Read site info: SiteID, State, County, WeatherFile, etc.
testList = readmatrix(inputFile, 'FileType', 'spreadsheet', ...
    'Range', 'A2:M926', 'OutputType', 'string');

for j = 1:925
    %% Location-specific setup
    weatherFile = char(fullfile(weatherDir, testList(j,12)));
    locationName = char(strcat(testList(j,1), " ", testList(j,3)));
    disp(['Running simulation for: ', locationName]);

    %% Initialize co-simulation
    ep = mlep;
    ep.idfFile = idfFileName;
    ep.epwFile = weatherFile;
    endTime = 365 * 24 * 3600; % 1 year in seconds
    ep.initialize;

    nRows = ceil(endTime / ep.timestep);
    logmat = zeros(nRows + 1, 44); % 43 outputs + time
    iLog = 1;

    ep.start;

    %% Initial values and control
    VentCom = 0;
    SumCount = 7; AvgCount = 3;
    Hoursum = zeros(1, SumCount);
    Houravg = zeros(1, AvgCount);
    HourOP = zeros(8760, SumCount + AvgCount);
    t = 0;

    %% Simulation loop
    while t < endTime
        u = VentCom;
        y = ep.step(u);
        t = ep.time;

        logmat(iLog,:) = [t, y(:)'];
        iLog = iLog + 1;

        %% Ventilation logic
        GHRH = y(3);    % Greenhouse RH
        InTemp = y(2);  % Indoor Temp

        VentCom = (GHRH > 70); % Vent if RH exceeds threshold
        if InTemp < 15
            VentCom = 0; % Disable venting if too cold
        end

        %% Energy & Water Calculations
        HGas    = sum(y(4:10)) / 1e6;       % MJ
        HFan    = sum(y(11:17)) / 3600000;  % kWh
        CElec   = sum(y(18:25)) / 3600000;  % kWh
        CFan    = sum(y(26:33)) / 3600000;  % kWh
        CH2O    = sum(y(34:41));            % m³ evap water
        VentFan = y(42) / 3600000;          % kWh
        Light   = y(43) / 3600000;          % kWh

        %% Hourly aggregation
        if t > 0 && rem(t,3600) == 0
            Houravg = Houravg + [y(1), y(2), y(3)]; % [CO2, Temp, RH]
            Hoursum = Hoursum + [HGas, HFan, CElec, CFan, CH2O, VentFan, Light];
            HourOP(t/3600,:) = [Houravg / 6, Hoursum];
            Houravg(:) = 0; Hoursum(:) = 0;
        else
            Houravg = Houravg + [y(1), y(2), y(3)];
            Hoursum = Hoursum + [HGas, HFan, CElec, CFan, CH2O, VentFan, Light];
        end
    end

    %% Monthly aggregation (based on hourly results)
    idx = [0, 744, 1416, 2160, 2880, 3624, 4344, 5088, 5832, 6552, 7296, 8016, 8760];
    MonthsExp = [];
    for m = 1:12
        avgVals = mean(HourOP(idx(m)+1:idx(m+1), 1:3), 1);
        sumVals = sum(HourOP(idx(m)+1:idx(m+1), 4:end), 1);
        MonthsExp = [MonthsExp, avgVals, sumVals];
    end

    %% Export results to Excel
    outputRange = strcat("F", string(j+2), ":DU", string(j+2));
    writematrix(MonthsExp, outputExcel, ...
        'FileType', 'spreadsheet', ...
        'Sheet', 'TMYList', ...
        'Range', outputRange);

    ep.stop;
    clc; % Prepare for next location
end

disp("All ventilation-based polycarbonate greenhouse simulations completed.");
