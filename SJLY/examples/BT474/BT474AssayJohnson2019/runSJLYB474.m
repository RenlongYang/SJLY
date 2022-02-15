function runSJLYB474(SJLYInputProperties)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%A script customized for BT474 cancer cell culture aassays (Johnson, 2019)
%To make a model for your own cell culture assays, you need to at least
%make adaptation to the PAlleeInputProperties class, or furthermore, the 
% PAllee class itself.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load the matlab MAT file containing PAlleeInputPropertiesBT474
% load('~/PAllee/examples/BT474/PAlleeInputPropertiesBT474.mat'); 

%construct a PAllee object named 'PAlleeBT474'
SJLYBT474 = SJLYClass();
%assign the PAlleeInputProperties loaded just now to 'PAlleeBT474'
SJLYBT474.SJLYInputProperties = SJLYInputProperties;
%% abbreviating
s = SJLYBT474;
%% call user-accustomed functions in PAlleeInputPropertiesBT474 sequentially
SJLYBT474 = nuCal(SJLYBT474);
%save the PAllee object to user-designated save directory
save([SJLYBT474.dataSaveDirectory,'/SJLYDataBT474.mat'], 'SJLYBT474')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Reference
%Johnson, K.E., et al., Cancer cell population growth kinetics at low densities 
%deviate from the exponential growth model and suggest an Allee effect. 
%PLoS biology, 2019. 17(8): p. e3000399-e3000399.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%