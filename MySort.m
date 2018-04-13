
% 
% function MySort()
%     
%     ASCENDING  = true; 
%     DESCENDING = false;
%     
%     a = rand(1, 10);
%     bitonicSort(1, numel(a), ASCENDING);    
%     
%     function bitonicSort(lo, n, dir)    
%         if (n>1)        
%             m = floor(n/2);
%             bitonicSort(lo, m, ASCENDING);
%             bitonicSort(lo+m, m, DESCENDING);
%             bitonicMerge(lo, n, dir);
%         end
%     end
%     
%     function bitonicMerge(lo, n, dir)    
%         if (n>1)        
%             m = floor(n/2);
%             for i=lo:lo+m-1
%                 compare(i, i+m, dir);
%             end
%             bitonicMerge(lo, m, dir);
%             bitonicMerge(lo+m, m, dir);
%         end
%     end
%     
%     function compare(i, j, dir)    
%         if (dir == (a(i) > a(j)))
%             exchange(i, j);
%         end
%     end
%     
%     function exchange(i, j)    
%         t = a(i);
%         a(i) = a(j);
%         a(j) = t;
%     end
% end
% 


   