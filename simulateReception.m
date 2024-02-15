function computedBER = simulateReception(SNR, fadedSig, modulationScheme, extensionType, Nsym, Nfft, CP_ratio, tx_bits, timeDomain)
    % Initialize the computedBER array
    computedBER = zeros(length(SNR), 1);
    
    hChan = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)');

    for n = 1:length(SNR)
        hChan.SNR = SNR(n);
        rx_sample = step(hChan, fadedSig);   % Add Gaussian noise

        if timeDomain
            rx_sym = reshape(rx_sample,Nfft,[]);
            for i=1:Nsym + 1
                rx_sym_after_cp_removal(:,i) = rx_sym(:,i);
            end
        else
            % Array to store symbols after CP/GI removal and FFT
            rx_sym_after_cp_removal = zeros(Nfft, Nsym+1);
            Ncp = round(Nfft * CP_ratio);
            if strcmp(extensionType, 'NONE')
                % Direct FFT without CP/GI removal
                for i = 1:Nsym + 1
                    startIdx = (i-1)*Nfft + 1;
                    endIdx = i*Nfft;
                    rx_sym_direct = rx_sample(startIdx:endIdx);
                    rx_sym_after_cp_removal(:,i) = fft(rx_sym_direct, Nfft) / sqrt(Nfft); 
                end
            else
                % Remove CP/GI and perform FFT
                for i = 1:Nsym+1
                    startIdx = (i-1)*(Nfft+Ncp) + Ncp + 1;
                    endIdx = startIdx + Nfft - 1;
                    rx_sym_without_CP = rx_sample(startIdx:endIdx);
                    rx_sym_after_cp_removal(:,i) = fft(rx_sym_without_CP, Nfft) / sqrt(Nfft); 
                end
            end
        end
        
        rx_bits = [];
        
        %%%%%%%%%% Demodulation process   %%%%%%%%%%
        for i = 1:Nsym
            for j = 1:Nfft
                % Differential demodulation
                sig(j,i) = rx_sym_after_cp_removal(j,i+1) * conj(rx_sym_after_cp_removal(j,i));
                % Decision logic based on modulation scheme
                [d] = demodulateSignal(sig(j,i), modulationScheme);
                rx_bits = [rx_bits d]; % Concatenate received bits
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%    COMPUTE BER    %%%%%%%%%%%%%%%%%%%%%%%%%
        computedBER(n) = sum(rx_bits ~= tx_bits) / length(tx_bits);
    end
end