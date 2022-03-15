
%script to rearrange the matfile output from v3d Inverse Dynamics for MAS
%study - w/no filling of missing data

clear all;
clc;
dbstop if error;

tic 

participantnum = 04;

%import file and setup counter - change name before running
load('s04momentsoutput.mat');
N = length(FILE_NAME);

%import trial details & sort as they are presented systematically in data sheets- Changename before running
detailsraw = xlsread('S04 Trial Details.xlsx');
trialdetails = sortrows(detailsraw);
direction = trialdetails(:,4);
hand = trialdetails(:,3);

% retrieve trial numbers from c3d file names - there are ordered by trial
% number by default
for c = 1:N
        trialnum{c} = FILE_NAME{c}(end-5:end-4);
end

%downsample force data (columns 1-6) by half & transpose the array

for k = 1:N;
    forcedownsampled{k} = downsample(Force{k},2);
end

forcedownsampled = forcedownsampled';

%create a table of the participant number and details with space for
%additional data to be calculated in the following loop

participantdetails = table(zeros(36,1),zeros(36,1),zeros(36,1),zeros(36,1),zeros(36,1),zeros(36,1),...
    zeros(36,1),zeros(36,1),zeros(36,3),zeros(36,3),zeros(36,3),zeros(36,3),zeros(36,3),...
    zeros(36,3),zeros(36,3),zeros(36,3),zeros(36,3),zeros(36,3),zeros(36,3),zeros(36,3),...
    zeros(36,3),'VariableNames', {'ParticipantNumber','TrialNumber','Position','Hand',...
    'Direction','TrialNumberV3D','ForceMainDirectionPeak','idxofPeakForce','forceXYZ','RightShoulderMomentXYZ',...
    'RightShoulderAngleXYZ','RightElbowMomentXYZ','RightElbowAngleXYZ','RightWristMomentXYZ',...
    'RightWristAngleXYZ','LeftShoulderMomentXYZ','LeftShoulderAngleXYZ','LeftElbowMomentXYZ',...
    'LeftElbowAngleXYZ','LeftWristMomentXYZ','LeftWristAngleXYZ'});

participantdetails.ParticipantNumber(:,1) = participantnum(:,:);
participantdetails.TrialNumber(:,1) = trialdetails(:,1);
participantdetails.Position(:,1) = trialdetails(:,2);
participantdetails.Hand(:,1) = trialdetails(:,3);
participantdetails.Direction(:,1) = trialdetails(:,4);
TrialNumberV3D = str2double(trialnum(1,:));
participantdetails.TrialNumberV3D(:,1) = TrialNumberV3D(1,:); %Conversion to double from cell is not possible.


%not absolutely needed, but relabeled raw channels so we can fill/filter
%later if needed
RShoulderMoment = RSHOULDER_MOM;
RShoulderAngle = RSHOULDER_ANGLE;
RElbowMoment = RELBOW_MOM;
RElbowAngle = RELBOW_ANGLE;
RWristMoment = RWRIST_MOM;
RWristAngle = RWRIST_ANGLE;
LShoulderMoment = LSHOULDER_MOM;
LShoulderAngle = LSHOULDER_ANGLE;
LElbowMoment = LELBOW_MOM;
LElbowAngle = LELBOW_ANGLE;
LWristMoment = LWRIST_MOM;
LWristAngle = LWRIST_ANGLE;


%create a 36x1 cell array of zeros to use incase there is no data for that trial
%so as to not break the loop 
for h = 1:N
   blanks{h} = zeros(500,1);
end

