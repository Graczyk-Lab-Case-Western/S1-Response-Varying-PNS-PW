function plotNormalizedFRAvgExample(predMean, confidInt, time, electrodeSet, elecName, colors, plotSaveDir)
    figure();
    hold on;

    plot(time, predMean, 'Color', colors,'LineWidth',2);
    fHandle = errorPatch(time', confidInt, colors, 0.2);

    xline(0,'--','LineWidth',1,'Color','k'); % Add a line at time 0 to indicate the stimulus presentation
    xline(2,'--','LineWidth',1,'Color','k'); % Add a line at time 2 to indicate the stimulus end
    xlim([-2 4])
    ylim([-10 30])
    box off
    
    xlabel('Time (sec)');
    ylabel('# SD above Mean Baseline Firing Rate')
    set(gca,'Fontsize',14.5)
    set(gca,'Color','w');
    
    titleString = strcat("Normalized Firing Rate on Electrode ",num2str(elecName));
    title(titleString);
    saveFilenamejpg = [plotSaveDir filesep char(titleString) '.jpg'];
    %saveas(gcf,saveFilenamejpg);
end
