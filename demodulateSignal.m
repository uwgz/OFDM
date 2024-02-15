function [d] = demodulateSignal(sig, modulationScheme)
    if strcmp(modulationScheme, 'DQPSK')
        dist = abs([1 exp(1i*pi/2) -1 exp(-1i*pi/2)] - sig);
        [~,indx] = min(dist);
        d = indexToBits(indx, 'DQPSK');
    elseif strcmp(modulationScheme, 'D8PSK')
        dist = abs([1 exp(1i*pi/4) exp(1i*pi/2) exp(3i*pi/4) -1 exp(-3i*pi/4) exp(-1i*pi/2) exp(-1i*pi/4)] - sig);
        [~,indx] = min(dist);
        d = indexToBits(indx, 'D8PSK');
    end
end