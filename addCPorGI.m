function tx_sample = addCPorGI(tmp, Nfft, Nsym, extensionType, CP_ratio, timeDomain)
    
    Ncp = round(Nfft * CP_ratio);
    tx_sample_with_CP = zeros((Nfft + Ncp) * (Nsym + 1), 1); % Preallocate memory

    if timeDomain % For time domain modulation, no need for CP/GI
        tx_sample_with_CP = tmp(:);
    else
        if strcmp(extensionType, 'CP') % CYCLIC PREFIX
            for i = 1:Nsym+1
                s_tx = ifft(tmp(:, i), Nfft) * sqrt(Nfft); % Normalized IFFT
                CP = s_tx(end-Ncp+1:end); % Extract CP from the end of the symbol
                tx_sample_with_CP((i-1)*(Nfft+Ncp)+1:i*(Nfft+Ncp)) = [CP; s_tx]; % Concatenate CP and symbol
            end
        elseif strcmp(extensionType, 'GI') % GUARD INTERVAL (ZERO PADDING)
            for i = 1:Nsym+1
                s_tx = ifft(tmp(:, i), Nfft) * sqrt(Nfft); % Normalized IFFT
                ZP = zeros(Ncp, 1); % Create Zero Padding
                tx_sample_with_CP((i-1)*(Nfft+Ncp)+1:i*(Nfft+Ncp)) = [ZP; s_tx]; % Concatenate ZP and symbol
            end
        else % NEITHER CYCLIC PREFIX NOR GUARD INTERVAL
            for i = 1:Nsym+1
                s_tx = ifft(tmp(:, i), Nfft) * sqrt(Nfft); % Perform IFFT on each OFDM symbol
                tx_sample_with_CP((i-1)*Nfft+1:i*Nfft) = s_tx; % Append the symbol directly, without CP or GI
            end
        end
    end
    
    tx_sample = reshape(tx_sample_with_CP.', 1, []); % Reshape to a row vector for transmission
end