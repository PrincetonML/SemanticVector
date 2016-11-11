function badones = find_bad_atoms(Dictionary, WordVector) 
%find bad atoms 
% INPUT:
% Dictionary: each column is an atom
% WordVector: each column is a vector; normalized
% OUTPUT:
% badones: indices of the found bad atoms

badones = []; 
for i=1:size(Dictionary,2) 
  corr = Dictionary(:,i)'*WordVector; 
  [~,sidd] = sort(corr, 'descend'); 
  found = 0;
  
  % Test atom with related words 
  ntop = 10;
  for j=1:ntop 
    WordVecTemp = WordVector; 
    vec1 = WordVecTemp(:, sidd(j)); 
    idd = i; 
    vec2 = Dictionary(:, idd);
    clique = [vec1 vec2]; 
    WordVecTemp(:, sidd(j)) = 0;  
    
    num = 2; 
    corr1 = prctile(abs(clique'*WordVecTemp), 10);
    [~,sid] = sort(corr1, 'descend'); 
    limit = 0.45; 
  
    while corr1(sid(1)) > limit && num<6
      clique = [clique WordVecTemp(:, sid(1))]; %add to dense graph
      num = num+1; 
      densitynew = density(clique, num); 
      if densitynew < limit
        break
      end
      WordVecTemp(:, sid(1)) = [];  
      corr1 = min(abs(clique'*WordVecTemp)); 
      [~,sid] = sort(corr1, 'descend'); 
    end
    if num >= 5
        found = 1; 
        break;
    end
  end
  if found == 0 
      disp(['Bad atom: ' num2str(i)]);
      badones = [badones i];
  end
end

end


function d = density(clique, num)
% calculate min-density
densitymx = abs(clique'*clique); 
degrees = prctile(densitymx,[10],1); 
d = min(degrees);

end