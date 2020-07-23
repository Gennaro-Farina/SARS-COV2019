classdef Viewer_cls < handle
    methods(Access = public)
        function This_obj = Viewer_cls(independentVariableArray, dependentVariables, varargin)
            legendNames = [];
            p = inputParser();

            addParameter(p, 'names', []);
            addParameter(p, 't0',   datenum('01-Gen-2020'));
            addParameter(p, 'datapoints', []);
            addParameter(p, 'datapointsNames', []);
            addParameter(p, 'tend', datenum('01-Gen-2020'));
            addParameter(p, 'title', []);
            
            parse(p, varargin{:})

            datapoints = p.Results.datapoints;
            datapointsNames = p.Results.datapointsNames;
            title_str = p.Results.title;
            tend = p.Results.tend;
            % dependentVariables is a matrix whose column are dependent variables
            figure();
            hold on;
            for dv = 1:size(dependentVariables, 2)
                plot(independentVariableArray, dependentVariables(:, dv));
            end
            
            if not(isempty(p.Results.names))
                legendNames = [legendNames, p.Results.names'];
            end
            
            % plotting real data
            for dpi = 1:size(datapoints, 2)
                plot([0:1:tend], datapoints(:, dpi), 'o');
            end
            
            if not(isempty(datapointsNames))
                legendNames = [legendNames; datapointsNames(:)];
            end
            
            if not(isempty(datapointsNames))
                legendNames = [legendNames; datapointsNames(:)];
            end
            
            legend(legendNames);
            
            if not(isempty(title_str))
                title({title_str; ' '});
            end
            
            % putting date reference in the upper zone
            xlabel('Days from t_0');
            ylabel('Individuals');            
            ax1 = gca;
            ax1_pos = ax1.Position; 
            ax2 = axes('Position', ax1_pos,...
            'XAxisLocation','top',...
            'YAxisLocation','right',...
            'Color','none');% 
%             y2 = 2*max(dependentVariables(:));
%             line([independentVariableArray(9), independentVariableArray(end)], [y2 y2]);
            xlim([p.Results.t0, p.Results.t0+numel(independentVariableArray)]);
%             xtickformat('dd-MMM-yyyy')
            datetick(ax2)
            set(gca,'ytick',[])
            
           
        end
    end
end