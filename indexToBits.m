function [d] = indexToBits(indx, scheme)
    if strcmp(scheme, 'DQPSK')
        switch indx
            case 1, d = [0 0];
            case 2, d = [0 1];
            case 3, d = [1 1];
            case 4, d = [1 0];
        end
    elseif strcmp(scheme, 'D8PSK')
        switch indx
            case 1, d = [0 0 0];
            case 2, d = [0 0 1];
            case 3, d = [0 1 0];
            case 4, d = [0 1 1];
            case 5, d = [1 0 0];
            case 6, d = [1 0 1];
            case 7, d = [1 1 0];
            case 8, d = [1 1 1];
        end
    end
end