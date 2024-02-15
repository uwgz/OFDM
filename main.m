close all;
clear;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nsym = 20;
Nfft = 256;
SNR = 0:2:20; % dB
CP_ratios = [1/4, 1/8, 1/16]; 
modulationSchemes = {'DQPSK', 'D8PSK'};
channelTypes = {'AWGN', 'RAYLEIGH'};
extensions = {'CP', 'GI', 'NONE'}; % CP, GI (Zero Padding)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
noneConsidered = false; % to only consider 'NONE' once
timeDomain = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs = 40.00e6;
pathDelays = [0 30 50 90 130 170]*1e-9;
avgPathGains = [0 -3 -5 -9 -13 -19];
fD = 200;


results = struct([]);

%%%%%%%%%%%%%%%%% CREATE RAYLEIGH FADING CHANNEL OBJECT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rayleighchan = comm.RayleighChannel('SampleRate',fs, ...
                                    'PathDelays',pathDelays, ...
                                    'AveragePathGains',avgPathGains, ...
                                    'MaximumDopplerShift',fD, ...
                                    'Visualization','Off', ... 
                                    'RandomStream','mt19937ar with seed', ... 
                                    'Seed', 2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for modIdx = 1:length(modulationSchemes)
    modulationScheme = modulationSchemes{modIdx};
    
    for chanIdx = 1:length(channelTypes)
        channelType = channelTypes{chanIdx};
        
        for extIdx = 1:length(extensions)
            extensionType = extensions{extIdx}; 

            for cpIdx = 1:length(CP_ratios)

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % RESETTING RAYLEIGH CHANNEL OBJECT AT THE END 
                % OF THE LOOP, I DON'T KNOW WHY IT IS NOT WORKING HERE
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                if strcmp(extensionType, 'NONE')
                    if noneConsidered % DID "NONE" CASE CONDIDERED BEFORE? (IF YES, BREAK, ELSE CONSIDER IT)
                        break
                    else

                        %%% SINCE I KNOW FOR SURE THAT THIS PART OF CODE
                        %%% WILL ONLY RUN ONCE (== in some specific loops).
                        %%% LET ME USE LOOP (RUN IT TWO TIMES) SO AS TO
                        %%% CONSIDER THE CASE OF TIME DOMANIN MODULATION

                        for jk = 1:2
                            if jk == 1
                                timeDomain = true;
                                CP_ratio = 11111; % 11111 <=====> TIME DOMAIN MODULATION
                            else
                                timeDomain = false;
                                CP_ratio = 0; % FOR DIFFERENCIATION PURPOSE, 0 MEANS NO CP/GI WAS USED
                            end
                            [tmp, tx_bits] = generateModulatedSymbols(modulationScheme, Nsym, Nfft);
                            tx_sample = addCPorGI(tmp, Nfft, Nsym, extensionType, CP_ratio, timeDomain);    
        
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            fadedSig = applyChannel(tx_sample, channelType, rayleighchan);
                            computedBER = simulateReception(SNR, fadedSig, modulationScheme, extensionType, Nsym, Nfft, CP_ratio, tx_bits, timeDomain);
    
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STORE THE INFORMATION FO PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            resultIdx = length(results) + 1; 
                            results(resultIdx).modulationScheme = modulationScheme;
                            results(resultIdx).channelType = channelType;
                            results(resultIdx).extensionType = extensionType;
                            results(resultIdx).CP_ratio = CP_ratio;
                            results(resultIdx).BER = computedBER;
                        end
                       noneConsidered = true; % NOT TO REPEAT

                    end
                else
                    timeDomain = false;
                    CP_ratio = CP_ratios(cpIdx);
                    [tmp, tx_bits] = generateModulatedSymbols(modulationScheme, Nsym, Nfft);
                    tx_sample = addCPorGI(tmp, Nfft, Nsym, extensionType, CP_ratio, timeDomain);            
                    fadedSig = applyChannel(tx_sample, channelType, rayleighchan);
                    computedBER = simulateReception(SNR, fadedSig, modulationScheme, extensionType, Nsym, Nfft, CP_ratio, tx_bits, timeDomain);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% STORE THE INFORMATION FO PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    resultIdx = length(results) + 1;
                    results(resultIdx).modulationScheme = modulationScheme;
                    results(resultIdx).channelType = channelType;
                    results(resultIdx).extensionType = extensionType;
                    results(resultIdx).CP_ratio = CP_ratio;
                    results(resultIdx).BER = computedBER;

                end
    
            end
            
            reset(rayleighchan) % Resetting rayleighchan object

        end
        noneConsidered = false;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTS REQUESTED IN HW ASSIGNMENT %%%%%%%%%%%%%%%%%%%%%
%  RAYLEIGH ==> DQPSK   GI =  [1/4 1/8 1/16] + CP = [1/4 1/8 1/16] + NONE
%  RAYLEIGH ==> D8PSK   GI =  [1/4 1/8 1/16] + CP = [1/4 1/8 1/16] + NONE
%      AWGN ==> DQPSK   GI =  [1/4 1/8 1/16] + CP = [1/4 1/8 1/16] + NONE
%      AWGN ==> D8PSK   GI =  [1/4 1/8 1/16] + CP = [1/4 1/8 1/16] + NONE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot_ber_curves(results, 'DQPSK', 'RAYLEIGH', extensions);
plot_ber_curves(results, 'D8PSK', 'RAYLEIGH', extensions);
plot_ber_curves(results, 'DQPSK', 'AWGN', extensions);
plot_ber_curves(results, 'D8PSK', 'AWGN', extensions);