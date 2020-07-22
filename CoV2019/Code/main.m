close all;
clear all; 
clear classes;
import com.DataProvider.*;
import com.Model.*;
import com.Viewer.*;

startDate = datenum('24-Feb-2020');
endDate   = datenum('31-Mar-2020');
region    = 'all';

beta  = 0.78; % infection rate
gamma = 1/5; % mean recovery rate -> suppose to be 5 days
sigma = 1/5; % inverse of incubation time ->
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

E0 = I0 * 5.0;%20.0;  % https://www.medrxiv.org/content/10.1101/2020.01.23.20018549v1.full.pdf
R0 = 0;
%N = dataTable(end, :).TotalTampons;% Italian population of tampons at the last time window available date
%N = 60457165;% Italian population on 2020 19 July 
N = dataTable(end, :).TotalTampons;

% Define the model and the solver, run the solver, get the results
try
    options.Algorithm = 'trust-region-reflective';%'levenberg-marquardt';
    minResnom = +Inf;
    initialParameters = [beta gamma sigma];
    lowerBoundsX = [1e-8, 1e-8, 1e-8];
    %lowerBoundsX = [0.6, 1/6, 1e-8];
    %upperBoundsX = [0.9, 1/4, 1];
    init_cond = [E0, I0, R0, N]; %dataTable(1, :).TotalTampons];
     
    
    a = 1; b = 1;
%     for a = 0:0.1:1
%         for b = 0:0.1:1


            f = @(x) Model_cls.calculateSEIRError(x, init_cond, [0:1:tend], dataTable, [a, b]);
           % parameters = fmincon(f, initialParameters, lowerBoundsX, upperBoundsX, options);
%             [parameters, resnorm] = lsqnonlin(f, initialParameters, lowerBoundsX, upperBoundsX, options);
%              if resnorm < minResnom
%                  finalParameters = parameters;
%                  minResnom = resnorm;
%              end
%         end
%     end

    %ftns = @(x) norm([dataTable.PositivesTotal, dataTable.Recovered]-Model_cls.getIR(x, [0:1:tend], init_cond));
    ftns = @(x) norm([dataTable.PositivesTotal, dataTable.Recovered]-Model_cls.getIR(x, linspace(1, tend), init_cond));
    PopSz = 500;
    Parms = 3;
    opts = optimoptions('ga', 'PopulationSize', PopSz, 'InitialPopulationMatrix', randi(1e4, PopSz, Parms)*1e3, 'MaxGenerations', 2e3, 'PlotFcn', @gaplotbestf, 'PlotInterval', 1);
    tic;
    [parameters,fval,exitflag,output] = ga(ftns, Parms, [], [], [], [], zeros(Parms,1), Inf(Parms,1), [], [], opts);
    toc;

   
    disp('Solved!');    disp('Best combination: '); disp(parameters);   disp(['Elapsed time build and fit the model ' num2str(toc) 's']);
catch Exception
    disp(Exception.identifier);
    disp('Error when executing the model');
end

% computing the model with estimated parameters
try   
    beta  = initialParameters(1);
    gamma = initialParameters(2);
    sigma = initialParameters(3);
    [S, E, I, R] = Model_cls.getSEIR(parameters, linspace(0, tend), init_cond);
%     model_obj = Model_cls(Model_cls.SEIR_MODEL_scl, ...
%                          'N',       N, ...
%                          'beta',    beta, ...
%                          'gamma',   gamma,...
%                          'sigma',   sigma);
          
%     model_obj.simulate_fcn('I0',    I0,  ...
%                            'E0',    E0,  ...
%                            'N',      N,  ...
%                            'R0',     0,  ...
%                            'tend',  datenum("10-Mar-2020")  - startDate);

catch Exception
    disp(Exception.identifier);
    disp('Error when computing the model');
end

% Visulizing the results
try
% all
 Viewer_cls(0, tend, [S, E, I, R], ...
        'names', [ "Supsceptible", "Exposed", "Infected", "Recovered"], ...
        't0', startDate, ...
        'datapoints', [dataTable.PositivesTotal dataTable.Recovered], ...
        'datapointsNames', ["Infected-real data",  "Recovered-real data"], ...
        'title', string(['SEIR plot beta:' num2str(beta) ' gamma:' num2str(gamma) ' sigma:' num2str(sigma)]));

    
 Viewer_cls(model_obj.t, [model_obj.S, model_obj.E, model_obj.I, model_obj.R], ...
        'names', [ "Supsceptible", "Exposed", "Infected", "Recovered"], ...
        't0', startDate, ...
        'datapoints', [dataTable.PositivesTotal dataTable.Recovered], ...
        'datapointsNames', ["Infected-real data",  "Recovered-real data"], ...
        'title', string(['SEIR plot beta:' num2str(beta) ' gamma:' num2str(gamma) ' sigma:' num2str(sigma)]));

% infected
Viewer_cls(model_obj.t, [model_obj.I], ...
        'names', ["Infected prediction"], ...
        't0', startDate, ...
        'datapoints', [dataTable.PositivesTotal], ...
        'datapointsNames', ["Infected-actual data"], ...
        'title', "Infected individuals prediction");
    
% recovered
Viewer_cls(model_obj.t, [model_obj.R], ...
        'names', ["Recovered prediction"], ...
        't0', startDate, ...
        'datapoints', [dataTable.Recovered], ...
        'datapointsNames', ["Recovered-actual data"], ...
        'title', "Recovered individuals prediction");
   
% infected, recovered and Exposed
Viewer_cls(model_obj.t, [model_obj.I, model_obj.R, model_obj.E], ...
        'names', ["Infected prediction", "Recovered prediction", "Exposed prediction", ], ...
        't0', startDate, ...
        'datapoints', [dataTable.PositivesTotal, dataTable.Recovered, ], ...
        'datapointsNames', ["Infected-actual data", "Recovered-actual data"], ...
        'title', "infected, recovered and Exposed");
    
% infected and Exposed
Viewer_cls(model_obj.t, [model_obj.I, model_obj.E], ...
        'names', ["Infected prediction", "Exposed prediction", ], ...
        't0', startDate, ...
        'datapoints', [dataTable.PositivesTotal], ...
        'datapointsNames', ["Infected-actual data"], ...
        'title', "infected and Exposed");
    
catch Exception
    disp(Exception.identifier);
    disp('Error when executing the model');
end



