classdef DataProvider_cls < handle
    methods(Static)
        function dataTable = getItalianData(URL_str)
            % this function use code from: https://github.com/ECheynet/SEIR/
            if nargin < 1
                URL_str = "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-regioni/dpc-covid19-ita-regioni.csv";
            end
            
            % Set the number of columns
            opts = delimitedTextImportOptions("NumVariables", 21);

            % Specify range and delimiter
            opts.DataLines = [2 Inf];
            opts.Delimiter = ",";

            % Specify column names and types

            opts.VariableNames = ["Date"  , "Contry", "RegionID", "RegionName", "Lat"   , "Long"  , "HospitalizedWithSymptoms", "IntensiveCare", "TotalHospitalized", "HomeConfinement", "PositivesTotal" , "PositivesVariation", "NewPositives", "Recovered", "Deaths" , "Suspects", "ScreeningCases",  "TotalCases" , "TotalTampons", "TestedCases", "Notes"];
            opts.VariableTypes = ["string", "string",    "uint8", "string"    , "double", "double", "double"                  , "double"       , "double"           , "double"         , "double"         , "double"            , "double"        , "double" , "double" , "double"  ,  "double"       , "double"      , "double"       , "double",      "string"];

            % Specify file level properties
            opts.ExtraColumnsRule = "ignore";
            opts.EmptyLineRule = "read";

            % Download the CSV file
            websave('temp.csv', URL_str);

            % Import the data
            fid = fopen('temp.csv');
            dataTable = readtable('temp.csv', opts);
            dataTable.Date = extractBefore(dataTable.Date, "T");
            fclose(fid);
            delete('temp.csv')
        end
        
        function newTable = filtering(dataTable, varargin)
            p = inputParser();

            addParameter(p, 'startDate', datenum('01-Gen-2020'));
            addParameter(p, 'endDate',   datenum('01-Sep-2020'));
            addParameter(p, 'region', 'all');

            parse(p, varargin{:})
            region      = upper(p.Results.region);
            startDate   = p.Results.startDate;
            endDate     = p.Results.endDate;
            
            % group by all region or keep a single region
            if strcmpi(region, 'all') 
                [group, id] = findgroups(dataTable.Date);
                dataTable.group = group;
%                 newTable = dataTable( 
%                 );
                datapointDate                   = id;
                HospitalizedWithSymptoms        = grpstats(dataTable.HospitalizedWithSymptoms,      dataTable.group, @sum);
                IntensiveCare                   = grpstats(dataTable.IntensiveCare,                 dataTable.group, @sum);
                TotalHospitalized               = grpstats(dataTable.TotalHospitalized,             dataTable.group, @sum);
                HomeConfinement                 = grpstats(dataTable.HomeConfinement,               dataTable.group, @sum);
                PositivesTotal                  = grpstats(dataTable.PositivesTotal,                dataTable.group, @sum);
                PositivesVariation              = grpstats(dataTable.PositivesVariation,            dataTable.group, @sum);
                NewPositives                    = grpstats(dataTable.NewPositives,                  dataTable.group, @sum);
                TotalCases                      = grpstats(dataTable.TotalCases,                    dataTable.group, @sum);
                Recovered                       = grpstats(dataTable.Recovered,                     dataTable.group, @sum);
                Deaths                          = grpstats(dataTable.Deaths,                        dataTable.group, @sum);
                TotalTampons                    = grpstats(dataTable.TotalTampons,                  dataTable.group, @sum);
                newTable                            = table(datapointDate,  HospitalizedWithSymptoms,  IntensiveCare,   TotalHospitalized,   HomeConfinement,   PositivesTotal,   PositivesVariation,   NewPositives,   TotalCases,    Recovered,  Deaths,    TotalTampons);
                newTable.Properties.VariableNames   =             {'Date', 'HospitalizedWithSymptoms', 'IntensiveCare', 'TotalHospitalized', 'HomeConfinement', 'PositivesTotal', 'PositivesVariation', 'NewPositives', 'TotalCases', 'Recovered', 'Deaths', 'TotalTampons'};
            elseif sum(contains(upper(dataTable.RegionName), region))>1
                newTable = dataTable(strcmpi(dataTable.RegionName, p.Results.region), :);
            end
            
            % data interval filtering
            filteringIdxs = datenum(newTable.Date)>= datenum(startDate) &  datenum(newTable.Date)<= datenum(endDate);
            newTable = newTable(filteringIdxs, :);
        end
        
        function table = cleanData(table)
            table;
        end
    end
end