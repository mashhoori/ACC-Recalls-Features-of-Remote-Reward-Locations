function res = MarkConfusion(res, tr)

    uTr = unique(tr);    
    
    for i = 1:numel(uTr)
        resT = [0; res(tr == uTr(i)); 0];
        df = diff(resT); 
        s = find(df == 1);
        e = find(df == -1);               
        cC(i) =  sum(e - s > 10);
    end
%     cC(cC <= 1) = 0;
    cC(cC > 0) = 1;
    res = [uTr(:), cC(:)]';



end