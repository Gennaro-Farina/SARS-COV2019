classdef Model_cls < handle
    properties(Constant)
        SEIR_MODEL_scl = 1;
    end
    
    properties(Access = public)
        modelType_scl;
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
    end
    
    methods(Access = public)
        function This_obj = Model_cls(model_constant)
            % this function use code from: https://github.com/ECheynet/SEIR/
            if nargin < 1
                This_obj.modelType_scl = This_obj.SEIR_MODEL_scl;
            else
                This_obj.modelType_scl = model_constant;
            end
        end
        
        function dydt = solve_fcn(This_obj, varargin)
            switch This_obj.modelType_scl
                case This_obj.SEIR_MODEL_scl
                    dydt = This_obj.OrdinaryDifferentialEquation_SEIR(y, N, beta, gamma, sigma);
            end
        end
        
        function dydt = OrdinaryDifferentialEquation_SEIR(~, y, N, beta, gamma, sigma)
            S = y(1);
            E = y(2);    
            I = y(3);
            R = y(4);
            
            dydt    = zeros(4,1);
            dydt(1) = -beta*S*I/N ;
            dydt(2) =  beta*S*I/N - sigma*E;    
            dydt(3) =  sigma*E - gamma*I;
            dydt(4) =  gamma* I;
        end
    end
end