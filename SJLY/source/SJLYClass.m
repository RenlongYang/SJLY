classdef SJLYClass
% SJLY, an interface to pseudo finite time scaling algorithms 
% focusing on quantification of invasion capability
%   sjly = SJLYClass() instanciates a SJLY class 
%   The arguments to SJLYClass are 
%   passed via property/value pairs in SJLYInputProperties, see the
%   table below.
% 
%   For example,
%   {
%     sjly  = SJLYClass();
%     sjly.SJLYInputProperties = SJLYInputProperties;
%     }
%   instanciate a SJLY class named 'sjly' and assign its property 
%   'SJLYInputProperties' with the user-predefined input information
%   'SJLYInputProperties'
% 
%   SJLY class has the following properties:
%   ------------------------------------------
% 
%   Required input predefined property:
%   
%  PAlleeInputProperties     user-predefined input
% 
%   Optional, empty understood when left out:
% 
%     workerID                            for parallel use      
%     URDMELink                    the directory of URDME
%     comsolModel         MPH file of predefined comsol model
%     URDMEUmod                 URDME Umod struct 
%     URDMEXmi             property xmi of URDME Umod struct 
%     cellArea                   the minimum area of a cell (that of its nucleus)
%     areaThreshold        restriction of proliferation and migration with 
%                                    regard to crowdedness
%     Species                     the labels of the species defined in URDME           
%     customReactions     the labels of the species defined in URDME     
%     poissonCoefficients  value table of the poisson coefficients of the
%                                       reactions
%     fullDBackup              backup of the diffusion matrix (full means against sparse)
%     D                               the diffusion matrix
%     InitialCellNumberDistribution     'u0' in URDME umod struct, a 2D array
%                                                         with cell number and location as indices
%     totalCellNumber       all cell species added together, one entry for one time step            
%     URDMEUmod_out                            URDME output struct
%     cellNumberSpatioTemporal             URDME umod_out.U
%     numberSpecies                                 number of species
%     xCoordinates                x coordinates of the URDME subVolumes
%     yCoordinates                y coordinates of the URDME subVolumes
%     numberSubvolumes    total number of EURDME subVolumes
%     regionInitialDistribution     an array of indices of initial regions 
%     overcrowdFlag                    1D array recording the overcrowdedness in
%                                                 each URDME subVolume
%                                                 
% PAlleeClass has the following methods:
% -------------------------------------------------------------
%PAlleeClassDefinition               the constructor
% URDMEStartup(obj)                linking URDME with matlab
% geometryComsolToURDME(obj)    from Comsol MPH file to URDME umod struct
% regionInitialDistributionGenerator(obj)  given regionInitialDistributionBoudaries  
%                                                   in PAlleeInputProperties, output regionInitialDistribution
%getWorkerID(obj)                      for parallel computation
%readTrajectory(obj, speciesIndex)    read from output data the agent number
%                                                         trajetory of a specific species
%updateDiffusionOperatorForCrowdedness(obj umod)     dealing with unphysical
%                                                             overcrowdedness in the subVolumes,
%                                                             'umod' is the temporary umod struct
%                                                             during one simulation
% R. Yang, Y. Shao 2021-10-10

    properties
        workerID=[];
        SJLYInputProperties = [];
        prob = [];
        meanProb = [];
        fitresultMeanProb = [];
        stdExpProb = [];
        uncertaintyProb = [];
        Tmax = [];
        meanNu = [];
        uncertaintyNu = [];       
        pseudoFTSPreparation = pseudoFTSPreparationClass();
        pseudoFTS = pseudoFTSClass();
        pseudoFTSGA = pseudoFTSGAClass();
    end
    methods
    %the constructor
        function obj = SJLYClass()
        end
        function obj = meanProbCal(obj)
            i=obj.SJLYInputProperties;
            for j=1:length(i.booleanTrajectoryTable)
                obj.prob(j).array = squeeze(mean(i.booleanTrajectoryTable(j).table));
                obj.meanProb(j).array = squeeze(mean(obj.prob(j).array));
                obj.stdExpProb(j).array = sqrt((1/(i.ensembleSize*(i.ensembleSize-1)))*sum((obj.prob(j).array-obj.meanProb(j).array).^2,1));
                obj.uncertaintyProb(j).array = obj.stdExpProb(j).array*1.96;
            end
        end
        function obj = TmaxSpearman(obj)
           
            i=obj.SJLYInputProperties;
             [~,indexMinOccupationProbability] = max(i.OccupationProbability);
            meanProbMaxOccupationProbability = obj.meanProb(indexMinOccupationProbability).array;
            [fitresultMeanProbMaxOcupationProbability,~] = obj.createFitMeanProb(i.tspan, meanProbMaxOccupationProbability);
            tspanDense = [0:0.01:i.tspan(end)];
            meanProbFitMaxOcupationProbability = feval(fitresultMeanProbMaxOcupationProbability,tspanDense);
            derivativeMeanProbFitMaxOcupationProbability = diff(meanProbFitMaxOcupationProbability)/0.01;
            obj.Tmax = tspanDense(find(derivativeMeanProbFitMaxOcupationProbability== max(derivativeMeanProbFitMaxOcupationProbability))); 
        end
        function [fitresult, gof] = createFitMeanProb(obj,tspan, meanProbArray)
            %CREATEFITMEANPROBS(TSPAN,MEANPROB)
            %  Create a fit.
            %
            %  Data for fit:
            %      X Input : tspan
            %      Y Output: meanProb
            %  Output:
            %      fitresult : a fit object representing the fit.
            %      gof : structure with goodness-of fit info.


            %   MATLAB  27-Sep-2021 12:22:14 auto-generation


            %% Fit: 
            i = obj.SJLYInputProperties;
            [xData, yData] = prepareCurveData(i.tspan, meanProbArray);

            % Set up fittype and options.
            ft = fittype( 'smoothingspline' );
            opts = fitoptions( 'Method', 'SmoothingSpline' );
            opts.SmoothingParam = 0.000128216959709242;

            % Fit model to data.
            [fitresult, gof] = fit( xData, yData, ft, opts );
        end
        function obj = nuCal(obj)
            i=obj.SJLYInputProperties;
            %% Calculate mean Probability
            obj = obj.meanProbCal();
            %% Preparation for pseudoFTS
            pFP = obj.pseudoFTS.pseudoFTSPreparation;
            pFP.q = i.OccupationProbability;
            pFP.p = zeros(length(i.booleanTrajectoryTable),11);
            n = length(i.OccupationProbability);
            for j = 1:n
                j
                [obj.fitresultMeanProb(j).fitresult, ~] = obj.createFitMeanProb(i.tspan, obj.meanProb(j).array);
                obj.fitresultMeanProb(j).OccupationProbability = i.OccupationProbability(j);
                obj = obj.TmaxSpearman();
                pFP.Tmax = obj.Tmax;
                pFP = pseudoFTSTimeSampPrep(pFP);
                pFP.p(j,:) = feval(obj.fitresultMeanProb(j).fitresult,pFP.tSamp);
                
            end
            pFP = eraseNegativeFitValue(pFP);
          
            obj.pseudoFTS.pseudoFTSPreparation = pFP;
            %% run the genetic algo
            obj.pseudoFTSGA.pseudoFTS = obj.pseudoFTS;
            obj.pseudoFTSGA = obj.pseudoFTSGA.pseudoFTSGARun();
            obj.meanNu =obj.pseudoFTSGA.meanNu;
            obj.uncertaintyNu = obj.pseudoFTSGA.uncertaintyNu ;       
        end
    end
end