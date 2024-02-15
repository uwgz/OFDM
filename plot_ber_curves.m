function plot_ber_curves(results, targetModulationScheme, targetChannelType, extensions)
    CP_GI_ratio_else = [1/4, 1/8, 1/16]; % CP/GI ratios
    CP_GI_ratio_none = [0, 11111]; % 11111 MEANS "TIME DOMAIN MODULATION, IT WAS NEVER USED
    SNR = 0:2:20; % SNR range
    
    % Define a list of colors for plotting
    colors = [0, 0, 1; 1, 0, 0; 0, 1, 0; 0, 1, 1; 1, 0, 1; 1, 1, 0; 0, 0, 0; 1, 0.5, 0];
    %%%%%%%%% Red - [1, 0, 0], Green - [0, 1, 0], Cyan - [0, 1, 1], Magenta
    %%%%%%%%% - [1, 0, 1], Yellow - [1, 1, 0], Black - [0, 0, 0], Orange - [1, 0.5, 0]

    figure;
    colorIdx = 1; % Initialize color index
    
    for extIdx = 1:length(extensions)
        targetExtensionType = extensions{extIdx}; 
        if strcmp(targetExtensionType, 'NONE')
            CP_GI_ratios = CP_GI_ratio_none;
        else
            CP_GI_ratios = CP_GI_ratio_else;
        end

        for ratioIdx = 1:length(CP_GI_ratios)
            targetCP_ratio = CP_GI_ratios(ratioIdx);
            
            filteredIdx = strcmp({results.modulationScheme}, targetModulationScheme) & ...
                          strcmp({results.channelType}, targetChannelType) & ...
                          strcmp({results.extensionType}, targetExtensionType) & ...
                          [results.CP_ratio] == targetCP_ratio;

            % Extracting BER values for the filtered results
            filteredBER = [results(filteredIdx).BER];

            if targetCP_ratio == 11111 
                label = sprintf('%s', "TIME DOMAIN MODULATION");
            else
               label = sprintf('%s %g', targetExtensionType, targetCP_ratio); 
            end
            
            % Ensure color index wraps around if more than 8 lines are plotted
            currentColor = colors(mod(colorIdx-1, size(colors, 1)) + 1, :);
            
            semilogy(SNR, filteredBER, 'DisplayName', label, 'Color', currentColor); 
            hold on;
            
            colorIdx = colorIdx + 1; % Increment color index for the next line
        end
    end
    
    title(sprintf('BER vs SNR for %s in %s channel', targetModulationScheme, targetChannelType));
    axis([min(SNR) max(SNR) 10^-3 1]);
    xlabel('SNR (dB)');
    ylabel('BER');
    legend('show', 'Location', 'best');
    grid on;
    hold off;
end