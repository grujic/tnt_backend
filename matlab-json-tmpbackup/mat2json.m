function mat2json(matoutpath,jsoninpath,jsonoutpath,imageoutputpath,calculation_id)

if (~isdeployed)
    addpath([pwd,'/jsonlab']);
end

% Load initial json structure
loadname = [jsoninpath '/' calculation_id '.json'];
pms = loadjson(loadname);
% Load the expectation value terms
exops = pms.calculation.setup.expectation_values.operators;
% Load which calculations have been carried out
dotebd = pms.calculation.setup.system.calculate_time_evolution;
dodmrg = pms.calculation.setup.system.calculate_ground_state;

% Load system size
L = pms.calculation.setup.system.system_size;

% Load results of calculations
loadname = [matoutpath '/' calculation_id '.mat'];
load(loadname);

% Formats for graph plotting
marker_colour = 'r';
line_style = '--ro';
axesfontsize = 14;

if (dodmrg)
    % Load energy per iteration
    data.groundstate.energy.iterations = length(E)-1;
    data.groundstate.energy.vals = E;
    
    fname = [imageoutputpath '/' calculation_id '_energy_gs.png'];
    
    figure('Visible','off');
    semilogy(abs(E-E(end)),'--ro','MarkerFaceColor','k');
    set(gca,'XTick',1:length(E));
    set(gca,'XTickLabel',0:(length(E)-1));
    set(gca,'FontSize',axesfontsize);
    xlabel('Iteration');
    ylabel('E - E_{gs}');
    title(['Convergence to energy density ',num2str(E(end)/L,'%12.12f')]);
    print('-dpng',fname);
    
    for loop=1:length(exops)
        
        data.groundstate.operators{loop}.operator_id = exops{loop}.operator_id;
        newlb = strrep(exops{loop}.function_description,' ','_');
        
        if (exist(newlb,'var'))
            eval(['datasetall = ' newlb ';']);

            data.groundstate.operators{loop}.two_site = exops{loop}.two_site;
            data.groundstate.operators{loop}.vals.re = real(datasetall);
            data.groundstate.operators{loop}.vals.im = imag(datasetall);
            if (exops{loop}.two_site)
                data.groundstate.operators{loop}.exp_val_type = exops{loop}.exp_val_type;
            end
            data.groundstate.operators{loop}.function_description = exops{loop}.function_description;
            errstr='';
        else
            datasetall = zeros(1,L);
            errstr='\newline !!Early exit due to error in calculation!!';
        end
        fname = [imageoutputpath '/' calculation_id '_' num2str(exops{loop}.operator_id) '_gs.png'];
        figure('Visible','off');
        plot(datasetall);
        set(gca,'XTick',1:4:length(datasetall))
        set(gca,'FontSize',axesfontsize);
        xlabel('Site number');
        ylabel(exops{loop}.function_description);
        title(['Ground state expectation of ' exops{loop}.function_description errstr]);
        print('-dpng',fname);
        
    end
end

if (dotebd)

    % if this variable doesn't exist it means the program ended early
    if (~exist('extimes','var'))
        bigstep=20; % default bigstep
        dt=pms.calculation.setup.system.time_step;
        % Find the final available output file 
        newlb = strrep(exops{1}.function_description,' ','_');
        numit = 1;
            while (exist([newlb '_' num2str(numit)],'var'))
                numit = numit+1;
            end
            numit = numit-2; 
        extimes = (0:numit)*bigstep*dt;
        errstr = '\newline !!Early exit due to error in calculation!!';
    else
        fname = [imageoutputpath '/' calculation_id '_0_evolved.png'];

        figure('Visible','off');
        semilogy(extimes,truncerrs,'--ro','MarkerFaceColor','k');
        set(gca,'FontSize',axesfontsize);
        xlabel('Time');
        ylabel('Truncation error');
        title('Truncation error (sum of squares of all discarded singular values) as a function of time');
        print('-dpng',fname);
        
        errstr = '';
    end

    for loop=1:length(exops)

        data.evolved.operators{loop}.operator_id = exops{loop}.operator_id;
        data.evolved.operators{loop}.two_site = exops{loop}.two_site;
        if (exops{loop}.two_site)
            data.evolved.operators{loop}.exp_val_type = exops{loop}.exp_val_type;
        end
        data.evolved.operators{loop}.function_description = exops{loop}.function_description;
        newlb = strrep(exops{loop}.function_description,' ','_');
        
        eval(['numcols = size(' newlb '_1,1)*size(' newlb '_1,2);']); 
        datasetall = zeros(length(extimes),numcols);
        
        for loopt=1:length(extimes) 
            strloop = num2str(loopt);
            tval.time_step = loopt;
            tval.time = extimes(loopt);
            eval(['datasetstep = ' newlb '_' strloop ';']);
            tval.re = real(datasetstep);
            tval.im = imag(datasetstep);

            data.evolved.operators{loop}.vals{loopt} = tval;
            datasetall(loopt,:) = datasetstep(:);
        end
        
        fname = [imageoutputpath '/' calculation_id '_' num2str(exops{loop}.operator_id) '_evolved.png'];

        figure('Visible','off');
        h = pcolor(1:numcols,extimes,datasetall);
        set(gca,'FontSize',axesfontsize);
        xlabel('Site number');
        ylabel('Time');
        title(['Expectation of ' exops{loop}.function_description ' as a function of time' errstr]);
        axis square;
        colorbar;
        set(h,'EdgeColor','none');
        print('-dpng',fname);
        
        
    end
end

savename = [jsonoutpath '/' calculation_id '.json'];
savejson('data',data,savename);

end