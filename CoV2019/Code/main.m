clear all; 
clear classes;
import com.DataProvider.*;
import com.Model.*;
import com.Viewer.*;

startDate = datenum('24-Feb-2020');
endDate   = datenum('01-Jul-2020');
region    = 'all';

beta = 3/4;
gamma = 1/3;
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
    I0 = firstDateTimeRow.PositivesTotal;
    disp(['Elapsed time for getting and managing data ' num2str(toc) 's']);
catch Exception
    disp("Errore while getting the data");
    disp(Exception.identifier);
end

E0 = I0*2.59; % each person expose 5 persons
N = 60457165;  %dataTable(end, :).TotalTampons; Italian population on 2020 19 July 

% Define the model and the solver, run the solver, get the results
try
%     tic;
%     disp('Model creation...');
%     beta  = linspace(0.001, 1, 50);%[0.001:0.01:1];
%     gamma = linspace(0.001, 1, 50);%[0.001:0.01:1];
%     sigma = linspace(0.001, 1, 50);%[0.001:0.01:1];
%     totalDays = size(dataTable, 1); % data until current date
%      
%     disp('Finding best parameters combination...You may want to have a beer');
%     
%     minSSEValueFound = Inf;
%     bestModel = [];
%     bestCombination = [];
%     TotalIterations = numel(beta)*numel(gamma)*numel(sigma);
%     iteration = 0;
%     
%     for b = beta
%         for g = gamma
%             for s = sigma%[beta;gamma;sigma;E0]
%                 iteration = iteration + 1;
%                 if mod(iteration,  floor(TotalIterations/50))==0 % approximatively 2% advance
%                     disp(['Advacement: ' num2str((iteration/TotalIterations)*100) '%']);
%                 end
%                 sse = 0;
%                 model_obj = Model_cls(Model_cls.SEIR_MODEL_scl, ...
%                                  'N',       N, ...
%                                  'beta',    b, ...
%                                  'gamma',   g,...
%                                  'sigma',   s);
%                 model_obj.simulate_fcn('I0',    I0, ...
%                    'E0',   E0, ...
%                    'tend',  tend);
% 
%                 sse = sum((model_obj.I(1:totalDays) - dataTable(1:totalDays, :).PositivesTotal).^2);
%                 %sse = sse + sum((model_obj.R(1:totalDays) - dataTable(1:totalDays, :).Recovered).^2);
% 
%                 if sse < minSSEValueFound
%                     minSSEValueFound= sse;
%                     bestModel       = copy(model_obj);
%                     bestCombination = [b, g, s];            
%                 end
%             end
%         end
%     end

%     model_obj = Model_cls(Model_cls.SEIR_MODEL_scl, ...
%                          'N',       N, ...
%                          'beta',    4/3, ...
%                          'gamma',   1/3,...
%                          'sigma',   sigma);
%     disp('Model created...');
          
%     disp('Solving the simulation...');
%     model_obj.simulate_fcn('I0',    I0, ...
%                            'E0',    0, ...
%                            'tend',  tend);

    options.Algorithm = 'levenberg-marquardt';
    initialParameters = [beta gamma sigma];
    lowerBoundsX = [1e-8, 1e-8, 1e-8];
    init_cond = [E0, I0, 0, N];    
    f = @(x) Model_cls.calculateSEIRError(x, init_cond, [0:1:tend], dataTable);
    parameters = lsqnonlin(f, initialParameters, lowerBoundsX, [], options);

    disp('Solved!');
    disp('Best combination: ');
    disp(parameters);
    disp(['Elapsed time build and fit the model ' num2str(toc) 's']);
catch Exception
    disp(Exception.identifier);
    disp('Error when executing the model');
end

% computing the model with estimated parameters
try   
    beta  = parameters(1);
    gamma = parameters(2);
    sigma = parameters(3);
    
    model_obj = Model_cls(Model_cls.SEIR_MODEL_scl, ...
                         'N',       N, ...
                         'beta',    beta, ...
                         'gamma',   gamma,...
                         'sigma',   sigma);
    disp('Model created...');
          
    disp('Solving the simulation...');
    model_obj.simulate_fcn('I0',    I0, ...
                           'E0',    E0, ...
                           'tend',  datenum("01-Aug-2020")  - startDate);

%     model_obj = Model_cls(Model_cls.SEIR_MODEL_scl, ...
%                          'N',       N, ...
%                          'beta',    parameters(1), ...
%                          'gamma',   parameters(2),...
%                          'sigma',   parameters(3));
%     disp('Model created...');
%           
%     disp('Solving the simulation...');
%     model_obj.simulate_fcn('I0',    I0, ...
%                            'E0',    E0, ...
%                            'tend',  tend);
catch Exception
    disp(Exception.identifier);
    disp('Error when computing the model');
end

% Visulizing the results
try
%     Viewer_cls(model_obj.t, [model_obj.S, model_obj.E, model_obj.I, model_obj.R], ...
%         'names', ["Supsceptible", "Exposed", "Infected", "Recovered"], ...
%         't0', startDate);

% all
 Viewer_cls(model_obj.t, [model_obj.S, model_obj.E, model_obj.I, model_obj.R], ...
        'names', [ "Supsceptible", "Exposed", "Infected", "Recovered"], ...
        't0', startDate, ...
        'datapoints', [dataTable.PositivesTotal dataTable.Recovered], ...
        'datapointsNames', ["Infected-real data",  "Recovered-real data"]);

% infected
Viewer_cls(model_obj.t, [model_obj.I], ...
        'names', ["Infected prediction"], ...
        't0', startDate, ...
        'datapoints', [dataTable.PositivesTotal], ...
        'datapointsNames', ["Infected-actual data"], ...
        'title', 'Infected individuals prediction');
    
% recovered
Viewer_cls(model_obj.t, [model_obj.R], ...
        'names', ["Recovered prediction"], ...
        't0', startDate, ...
        'datapoints', [dataTable.Recovered], ...
        'datapointsNames', ["Recovered-actual data"], ...
        'title', 'Recovered individuals prediction');
   
% infected, recovered and Exposed
Viewer_cls(model_obj.t, [model_obj.I, model_obj.R, model_obj.E], ...
        'names', ["Infected prediction", "Recovered prediction", "Exposed prediction", ], ...
        't0', startDate, ...
        'datapoints', [dataTable.PositivesTotal, dataTable.Recovered, ], ...
        'datapointsNames', ["Infected-actual data", "Recovered-actual data"], ...
        'title', 'infected, recovered and Exposed');
    
% infected and Exposed
Viewer_cls(model_obj.t, [model_obj.I, model_obj.E], ...
        'names', ["Infected prediction", "Exposed prediction", ], ...
        't0', startDate, ...
        'datapoints', [dataTable.PositivesTotal], ...
        'datapointsNames', ["Infected-actual data"], ...
        'title', 'infected, recovered and Exposed');
    
catch Exception
    disp(Exception.identifier);
    disp('Error when executing the model');
end



