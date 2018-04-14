function [N] = applyProcrustes(data)

nSession = max(data.session);
sessVector = num2cell(2:nSession);

N = cellfun(@applyProcrustesSingleSession, ...
            repmat({data}, length(sessVector), 1), sessVector', ...
            'UniformOutput', 0);

    function [N] = applyProcrustesSingleSession(data, iS)
      
        indSession1 = data.session == 1;
        indSession2 = data.session == iS;
        [X2, Y2, Z2] = selectRows(data, indSession2);
        commonIDs = intersect(data.correlationID(indSession1), ...
                              data.correlationID(indSession2));
        idInd = ismember(data.correlationID, commonIDs);
        
        [sX1, sY1, sZ1] = selectRows(data, indSession1 & idInd);
        [sX2, sY2, sZ2] = selectRows(data, indSession2 & idInd);
        [~, ~, C] = procrustes([sX1, sY1, sZ1], [sX2, sY2, sZ2]);
        N = C.b * [X2, Y2, Z2] * C.T + C.c(1,:);
        
    end

end
