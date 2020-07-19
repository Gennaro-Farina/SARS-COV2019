clear all; 
clear classes;
import com.DataProvider.*;
import com.Model.*;
import com.Viewer.*;

startDate = datenum('01-Gen-2020');
endDate   = datenum('01-Sep-2020');
region    = 'all';

N = 10;
beta = 1.0;
gamma = 197/244; %An approximation given by current statistics (we don't consider future recovered cases as well as exposed or untraced infected)
sigma = 1/7;
tend = endDate - startDate; % i want just a value per day
    
% Getting the data, managing it and producing a table
try
    tic;
    disp('reading the data from remote repository (need connection)...')
    dataTable = DataProvider_cls.getItalianData();
    dataTable = DataProvider_cls.filtering(dataTable, ...
                'startDate',    startDate, ...
                'endDate',      endDate, ...
                'region',       region);
    disp('data have been correctly read!')
    
    firstDateTimeRow = dataTable(datetime(dataTable.Date)==min(datetime(dataTable.Date)), :);
    I0 = firstDateTimeRow.TotalCases;
    disp(['Elapsed time for getting and managing data ' num2str(toc) 's']);
catch Exception
    disp("Errore while getting the data");
    disp(Exception.identifier);
end

% Define the model and the solver, run the solver, get the results
try
    tic;
    disp('Model creation...');
    model_obj = Model_cls(Model_cls.SEIR_MODEL_scl, ...
                         'N',       145e3, ...
                         'beta',    4/3, ...
                         'gamma',   1/3,...
                         'sigma',   sigma);
    disp('Model created...');
          
    disp('Solving the simulation...');
    model_obj.simulate_fcn('I0',    1, ...
                           'E0',    3, ...
                           'tend',  tend);
    disp('Solved');
    disp(['Elapsed time build and fit the model ' num2str(toc) 's']);
catch Exception
    disp(Exception.identifier);
    disp('Error when executing the model');
end

% Visulizing the results
try
    Viewer_cls(model_obj.t, [model_obj.S, model_obj.E, model_obj.I, model_obj.R], ...
        'names', ["Supsceptible", "Exposed", "Infected", "Recovered"], ...
        't0', startDate);
catch Exception
    disp(Exception.identifier);
    disp('Error when executing the model');
end



