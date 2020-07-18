clear all; 
clear classes;
import com.DataProvider.*;
import com.Model.*;

try
    tic;
    disp('reading the data...')
    dataTable = DataProvider_cls.getItalianData();
    dataTable = DataProvider_cls.cleanData(dataTable);
    disp('data have been correctly readed!')
catch Exception
    disp("Errore while getting the data");
    disp(Exception.identifier);
end

try
    model_obj = Model_cls(Model_cls.SEIR_MODEL_scl);
    
    y0 = [obj.N - obj.I0 - obj.E0 obj.E0 obj.I0 0 obj.I0];
    [tout,y] = ode45(@(t,y) odeSEIR(t,y,obj.N,obj.beta,obj.gamma,obj.sigma), tspan, y0);
    % save results
    obj.t = tout;
    obj.S = y(:,1);
    obj.E = y(:,2);                    
    obj.I = y(:,3);
    obj.R = y(:,4);
    obj.C = y(:,5);
    % calculate derivatives
    dy = zeros(length(tout),5);
    for n = 1:length(tout)
        dy(n,:) = odeSEIR(0,y(n,:),obj.N,obj.beta,obj.gamma,obj.sigma);
    end
    obj.dS = dy(:,1);
    obj.dE = dy(:,2);                      
    obj.dI = dy(:,3);                  
    obj.dR = dy(:,4);
    obj.dC = dy(:,5);    
catch Exception
    disp(Exception.identifier);
    disp('Error when executing the model');
end
disp('here');

