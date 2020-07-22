classdef Model_cls < matlab.mixin.Copyable
    properties(Constant)
        SEIR_MODEL_scl = 1;
    end
    
    properties(Access = public)
        modelType_scl;
        N;
        beta;
        gamma;
        sigma;
    end
    
    properties (SetAccess = private)
        t;
        S;
        E;
        I;
        R;
        dS;
        dE;
        dI;
        dR;
        d_;
        tend;
    end
    
    methods(Static)
        
        function dydt = ODE_SEIR(~, y, beta, gamma, sigma)
            S = y(1);
            E = y(2);    
            I = y(3);
            R = y(4);
            N = S + E + I + R;
            
            dydt    =  zeros(4,1);
            dydt(1) =  -(beta*S*I)/N ;
            dydt(2) =  (beta*S*I/N) - (sigma*E);    
            dydt(3) =  (sigma*E) - (gamma*I);
            dydt(4) =  gamma * I;
        end
        
        function [y, tout] = ode_solver(tSpan, init_cond, beta, gamma, sigma)
            import com.Model.*;
            
            E0 = init_cond(1);
            I0 = init_cond(2);
            R0 = init_cond(3);
            N0 = init_cond(4);
            
            S0 = N0 - E0 - I0 - R0;
            
            y0 = [S0  E0  I0 0];
            
            opt = odeset('RelTol',1.0e-6,'AbsTol',1.0e-9, 'MaxOrder', 5);
            % non stiff solver               
            [tout, y] = ode45(@(t,y) Model_cls.ODE_SEIR(t, y, beta, gamma, sigma), ...
                        tSpan, y0, opt);
            
        end
        
        function err = calculateSEIRError(params,  init_cond, tSpan, dataTable, hyperparameters)
            import com.Model.*;
            [a, b] = deal(hyperparameters(1), hyperparameters(2));
            
            [beta, gamma, sigma] = deal(params(1), params(2), params(3));
            sol = Model_cls.ode_solver(tSpan, init_cond, beta, gamma, sigma);
            
            S = sol(:,1);
            E = sol(:,2);                    
            I = sol(:,3);
            R = sol(:,4);
            
            s1= (I(1:size(dataTable, 1)) - dataTable.PositivesTotal).^2;
            s1 = s1/max(s1);
            
            s2 = abs(R(1:size(dataTable, 1)) - dataTable.Recovered);
            s2 = s2/max(s2);
            
%             clf;
%             hold on;
%             plot(1:size(dataTable, 1), s1, 'r');
%             plot(1:size(dataTable, 1), s2, 'b');
            err = a*s1 .* (b*s2);% + s2;%/(max(s1)*max(s2));

%             try
%                 A1 = trapz(I(1:size(dataTable, 1)));
%                 A2 = trapz(dataTable.PositivesTotal);
%             catch
%                 disp('here');
%             end            
%             %I admit the prediction to be just a little higher then the actual value
%             err = abs(A1 - A2);
            
            
        end
    end
    
    methods(Access = public)
        function This_obj = Model_cls(modelIdentifier_const, varargin)
            
            if isempty(modelIdentifier_const)
                This_obj.modelType_scl = This_obj.SEIR_MODEL_scl;
            else
                This_obj.modelType_scl = modelIdentifier_const;
            end
            
            p = inputParser();
            switch This_obj.modelType_scl
                case This_obj.SEIR_MODEL_scl                    
                    addParameter(p, 'N', 1);  
                    addParameter(p, 'beta', 0.7);
                    addParameter(p, 'gamma', 1/5);
                    addParameter(p, 'sigma', 1/5);
                    
                    parse(p, varargin{:})
                    
                    validateattributes(p.Results.N,     {'numeric'},  {'positive'},     'scalar');
                    validateattributes(p.Results.beta,  {'numeric'},  {'positive'},     'scalar');
                    validateattributes(p.Results.gamma, {'numeric'},  {'nonnegative'},  'scalar');
                    validateattributes(p.Results.sigma, {'numeric'},  {'nonnegative'},  'scalar');

                    
                    This_obj.N      = p.Results.N;
                    This_obj.beta   = p.Results.beta;
                    This_obj.gamma  = p.Results.gamma;
                    This_obj.sigma  = p.Results.sigma;
            end

        end
        
        function simulate_fcn(This_obj, varargin)
            import com.Model.*;
            p = inputParser();
            
            addParameter(p, 'I0', 1);
            addParameter(p, 'E0', 0);
            addParameter(p, 'R0', 0);
            addParameter(p, 'N0', This_obj.N);
            addParameter(p, 't0', datetime('2020-01-01'));
            addParameter(p, 'tend', datetime('2020-01-09'));

            parse(p, varargin{:})
           
            I0 = p.Results.I0;
            E0 = p.Results.E0;
            R0 = p.Results.R0;
            N0 = p.Results.N0;
            
            switch This_obj.modelType_scl
                case This_obj.SEIR_MODEL_scl
                    
                    y0 = [E0 I0 R0 N0];%;This_obj.N];
                    % non stiff solver
                    [y, tout] = Model_cls.ode_solver([0:1:p.Results.tend], y0, This_obj.beta, This_obj.gamma, This_obj.sigma);
%                     [tout, y] = ode45(@(t,y) Model_cls.ODE_SEIR(t, y, This_obj.beta, This_obj.gamma, This_obj.sigma), ...
%                         0:1:p.Results.tend, y0, opt);
                    % save results
                    This_obj.t = tout;
                    This_obj.S = y(:,1);
                    This_obj.E = y(:,2);                    
                    This_obj.I = y(:,3);
                    This_obj.R = y(:,4);
%                     This_obj.d_= y(:,5);
                    % calculate derivatives
                    dy = zeros(length(tout), 4);
                    for idx = 1:length(tout)
                        dy(idx,:) =  Model_cls.ODE_SEIR(0, y(idx,:), This_obj.beta, This_obj.gamma, This_obj.sigma);
                    end
                    This_obj.dS = dy(:,1);
                    This_obj.dE = dy(:,2);                      
                    This_obj.dI = dy(:,3);                  
                    This_obj.dR = dy(:,4);
                    
                    ReLU = @(x) max(0, x);
                    This_obj.S      = arrayfun(ReLU, This_obj.S);
                    This_obj.E      = arrayfun(ReLU, This_obj.E);
                    This_obj.I      = arrayfun(ReLU, This_obj.I);
                    This_obj.R      = arrayfun(ReLU, This_obj.R);
            end
        end
    end
end