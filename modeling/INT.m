function integer_value = INT(number,data_type)
    switch data_type
        case 8
            integer_value = int8(number);
        case 16
            integer_value = int16(number);
        case 32
            integer_value = int32(number);
        case 64
            integer_value = int64(number);
        otherwise
            error('Unsupported data type.');
    end
end