clear all; 
clear classes;
import com.DataProvider.*;
import com.Model.*;

startDate = datenum('01-Gen-2020');
endDate   = datenum('01-Mag-2020');
region    = 'all';
    
try
    tic;
    disp('reading the data from remote repository (need connection)...')
    dataTable = DataProvider_cls.getItalianData();
    dataTable = DataProvider_cls.filtering(dataTable, ...
                'startDate',    startDate, ...
                'endDate',      endDate, ...
                'region',       region);
    disp('data have been correctly readed!')
    
    firstDateTimeRow = dataTable(datetime(dataTable.Date)==min(datetime(dataTable.Date)), :);
    I0 = firstDateTimeRow.TotalCases;
catch Exception
    disp("Errore while getting the data");
    disp(Exception.identifier);
end

try
    %defining a test run
    N = 1;
    beta = 1.0;
    gamma = 197/244; %An approximation given by current statistics (we don't consider future recovered cases as well as exposed or untraced infected)
    sigma = 1/7;
    tend = endDate - startDate; % i want just a value per day

    model_obj = Model_cls(Model_cls.SEIR_MODEL_scl, ...
                         'N',       N, ...
                         'beta',    beta, ...
                         'gamma',   gamma,...
                         'sigma',   1/10);
                     
    model_obj.simulate_fcn('I0',    I0, ...
                           'E0',    0, ...
                           'tend',  tend);
catch Exception
    disp(Exception.identifier);
    disp('Error when executing the model');
end
disp('here');

