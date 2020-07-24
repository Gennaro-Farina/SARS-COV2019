close all;
clear all; 
clear classes;
import com.DataProvider.*;
import com.Model.*;
import com.Viewer.*;

startDate           = datenum('24-Feb-2020');
endDate             = datenum('09-Mar-2020');% should be today
predictionEndDate   = datenum('01-Sep-2020');


region    = 'all';

% initial approximation
beta  = 0.78; % infection rate
gamma = 1/5; % mean recovery rate -> suppose to be 5 days
sigma = 1/5; % inverse of incubation time ->

tEnd = endDate - startDate; % i want just a value per day
tEndPrediction = predictionEndDate - startDate;


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
    tt = dataTable(end, :).TotalTampons;
    disp(['Elapsed time for getting and managing data ' num2str(toc) 's']);
catch Exception
    disp("Errore while getting the data");
    disp(Exception.identifier);
    
    disp("Check your connection please");
end

E0 = I0 * 20.0;  % https://www.medrxiv.org/content/10.1101/2020.01.23.20018549v1.full.pdf
R0 = 0;
N = 60456197; %tt;  italy population on 23 july

init_cond = [E0, I0, R0, N]; %dataTable(1, :).TotalTampons];
initialParameters = [beta gamma sigma];

lowerBoundsX = [0.6, 1/6, 1/8];
upperBoundsX = [0.9, 1/4, 1];


% Define the model and the solver, run the solver, get the results
try
    options.Algorithm = 'trust-region-reflective';%'levenberg-marquardt';
    minResnom = +Inf;
     

    % DEPRECATED: Alternative method to find a good paramters combination
%     a = 1; b = 1;
% %     for a = 0:0.1:1
% %         for b = 0:0.1:1
% 
% 
%             f = @(x) Model_cls.calculateSEIRError(x, init_cond, [0:1:tend], dataTable, [a, b]);
%            % parameters = fmincon(f, initialParameters, lowerBoundsX, upperBoundsX, options);
% %             [parameters, resnorm] = lsqnonlin(f, initialParameters, lowerBoundsX, upperBoundsX, options);
% %              if resnorm < minResnom
% %                  finalParameters = parameters;
% %                  minResnom = resnorm;
% %              end
% %         end
% %     end

    %ftns = @(x) norm([dataTable.PositivesTotal, dataTable.Recovered]-Model_cls.getIR(x, [0:1:tend], init_cond));
%     ftns = @(x) norm([dataTable.PositivesTotal, dataTable.Recovered]- Model_cls.getIR(x, [0:tend], init_cond));
    ftns = @(x) norm([dataTable.PositivesTotal]- Model_cls.getI(x, [0:tEnd], init_cond));
    populationSize = 3e2;
    paramsNumber = 3;
    
    % matlab genetic algoritm for finding a good combination of parameters
    opts = optimoptions('ga', 'PopulationSize',populationSize, 'InitialPopulationMatrix',randi(1E+4,populationSize,paramsNumber)*1E-3, 'MaxGenerations',1E3, 'PlotFcn',@gaplotbestf, 'PlotInterval',1);
    tic;
    %[parameters,fval,exitflag,output] = ga(ftns, Parms, [], [], [], [], zeros(Parms,1), Inf(Parms,1), [], [], opts);
    [parameters,fval,exitflag,output] = ga(ftns, paramsNumber, [], [], [], [], lowerBoundsX,  upperBoundsX, [], [], opts);
    toc;

    disp('Solved!');    disp('Best combination: '); 
    disp(parameters);   
catch Exception
    disp(Exception.identifier);
    disp('Error when executing the model');
end

% computing the model with estimated parameters
try   
	[S,   E,  I,  R] = Model_cls.getSEIR(parameters, [0:tEnd], init_cond);
    [Sp, Ep, Ip, Rp] = Model_cls.getSEIR(parameters, [0:tEndPrediction], init_cond);
