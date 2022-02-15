classdef pseudoFTSPreparationClass
    properties
        Tmin = 256;
        Tmax = [];
        numberDivision = 10;
        tSamp = [];
        p = [];
        q = [];
    end
    methods
        function obj = pseudoFTSPreparationClass()
        end
        function obj = pseudoFTSTimeSampPrep(obj)
            obj.tSamp = exp([log(obj.Tmin):(log(obj.Tmax)-log(obj.Tmin))/10:log(obj.Tmax)]);  
   
        end
        function obj = eraseNegativeFitValue(obj)
             for i = 1:size(obj.p,1)
                 for j = 1:size(obj.p,2)
                     if obj.p(i,j)<0
                         obj.p(i,j)=0;
                     end
                 end
             end 
        end
    end
end