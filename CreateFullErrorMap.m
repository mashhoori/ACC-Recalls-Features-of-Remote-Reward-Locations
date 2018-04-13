
function CreateFullErrorMap
    
a = load('.\Errors\err16New');
a = a.A;


[data, ~] = CreateAllData('E:\New folder\P1353_16p\', [], 'vtm1.pvd');
choice = [data.trInfo.choice];










realLocation = [a.real_v];
predLocation = [a.pred_v];
trials = [a.trial_v];


realChoice = choice(trials);


[codeR, ~] = CoarseGrid(realLocation, 2);
codeR = ConvertCode(codeR);


% setdiff(1:18, [1 7]) 1 7
for i = [2:18 1]
    
    selectedIndices = codeR == i & realChoice == 1;

    subplot(1,2,1)    
    
    if (i == 1)
        plot(realLocation(1, selectedIndices), realLocation(2, selectedIndices), '.', 'color' , [0.7 0.7 0.7])
    elseif (i == 7)        
        plot(realLocation(1, selectedIndices), realLocation(2, selectedIndices), 'k.')
    else
        plot(realLocation(1, selectedIndices), realLocation(2, selectedIndices), '.')
    end
    
    axis([-2.5 2 -2 2.5])
    set(gca, 'XTickLabel', {});
    set(gca, 'YTickLabel', {});
    hold on
        
    subplot(1,2,2)
    if (i == 1)
        plot(predLocation(1, selectedIndices), predLocation(2, selectedIndices), '.', 'color' , [0.7 0.7 0.7])
    elseif (i == 7)        
        plot(predLocation(1, selectedIndices), predLocation(2, selectedIndices), 'k.')
    else
        plot(predLocation(1, selectedIndices), predLocation(2, selectedIndices), '.')
    end
    axis([-2.5 2 -2 2.5])
    set(gca, 'XTickLabel', {});
    set(gca, 'YTickLabel', {});
    hold on
        
end



end





function newCode = ConvertCode(code)

 newCode = zeros(size(code)); 

 newCode(code == 25) = 1;
 newCode(code == 32) = 2;
 newCode(code == 39) = 3;
 newCode(code == 46) = 4;
 newCode(code == 45 | code == 47) = 5;
 newCode(code == 44 | code == 48) = 6;
 newCode(code == 43 | code == 49) = 7;
 newCode(code == 36 | code == 42) = 8;
 newCode(code == 29 | code == 35) = 9;
 newCode(code == 22 | code == 28) = 10;
 newCode(code == 15 | code == 21) = 11;
 newCode(code == 8 | code == 14) = 12;
 newCode(code == 1 | code == 7) = 13;
 newCode(code == 2 | code == 6) = 14;
 newCode(code == 3 | code == 5) = 15;
 newCode(code ==  4) = 16;
 newCode(code == 11) = 17;
 newCode(code == 18) = 18;
 

end

