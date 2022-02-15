classdef pseudoFTSClass
    properties
        pseudoFTSPreparation = pseudoFTSPreparationClass();
        NegativeSpearmanRank = [];
    end
    methods
        function obj = pseudoFTSClass()
        end
        function negativeSpearmanRank = negativeSpearmanRankCal(obj,beta,nu,qc,alpha)
            tSamp = obj.pseudoFTSPreparation.tSamp;
            p = obj.pseudoFTSPreparation.p;
            q =obj.pseudoFTSPreparation.q;
            qt = zeros(size(p));
            S = zeros(size(p));
            t = tSamp;
                for i=1:length(q)
                    for j=1:length(t)
                        S(i,j) =  p(i,j)*t(j)^(-beta);
                        qt(i,j) = (q(i)-qc)^alpha*(t(j))^(1/nu);
                    end
                end
                reshapeS = S(:);
                reshapeqt = qt(:);
                obj.NegativeSpearmanRank = -corr(reshapeqt, reshapeS, 'type' , 'Spearman');      
                negativeSpearmanRank = obj.NegativeSpearmanRank;
        end
    end
end