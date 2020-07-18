classdef DataProvider_cls < handle
    methods(Static)
        function table = GetItalianData(URL_str)
            % this function use code from: https://github.com/ECheynet/SEIR/
            
            % Set the number of columns
            opts = delimitedTextImportOptions("NumVariables", 16);

            % Specify range and delimiter
            opts.DataLines = dataLines;
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
    end
end