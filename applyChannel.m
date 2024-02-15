function fadedSig = applyChannel(tx_sample, channelType, rayleighchan)
    
    if strcmp(channelType, 'AWGN')
        % For AWGN, the signal remains unchanged
        fadedSig = tx_sample;
    elseif strcmp(channelType, 'RAYLEIGH')
        % For Rayleigh fading, apply the Rayleigh channel effect
        fadedSig = step(rayleighchan, tx_sample(:));
    else
        error('Unsupported channel type. Please choose ''AWGN'' or ''RAYLEIGH''.');
    end
end