catch Exception
    disp(Exception.identifier);
    disp('Error when computing the model');
end

% Visulizing the results
try
    t = [0: tEnd];
%     % all
%     Viewer_cls(t, [S, E, I, R], ...
%         'names', [ "Supsceptible", "Exposed", "Infected", "Recovered"], ...
%         't0', startDate, ...
%         'tend', tEnd, ...
%         'datapoints', [dataTable.PositivesTotal], ...
%         'datapointsNames', ["Infected-real data"], ...
%         'title', string(['SEIR plot beta:' num2str(beta) ' gamma:' num2str(gamma) ' sigma:' num2str(sigma)]));

    % infected
    Viewer_cls(t, [I], ...
        'names', ["Infected prediction"], ...
        't0', startDate, ...
        'tend', tEnd, ...
        'datapoints', [dataTable.PositivesTotal], ...
        'datapointsNames', ["Infected-actual data"], ...
        'title', "Infected individuals");

%     
%     % infected and Exposed
%     Viewer_cls(t, [I, E], ...
%         'names', ["Infected prediction", "Exposed prediction", ], ...
%         't0', startDate, ...
%         'tend', tEnd, ...
%         'datapoints', [dataTable.PositivesTotal], ...
%         'datapointsNames', ["Infected-actual data"], ...
%         'title', "infected and Exposed");
%     
    
    % PREDICTIONS =======================================================
    t = [0: tEndPrediction];
    Viewer_cls(t, [Sp, Ep, Ip, Rp], ...
        'names', [ "Supsceptible", "Exposed", "Infected", "Recovered"], ...
        't0', startDate, ...
        'tend', tEnd, ...
        'title', string(['Predictions: SEIR plot beta:' num2str(beta) ' gamma:' num2str(gamma) ' sigma:' num2str(sigma)]));

    % infected
    Viewer_cls(t, [Ip], ...
        'names', ["Infected prediction"], ...
        't0', startDate, ...
        'tend', tEnd, ...
        'title', "Predictions: Infected individuals");

    
    % infected and Exposed
    Viewer_cls(t, [Ip, Ep], ...
        'names', ["Infected prediction", "Exposed prediction", ], ...
        't0', startDate, ...
        'tend', tEnd, ...
        'title', "Predictions: infected and Exposed");
    
catch Exception
    disp(Exception.identifier);
    disp('Error when executing the model');
end


% Social distancing =======================================================
try
% Keep fixed is just a trial
parameters = [0.8543    0.2500    0.1250]; % parameters obtained through minimization (report eample)
rho = [1, 0.8, 0.5];

t = [0: tEndPrediction];
for r = 1:numel(rho)
    curRho = rho(r);
    
    [Sp, Ep, Ip, Rp] = Model_cls.getSEIRrho([parameters, curRho], t, init_cond);
    % all with social distancing
    Viewer_cls(t, [Sp, Ep, Ip, Rp], ...
        'names', [ "Supsceptible", "Exposed", "Infected", "Recovered"], ...
        't0', startDate, ...
        'tend', tEnd, ...
        'title', string(['Predictions: SEIR rho:' num2str(curRho) ' beta:' num2str(beta) ' gamma:' num2str(gamma) ' sigma:' num2str(sigma)]));

    % infected
    Viewer_cls(t, [Ip], ...
        'names', ["Infected prediction"], ...
        't0', startDate, ...
        'tend', tEnd, ...
        'title', string(['Predictions: rho:' num2str(curRho) 'Infected individuals']));

    
    % infected and Exposed
    Viewer_cls(t, [Ip, Ep], ...
        'names', ["Infected prediction", "Exposed prediction", ], ...
        't0', startDate, ...
        'tend', tEnd, ...
        'title', string(['Predictions: rho:' num2str(curRho) ' infected and Exposed']));
end
catch Exception
    disp(Exception.identifier);
    disp('Error on the model when simulating social distancing');
end
