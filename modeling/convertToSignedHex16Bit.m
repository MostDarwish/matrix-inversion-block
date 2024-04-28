function signedHex = convertToSignedHex16Bit(integerVector)
    signedHex = cell(size(integerVector));
    
    for i = 1:length(integerVector)
        decimalNumber = integerVector(i);
        
        % Limit the number to a 16-bit signed range
        decimalNumber = max(-32768, min(32767, decimalNumber));
        
        % Convert negative numbers to two's complement representation
        if decimalNumber < 0
            numBits = 16; % 16-bit representation
            binaryRepresentation = dec2bin(abs(decimalNumber), numBits);
            invertedBinary = ~logical(binaryRepresentation - '0');
            twosComplementBinary = addBinaryArrays(invertedBinary, logical([zeros(1, numBits - 1), 1]));
            hexString = binaryToHex(twosComplementBinary);
        else
            hexString = dec2hex(decimalNumber, 4); % 4 characters (16 bits)
        end
        
        signedHex{i} = hexString;
    end
end

function result = addBinaryArrays(a, b)
    carry = 0;
    result = zeros(1, length(a));
    for i = length(a):-1:1
        sum = a(i) + b(i) + carry;
        result(i) = mod(sum, 2);
        carry = sum >= 2;
    end
end

function hexString = binaryToHex(binaryArray)
    binaryArray = reshape(binaryArray, 4, []);
    hexString = '';
    for i = 1:size(binaryArray, 2)
        nibble = binaryArray(:, i)';
        hexDigit = sum(nibble .* [8, 4, 2, 1]);
        hexString = [hexString, dec2hex(hexDigit)];
    end
end