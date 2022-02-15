classdef pseudoFTSGAClass
    properties
        pseudoFTS = pseudoFTSClass;
        lb = [0.01,0.01,0.01,0.01];
        ub = [5,5,0.45,5];
        batchSize = 10000;
        Crossoverfrac = 0.5;
        PopulationSize = 300;
        EliteCount = 0.05*300;
        meanWinner = [];
        uncertaintyWinner = [];
        meanNu = [];
        uncertaintyNu = [];
    end
    methods
        function obj = pseudoFTSGAClass()
        end
        function obj = pseudoFTSGARun(obj)
           pf = obj.pseudoFTS;
          
           h = waitbar(0,'GA in process');
            winnerList = zeros(obj.batchSize,4);
            fvalList = zeros(obj.batchSize,1);
            for i = 1:obj.batchSize
                s = ['GA in process:',num2str(ceil(i/obj.batchSize*10000)),'%'];
                waitbar(i/obj.batchSize,h,s);
                ga_options = optimoptions('ga','Crossoverfrac',obj.Crossoverfrac,'PopulationSize',obj.PopulationSize,'EliteCount',obj.EliteCount); 

                [winner,fval,~,~,~,~] = ga(@(x)pf.negativeSpearmanRankCal(x(1),x(2),x(3),x(4)),4,[],[],[],[],obj.lb,obj.ub,[],ga_options);
                winnerList(i,:) = winner;
                fvalList(i) = fval;
            end 
            obj.meanWinner = mean(winnerList);
            stdExpWinner= sqrt((1/(10000*9999))*sum((winnerList-obj.meanWinner).^2));
            obj.uncertaintyWinner = stdExpWinner*1.96;
            obj.meanNu = obj.meanWinner(2);
            obj.uncertaintyNu = obj.uncertaintyWinner(2);
        end
    end
end