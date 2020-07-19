classdef Model_cls < handle
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
        dC;        
        tend;
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
                    addParameter(p, 'beta', 9/10);
                    addParameter(p, 'gamma', 197/244);
                    addParameter(p, 'sigma', 1/10);
                    
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
        
        function dydt = simulate_fcn(This_obj, varargin)
            p = inputParser();
            
            addParameter(p, 'I0', 1);
            addParameter(p, 'E0', 0);
            addParameter(p, 't0', datetime('2020-01-01'));
            addParameter(p, 'tend', datetime('2020-01-09'));

            parse(p, varargin{:})
           
            I0 = p.Results.I0;
            E0 = p.Results.E0;
            
            tend    = p.Results.tend;

            switch This_obj.modelType_scl
                case This_obj.SEIR_MODEL_scl
                    
                    y0 = [ This_obj.N-I0-E0  E0  I0 0  I0];
                    [tout,y] = ode45(@(t,y) odeSEIR(t,y, This_obj.N, This_obj.beta, This_obj.gamma, This_obj.sigma), ...
                        tspan, y0);
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
                    
                    dydt = This_obj.OrdinaryDifferentialEquation_SEIR(y, This_obj.N, This_obj.beta, This_obj.gamma, This_obj.sigma);
                    y0 = [This_obj.N - This_obj.I0 - This_obj.E0 This_obj.E0 This_obj.I0 0 This_obj.I0];                    
            end
        end
        
        function dydt = OrdinaryDifferentialEquation_SEIR(~, y, N, beta, gamma, sigma)
            S = y(1);
            E = y(2);    
            I = y(3);
            % R is not used in the ODE system
            
            dydt    = zeros(4,1);
            dydt(1) = -(beta*S*I)/N ;
            dydt(2) =  (beta*S*I/N) - (sigma*E);    
            dydt(3) =  (sigma*E) - (gamma*I);
            dydt(4) =  gamma * I;
        end
    end
end