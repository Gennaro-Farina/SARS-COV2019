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
        d_;
        tend;
    end
    
    methods(Static)
        function dydt = OrdinaryDifferentialEquation_SEIR(~, y, N, beta, gamma, sigma)
            S = y(1);
            E = y(2);    
            I = y(3);
            % R is not used in the ODE system
            
            dydt    = zeros(5,1);
            dydt(1) = -(beta*S*I)/N ;
            dydt(2) =  (beta*S*I/N) - (sigma*E);    
            dydt(3) =  (sigma*E) - (gamma*I);
            dydt(4) =  gamma * I;
            dydt(5) =  sigma*E;
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
        
        function simulate_fcn(This_obj, varargin)
            import com.Model.*;
            p = inputParser();
            
            addParameter(p, 'I0', 1);
            addParameter(p, 'E0', 0);
            addParameter(p, 't0', datetime('2020-01-01'));
            addParameter(p, 'tend', datetime('2020-01-09'));

            parse(p, varargin{:})
           
            I0 = p.Results.I0;
            E0 = p.Results.E0;
            
            switch This_obj.modelType_scl
                case This_obj.SEIR_MODEL_scl
                    
                    y0 = [This_obj.N-I0-E0  E0  I0 0 I0];
                    [tout, y] = ode45(@(t,y) Model_cls.OrdinaryDifferentialEquation_SEIR(t,y, This_obj.N, This_obj.beta, This_obj.gamma, This_obj.sigma), ...
                        0:1:p.Results.tend, y0);
                    % save results
                    This_obj.t = tout;
                    This_obj.S = y(:,1);
                    This_obj.E = y(:,2);                    
                    This_obj.I = y(:,3);
                    This_obj.R = y(:,4);
                    This_obj.d_= y(:,5);
                    % calculate derivatives
                    dy = zeros(length(tout), 5);
                    for idx = 1:length(tout)
                        dy(idx,:) =  Model_cls.OrdinaryDifferentialEquation_SEIR(0, y(idx,:), This_obj.N, This_obj.beta, This_obj.gamma, This_obj.sigma);
                    end
                    This_obj.dS = dy(:,1);
                    This_obj.dE = dy(:,2);                      
                    This_obj.dI = dy(:,3);                  
                    This_obj.dR = dy(:,4);
                    This_obj.d_ = dy(:,5);
                    
                    ReLU = @(x) max(0, x);
                    This_obj.S      = arrayfun(ReLU, This_obj.S);
                    This_obj.E      = arrayfun(ReLU, This_obj.E);
                    This_obj.I      = arrayfun(ReLU, This_obj.I);
                    This_obj.R      = arrayfun(ReLU, This_obj.R);
                    This_obj.d_     = arrayfun(ReLU, This_obj.d_);
            end
        end
    end
end