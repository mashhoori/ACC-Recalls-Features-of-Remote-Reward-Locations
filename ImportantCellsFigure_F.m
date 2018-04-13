
% folderNames = {'P1353_15p', 'P1353_16p', 'P1353_17p', 'P1353_18p', 'P1958_24p', 'P1958_25p', 'P1958_27p'};
outputNames = {'thN15p75_50', 'thN16p75_50', 'thN17p75_50', 'thN18p75_50', 'thN24p75_50', 'thN25p75_50', 'thN27p75_50'};
load('impStructure.mat')

a = [47 40 42 37 65 59 72];

figure
c = [];
for rat = 1:numel(outputNames)
    RD = load(outputNames{rat});
    
    cnt0 = zeros(1, a(rat));    
    for j = 1:10
        cnt0(RD.sig0{j}) = cnt0(RD.sig0{j}) + 1;
    end    
    
    cnt1 = zeros(1, a(rat));    
    for j = 1:10
        cnt1(RD.sig1{j}) = cnt1(RD.sig1{j}) + 1;
    end
    
    subplot(7, 1, rat);
    b = [cnt0 ; cnt1;  impStructure{rat, 1}/ 5;  impStructure{rat, 2}/ 5];
    c = [c, sum(b, 2)]
    
    if(ismember(rat, [1 3 5 6 7]))    
        [~, indices] = sort(cnt0, 'descend' );
    else
        [~, indices] = sort(cnt1, 'descend' );
    end
%     
    b = b(:, indices);
    
    b(b <= 3) = 0;
    b(b >= 7) = 10;
    b(b > 0 & b < 10) = 5;    
    
    imagesc(b);
    set(gca, 'YTick', [1:4] )
    set(gca, 'YTickLabel', {'Site0', 'Site1', 'Choice', 'Reward'} )
    grid on
    caxis([0, 10])
    
end


