function [tmp, tx_bits] = generateModulatedSymbols(modulationScheme, Nsym, Nfft)
    tmp = ones(Nfft, Nsym + 1);
    tx_bits = [];
    
    if strcmp(modulationScheme, 'DQPSK')
        maxValue = 4;
    elseif strcmp(modulationScheme, 'D8PSK')
        maxValue = 8;
    else
        error('Unsupported modulation scheme');
    end
    
    tx_sym = randi([1, maxValue], Nsym*Nfft, 1);
    tx_sym_array = reshape(tx_sym, Nfft, []);

    for i = 1:Nsym
        for j = 1:Nfft
            d = indexToBits(tx_sym_array(j, i), modulationScheme); 
            tx_bits = [tx_bits d]; % Concatenate transmitted bits

            % phase shift for the symbol
            if strcmp(modulationScheme, 'DQPSK')
                phi = (tx_sym_array(j, i) - 1) * (pi/2);
            elseif strcmp(modulationScheme, 'D8PSK')
                phi = (tx_sym_array(j, i) - 1) * (pi/4);
            end
            
            tmp(j, i + 1) = tmp(j, i) * exp(1i * phi); % Differential modulation
        end
    end
end