

outputNames = {'Rapatu15', 'Rapatu16', 'Rapatu17', 'Rapatu18', 'Rapatu24', 'Rapatu25', 'Rapatu27'};



GG = [];
for i = 1:numel(outputNames)
   load(outputNames{i})
   
   gg = [];
   for j = 1:10
       
       marker = MarkReplay3(A(j).valid_loc, A(j).res, A(j).trIndex_v);
       startIdx = find(marker == 1);
       startTime = A(j).timestamp_v(startIdx);
       trials = unique(A(j).trIndex_v(startIdx));  
       
       ST{j} = startTime;
       TR{j} = trials;
       
       if(isempty(trials))
           gg{j} = [];
           continue
       end
       
       gg{j} = (ST{j} + 40 - (TS{j}(cell2mat(values(EZ{j}, num2cell(TR{j}))))));%  ./ ((TS{j}(cell2mat(values(SM{j}, num2cell(TR{j}))))) - (TS{j}(cell2mat(values(EZ{j}, num2cell(TR{j})))))) ;       
       
       % Animate(A(j).valid_loc(:, A(j).trIndex_v == 103), A(j).res(:, A(j).trIndex_v == 103), 0.5, [-3 3 -3 3], 0);      
       
   end
   
   GG{i} = [gg{:}];    
end




TimeLockedToStart = [GG{:}];
figure
hist(TimeLockedToStart, 60)


save('TeleTime', 'TimeLockedToEnd', 'TimeLockedToStart')

% gg{hhh}  = (startTime - sideOn(trials)) ./ -(timestamps(cell2mat(values(enteringZone, num2cell(trials)))) - timestamps(cell2mat(values(startMovement, num2cell(trials)))));
% timeLocked{hhh} = startTime - sideOn(trials);
% timeLockedEnd{hhh} = startTime - timestamps(cell2mat(values(startMovement, num2cell(trials))));
