classdef DataProvider_cls < handle
    methods(Static)
        function table = getItalianData(URL_str)
            % this function use code from: https://github.com/ECheynet/SEIR/
            if nargin < 1
                URL_str = "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-regioni/dpc-covid19-ita-regioni.csv";
            end
            
            % Set the number of columns
            opts = delimitedTextImportOptions("NumVariables", 16);

            % Specify range and delimiter
            opts.DataLines = [2 Inf];
            opts.Delimiter = ",";

            % Specify column names and types

            %  opts.VariableNames = ["HospitalizedWithSymptoms", "HospitalizedInIntensiveCare", "Hospitalized",  	"HomeConfinement", 	"confirmed" ,	"activeCases", 	"newCases", "Recovered", 	"Deaths" ,	"totalCases"]
            opts.VariableNames = ["Date"    , "CountryCode", "RegionCode", "RegionName", "Lat"   , "Long"  , "HospitalizedWithSymptoms", "HospitalizedInIntensiveCare", "Hospitalized", "HomeConfinement", "Quarantined", "variationQuarantined", "NewQuarantined","Recovered", "Deaths", "Confirmed" , "Swabs" ];
            opts.VariableTypes = ["string", "string"     , "uint8"     , "string"    , "double", "double", "double"                  , "double"                     , "double"      , "double"         , "double"     , "double"        , "double"        , "double"   , "double", "double"    , "double"];

            % Specify file level properties
            opts.ExtraColumnsRule = "ignore";
            opts.EmptyLineRule = "read";

            % Download the CSV file
            websave('temp.csv', URL_str);

            % Import the data
            fid = fopen('temp.csv');
            table = readtable('temp.csv', opts);
            fclose(fid);
            delete('temp.csv')
        end
        
        function table = cleanData(table)
            table;
        end
    end
end