%% Greenhouse Co-Simulation with EnergyPlus and MLE+ (Electric Dehumidification Mode)
% Simulates electric dehumidification-based greenhouse performance across 925 locations

% Define input/output file paths (customize these before running)
inputFile = 'YOUR_FEED_CSV_FILE_NAME'; % <- Path to location list (site IDs, epw filenames, etc.)
weatherDir = fullfile('YOUR_BASE_DIRECTORY', 'TMY', 'epw_2014_2023'); % <- Edit this to point to your .epw files
idfFileName = 'YOUR_IDF_FILE_NAME'; % <- EnergyPlus model (.idf)
outputExcel = 'YOUR_OUTPUT_EXCEL_FILE_NAME'; % <- Output spreadsheet

% Read EPW file list and site info
testList = readmatrix(inputFile, 'FileType', 'spreadsheet', ...
    'Range', 'A2:M926', 'OutputType', 'string');

for j = 1:925
    %% Site-specific setup
    weatherFile = char(fullfile(weatherDir, testList(j,12)));
    locationName = char(strcat(testList(j,1), " ", testList(j,3)));
    disp(['Running simulation for: ', locationName]);

    %% Initialize EnergyPlus co-simulation
    ep = mlep;
    ep.idfFile = idfFileName;
    ep.epwFile = weatherFile;
    endTime = 365 * 24 * 3600; % One year [s]
    ep.initialize;

    nRows = ceil(endTime / ep.timestep);
    logmat = zeros(nRows + 1, 51); % 50 output vars + time
    iLog = 1;

    ep.start;

    %% Initialize controls and storage
    VentCom = 0; DHCom = 0;
    SumCount = 9; AvgCount = 4;
    Hoursum = zeros(1, SumCount);
    Houravg = zeros(1, AvgCount);
    HourOP = zeros(8760, SumCount + AvgCount);
    t = 0;

    %% Simulation loop
    while t < endTime
        u = [VentCom, DHCom];
        y = ep.step(u);
        t = ep.time;

        logmat(iLog,:) = [t, y(:)'];
        iLog = iLog + 1;

        %% Dehumidification control logic
        GHRH = y(3);       % Greenhouse RH
        InTemp = y(2);     % Indoor temperature
        OutsideRH = y(44); % Outdoor RH

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

        %% Aggregated energy and water outputs
        HGas   = sum(y(4:10)) / 1e6;          % MJ
        HFan   = sum(y(11:17)) / 3600000;     % kWh
        CElec  = sum(y(18:25)) / 3600000;     % kWh
        CFan   = sum(y(26:33)) / 3600000;     % kWh
        CH2O   = sum(y(34:41));               % m³
        VentFan = y(42) / 3600000;            % kWh
        Light   = y(43) / 3600000;            % kWh
        DHElec  = sum(y(45:47)) / 3600000;    % kWh
        DHH2O   = sum(y(48:50)) / 1000;       % m³

        %% Hourly aggregation
        if t > 0 && rem(t,3600) == 0
            Houravg = Houravg + [y(1), y(44), y(2), y(3)]; % [CO2, OutRH, InTemp, InRH]
            Hoursum = Hoursum + [HGas, HFan, CElec, CFan, CH2O, VentFan, Light, DHElec, DHH2O];
            HourOP(t/3600,:) = [Houravg / 6, Hoursum];
            Houravg(:) = 0; Hoursum(:) = 0;
        else
            Houravg = Houravg + [y(1), y(44), y(2), y(3)];
            Hoursum = Hoursum + [HGas, HFan, CElec, CFan, CH2O, VentFan, Light, DHElec, DHH2O];
        end
    end

    %% Monthly aggregation (hourly data: 8760 rows)
    idx = [0, 744, 1416, 2160, 2880, 3624, 4344, 5088, 5832, 6552, 7296, 8016, 8760];
    MonthsExp = [];
    for m = 1:12
        avgVals = mean(HourOP(idx(m)+1:idx(m+1), 1:4), 1);  % CO2, RH, Temp, etc.
        sumVals = sum(HourOP(idx(m)+1:idx(m+1), 5:end), 1); % Energy + Water
        MonthsExp = [MonthsExp, avgVals, sumVals];
    end

    %% Export results to Excel
    outputRange = strcat("F", string(j+2), ":FE", string(j+2));
    writematrix(MonthsExp, outputExcel, ...
        'FileType', 'spreadsheet', ...
        'Sheet', 'TMYList', ...
        'Range', outputRange);

    ep.stop;
    clc;
end

disp("All electric dehumidification-based polycarbonate greenhouse simulations completed.");
