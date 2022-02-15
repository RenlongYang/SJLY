function SJLYInputPropertiesBT474 = SJLYInputPropertyFileMakerBT474()
    i = SJLYInputPropertiesClass;
    i.workingDirectory = 'D:\career\work\Draft for BMB\proofOfUncertainty\home\';
    i.dataSaveDirectory =[i.workingDirectory,'SJLY\examples\BT474\BT474AssayJohnson2019']; 
    i.tspan = [0:4:800];
    i.booleanTrajetoryTableDirectory = [i.workingDirectory,'SJLY\examples\BT474\BT474AssayJohnson2019\booleanTrajectoryTable\booleanTrajectoryTable.mat'];
    i.OccupationProbability = [0.45,0.46,0.47,0.48,0.49,0.50,0.51,0.52,0.53,0.54,0.55];
    load(i.booleanTrajetoryTableDirectory)
    for j=1:11
        k=j+44;
        eval(['i.booleanTrajectoryTable(',num2str(j),').table = booleanTrajectoryTable',num2str(k),';']);
    end
    SJLYInputPropertiesBT474 = i;
    save([SJLYInputPropertiesBT474.workingDirectory,'SJLY\examples\BT474\BT474AssayJohnson2019\SJLYInputPropertiesBT474.mat'],'SJLYInputPropertiesBT474');
end