for i = 1:N;
    
       
    %relabel force columns into their component directions, pick the
    %appropriate (main directon for that trial) peak and the index value where the peak is located
    
    if not(isempty(forcedownsampled{i}));
       [valup{i}, idx] = min(forcedownsampled{i}(:,1));
       idxup{i} = idx;
       [valdown{i}, idx] = max(forcedownsampled{i}(:,1)); 
       idxdown{i} = idx;
       [valpush{i}, idx] = max(forcedownsampled{i}(:,2));
       idxpush{i} = idx;
       [valpull{i}, idx] = min(forcedownsampled{i}(:,2));
       idxpull{i} = idx;
       [valleft{i}, idx] = max(forcedownsampled{i}(:,3));
       idxleft{i} = idx;
       [valright{i}, idx] = min(forcedownsampled{i}(:,3));
       idxright{i} = idx;

    elseif isempty(forcedownsampled{i});
       [valup{i}, idx] = max(blanks{i}(:,1));
       idxup{i} = idx;
       [valdown{i}, idx] = max(blanks{i}(:,1));
       idxdown{i} = idx;
       [valpush{i}, idx] = max(blanks{i}(:,1));
       idxpush{i} = idx;
       [valpull{i}, idx] = max(blanks{i}(:,1));
       idxpull{i} = idx;
       [valleft{i}, idx] = max(blanks{i}(:,1));
       idxleft{i} = idx;
       [valright{i}, idx] = max(blanks{i}(:,1));
       idxright{i} = idx;
              
    end
    
    %fills raw force colums with absolute force from that trial so we can
    %observe % in correct direction if needed later
    
    if not(isempty(forcedownsampled{i}));
        participantdetails.forceXYZ(i,1) = max(abs(forcedownsampled{i}(:,1)));
        participantdetails.forceXYZ(i,2) = max(abs(forcedownsampled{i}(:,2)));
        participantdetails.forceXYZ(i,3) = max(abs(forcedownsampled{i}(:,3)));
        
    elseif isempty(forcedownsampled{i});
        participantdetails.forceXYZ(i,:) = blanks{i}((i),:);
    end
    
    %using direction details from the previous if statement, pick the
    %moment/angle values at the index for the peak force for that trial according to
    %direction and hand and inserts those into the table
    
    if direction(i,1) == 1 & hand(i,1) == 0
        participantdetails.ForceMainDirectionPeak(i,1) = valup{1,i};
        participantdetails.idxofPeakForce(i,1) = idxup{1,i};
        participantdetails.RightShoulderMomentXYZ(i,:) = RShoulderMoment{i}(idxup{i},:);
        participantdetails.RightShoulderAngleXYZ(i,:) = RShoulderAngle{i}(idxup{i},:);
        participantdetails.RightElbowMomentXYZ(i,:) = RElbowMoment{i}(idxup{i},:);
        participantdetails.RightElbowAngleXYZ(i,:) = RElbowAngle{i}(idxup{i},:);
        participantdetails.RightWristMomentXYZ(i,:) = RWristMoment{i}(idxup{i},:);
        participantdetails.RightWristAngleXYZ(i,:) = RWristAngle{i}(idxup{i},:);
    elseif direction(i,1) == 2 & hand(i,1) == 0
        participantdetails.ForceMainDirectionPeak(i,1) = valdown{1,i};
        participantdetails.idxofPeakForce(i,1) = idxdown{1,i};
        participantdetails.RightShoulderMomentXYZ(i,:) = RShoulderMoment{i}(idxdown{i},:);
        participantdetails.RightShoulderAngleXYZ(i,:) = RShoulderAngle{i}(idxdown{i},:);
        participantdetails.RightElbowMomentXYZ(i,:) = RElbowMoment{i}(idxdown{i},:);
        participantdetails.RightElbowAngleXYZ(i,:) = RElbowAngle{i}(idxdown{i},:);
        participantdetails.RightWristMomentXYZ(i,:) = RWristMoment{i}(idxdown{i},:);
        participantdetails.RightWristAngleXYZ(i,:) = RWristAngle{i}(idxdown{i},:);
    elseif direction(i,1) == 3 & hand(i,1) == 0
        participantdetails.ForceMainDirectionPeak(i,1) = valpush{1,i};
        participantdetails.idxofPeakForce(i,1) = idxpush{1,i};
        participantdetails.RightShoulderMomentXYZ(i,:) = RShoulderMoment{i}(idxpush{i},:);
        participantdetails.RightShoulderAngleXYZ(i,:) = RShoulderAngle{i}(idxpush{i},:);
        participantdetails.RightElbowMomentXYZ(i,:) = RElbowMoment{i}(idxpush{i},:);
        participantdetails.RightElbowAngleXYZ(i,:) = RElbowAngle{i}(idxpush{i},:);
        participantdetails.RightWristMomentXYZ(i,:) = RWristMoment{i}(idxpush{i},:);
        participantdetails.RightWristAngleXYZ(i,:) = RWristAngle{i}(idxpush{i},:);
    elseif direction(i,1) == 4 & hand(i,1) == 0
        participantdetails.ForceMainDirectionPeak(i,1) = valpull{1,i};
        participantdetails.idxofPeakForce(i,1) = idxpull{1,i};
        participantdetails.RightShoulderMomentXYZ(i,:) = RShoulderMoment{i}(idxpull{i},:);
        participantdetails.RightShoulderAngleXYZ(i,:) = RShoulderAngle{i}(idxpull{i},:);
        participantdetails.RightElbowMomentXYZ(i,:) = RElbowMoment{i}(idxpull{i},:);
        participantdetails.RightElbowAngleXYZ(i,:) = RElbowAngle{i}(idxpull{i},:);
        participantdetails.RightWristMomentXYZ(i,:) = RWristMoment{i}(idxpull{i},:);
        participantdetails.RightWristAngleXYZ(i,:) = RWristAngle{i}(idxpull{i},:);
    elseif direction(i,1) == 5 & hand(i,1) == 0
        participantdetails.ForceMainDirectionPeak(i,1) = valleft{1,i};
        participantdetails.idxofPeakForce(i,1) = idxleft{1,i};
        participantdetails.RightShoulderMomentXYZ(i,:) = RShoulderMoment{i}(idxleft{i},:);
        participantdetails.RightShoulderAngleXYZ(i,:) = RShoulderAngle{i}(idxleft{i},:);
        participantdetails.RightElbowMomentXYZ(i,:) = RElbowMoment{i}(idxleft{i},:);
        participantdetails.RightElbowAngleXYZ(i,:) = RElbowAngle{i}(idxleft{i},:);
        participantdetails.RightWristMomentXYZ(i,:) = RWristMoment{i}(idxleft{i},:);
        participantdetails.RightWristAngleXYZ(i,:) = RWristAngle{i}(idxleft{i},:);
    elseif direction(i,1) == 6 & hand(i,1) == 0
        participantdetails.ForceMainDirectionPeak(i,1) = valright{1,i};
        participantdetails.idxofPeakForce(i,1) = idxright{1,i};
        participantdetails.RightShoulderMomentXYZ(i,:) = RShoulderMoment{i}(idxright{i},:);
        participantdetails.RightShoulderAngleXYZ(i,:) = RShoulderAngle{i}(idxright{i},:);
        participantdetails.RightElbowMomentXYZ(i,:) = RElbowMoment{i}(idxright{i},:);
        participantdetails.RightElbowAngleXYZ(i,:) = RElbowAngle{i}(idxright{i},:);
        participantdetails.RightWristMomentXYZ(i,:) = RWristMoment{i}(idxright{i},:);
        participantdetails.RightWristAngleXYZ(i,:) = RWristAngle{i}(idxright{i},:);
    elseif direction(i,1) == 1 & hand(i,1) == 1
        participantdetails.ForceMainDirectionPeak(i,1) = valup{1,i};
        participantdetails.idxofPeakForce(i,1) = idxup{1,i};
        participantdetails.LeftShoulderMomentXYZ(i,:) = LShoulderMoment{i}(idxup{i},:);
        participantdetails.LeftShoulderAngleXYZ(i,:) = LShoulderAngle{i}(idxup{i},:);
        participantdetails.LeftElbowMomentXYZ(i,:) = LElbowMoment{i}(idxup{i},:);
        participantdetails.LeftElbowAngleXYZ(i,:) = LElbowAngle{i}(idxup{i},:);
        participantdetails.LeftWristMomentXYZ(i,:) = LWristMoment{i}(idxup{i},:);
        participantdetails.LeftWristAngleXYZ(i,:) = LWristAngle{i}(idxup{i},:);
    elseif direction(i,1) == 2 & hand(i,1) == 1
        participantdetails.ForceMainDirectionPeak(i,1) = valdown{1,i};
        participantdetails.idxofPeakForce(i,1) = idxdown{1,i};
        participantdetails.LeftShoulderMomentXYZ(i,:) = LShoulderMoment{i}(idxdown{i},:);
        participantdetails.LeftShoulderAngleXYZ(i,:) = LShoulderAngle{i}(idxdown{i},:);
        participantdetails.LeftElbowMomentXYZ(i,:) = LElbowMoment{i}(idxdown{i},:);
        participantdetails.LeftElbowAngleXYZ(i,:) = LElbowAngle{i}(idxdown{i},:);
        participantdetails.LeftWristMomentXYZ(i,:) = LWristMoment{i}(idxdown{i},:);
        participantdetails.LeftWristAngleXYZ(i,:) = LWristAngle{i}(idxdown{i},:);
    elseif direction(i,1) == 3 & hand(i,1) == 1
        participantdetails.ForceMainDirectionPeak(i,1) = valpush{1,i};
        participantdetails.idxofPeakForce(i,1) = idxpush{1,i};
        participantdetails.LeftShoulderMomentXYZ(i,:) = LShoulderMoment{i}(idxpush{i},:);
        participantdetails.LeftShoulderAngleXYZ(i,:) = LShoulderAngle{i}(idxpush{i},:);
        participantdetails.LeftElbowMomentXYZ(i,:) = LElbowMoment{i}(idxpush{i},:);
        participantdetails.LeftElbowAngleXYZ(i,:) = LElbowAngle{i}(idxpush{i},:);
        participantdetails.LeftWristMomentXYZ(i,:) = LWristMoment{i}(idxpush{i},:);
        participantdetails.LeftWristAngleXYZ(i,:) = LWristAngle{i}(idxpush{i},:);
    elseif direction(i,1) == 4 & hand(i,1) == 1
        participantdetails.ForceMainDirectionPeak(i,1) = valpull{1,i};
        participantdetails.idxofPeakForce(i,1) = idxpull{1,i};
        participantdetails.LeftShoulderMomentXYZ(i,:) = LShoulderMoment{i}(idxpull{i},:);
        participantdetails.LeftShoulderAngleXYZ(i,:) = LShoulderAngle{i}(idxpull{i},:);
        participantdetails.LeftElbowMomentXYZ(i,:) = LElbowMoment{i}(idxpull{i},:);
        participantdetails.LeftElbowAngleXYZ(i,:) = LElbowAngle{i}(idxpull{i},:);
        participantdetails.LeftWristMomentXYZ(i,:) = LWristMoment{i}(idxpull{i},:);
        participantdetails.LeftWristAngleXYZ(i,:) = LWristAngle{i}(idxpull{i},:);
    elseif direction(i,1) == 5 & hand(i,1) == 1
        participantdetails.ForceMainDirectionPeak(i,1) = valleft{1,i};
        participantdetails.idxofPeakForce(i,1) = idxleft{1,i};
        participantdetails.LeftShoulderMomentXYZ(i,:) = LShoulderMoment{i}(idxleft{i},:);
        participantdetails.LeftShoulderAngleXYZ(i,:) = LShoulderAngle{i}(idxleft{i},:);
        participantdetails.LeftElbowMomentXYZ(i,:) = LElbowMoment{i}(idxleft{i},:);
        participantdetails.LeftElbowAngleXYZ(i,:) = LElbowAngle{i}(idxleft{i},:);
        participantdetails.LeftWristMomentXYZ(i,:) = LWristMoment{i}(idxleft{i},:);
        participantdetails.LeftWristAngleXYZ(i,:) = LWristAngle{i}(idxleft{i},:);
    elseif direction(i,1) == 6 & hand(i,1) == 1
        participantdetails.ForceMainDirectionPeak(i,1) = valright{1,i};
        participantdetails.idxofPeakForce(i,1) = idxright{1,i};
        participantdetails.LeftShoulderMomentXYZ(i,:) = LShoulderMoment{i}(idxright{i},:);
        participantdetails.LeftShoulderAngleXYZ(i,:) = LShoulderAngle{i}(idxright{i},:);
        participantdetails.LeftElbowMomentXYZ(i,:) = LElbowMoment{i}(idxright{i},:);
        participantdetails.LeftElbowAngleXYZ(i,:) = LElbowAngle{i}(idxright{i},:);
        participantdetails.LeftWristMomentXYZ(i,:) = LWristMoment{i}(idxright{i},:);
        participantdetails.LeftWristAngleXYZ(i,:) = LWristAngle{i}(idxright{i},:);
    end
    
    %flags a trial with missing force data as NaN values so no outlier
    %Moment/angles get included for bad trials
    
    if isempty(forcedownsampled{i});
        participantdetails.ForceMainDirectionPeak(i,1) = NaN;
        participantdetails.RightShoulderMomentXYZ(i,:) = NaN;
        participantdetails.RightShoulderAngleXYZ(i,:) = NaN;
        participantdetails.RightElbowMomentXYZ(i,:) = NaN;
        participantdetails.RightElbowAngleXYZ(i,:) = NaN;
        participantdetails.RightWristMomentXYZ(i,:) = NaN;
        participantdetails.RightWristAngleXYZ(i,:) = NaN;
        participantdetails.ForceMainDirectionPeak(i,1) = NaN;
        participantdetails.LeftShoulderMomentXYZ(i,:) = NaN;
        participantdetails.LeftShoulderAngleXYZ(i,:) = NaN;
        participantdetails.LeftElbowMomentXYZ(i,:) = NaN;
        participantdetails.LeftElbowAngleXYZ(i,:) = NaN;
        participantdetails.LeftWristMomentXYZ(i,:) = NaN;
        participantdetails.LeftWristAngleXYZ(i,:) = NaN;
    end
    
end

%check trial number from details sheet vs trial number from v3d filename

for j = 1:N
    
    if trialdetails(j,1) ~= TrialNumberV3D(:,j)
       disp('mismatch trial numbers in row #')
       disp(j)
    end
        
end

%write data to excelsheet 

writetable(participantdetails,'S04JointMomentsandAngles.xlsx');

toc