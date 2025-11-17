%%########################################################################################
%%% This the function calculates a matrix of appearence and disappearence
%%% times of stimuli from the timeline cell for plotting. It also
%%% calculates the requested events
%%########################################################################################


function TIMEdata = MW_timelineCalculate(TIMEdata)




% StimNames = Timeline.StimNames;
% StimTimeline = Timeline.StimTimline;
% Type_Event = Timeline.Event_Type

%%%we create an M matrix:each row contains the time points of appearence and
%%%disppearence of every stimulus. 
% M = [];
% 
% for i = 1:size(StimTimeline, 1);
%     A = [];
%     for j = 2: size(StimTimeline, 2);
%         for k = 1:size(StimTimeline{i,j},1);
%             A = [A StimTimeline{i,j}{k,1}];
%         end
%     end
%     if length(A) < 2*(size(StimTimeline, 2)-1);
%         B = zeros(1,(2*(size(StimTimeline, 2)-1))-length(A));
%         A = [A B];
%     end
%         
%     M = [M; A];
% end
% [M, Index] = sortrows(M);
% 
% Timeline.OnSet_OffSet = M;
% 
% StimNames_New = [];


%%%we here record all the events in the trial
% Events = {};
% for G = 1:length(Index(:,1));
%     StimNames_New{G} = StimNames{Index(G)};
%     if strcmp(MW_getStimData(StimNames_New{G}, 'type', trial), {'dynamic_random_dots'}) == 1;
%        [Events_Log, Timing] =MW_getStimData(StimNames_New{G}, Type_Event, trial) ;
%        if length(Events_Log)>1;
%           Events{G}{1} = Events_Log;
%           Events{G}{2} = Timing;
%        else
%            Events{G}{1} = 0;
%            Events{G}{2} = 0;
%        end
%     end
% end;
% 
% Timeline.Events = Events


%%%We extract the information about position and color of every stimulus%%
% Str = [];
% for i = 1:size(StimNames_New,2);
% 
%     if sum(strcmp(MW_getStimData(StimNames_New{i}, 'type', trial), {'dynamic_random_dots'}) >= 1);
%        U = double(cell2mat(MW_getStimData(StimNames_New{i}, 'field_center_x', trial)));
%        X = U(1);
%        U = double(cell2mat(MW_getStimData(StimNames_New{i}, 'field_center_y', trial)));
%        Y = U(1);
%        U = MW_getStimData(StimNames_New{i}, 'color', trial);
%        color = U(1);
%        ecc = num2str(round(10*sqrt((X^2) + (Y^2)))/10);
% 
%        X = num2str(round(10*X)/10);
%        Y = num2str(round(10*Y)/10);
%        
%        str1 = strcat('Coord. ecc.: (', X, ',', Y, ',', ecc, ')', '.', ' color :','[', color, ']');
%     elseif sum(strcmp(MW_getStimData(StimNames_New{i}, 'type', trial), {'blankscreen'}) >= 1);
%        R = num2str(cell2mat(MW_getStimData(StimNames_New{i}, 'color_r', trial)));
%        G = num2str(cell2mat(MW_getStimData(StimNames_New{i}, 'color_g', trial)));
%        B = num2str(cell2mat(MW_getStimData(StimNames_New{i}, 'color_b', trial)));
%        
%        str1 = strcat(' color :','[',R, ',', G, ',', B, ']');
%         
%     else
% 
%        U = double(cell2mat(MW_getStimData(StimNames_New{i}, 'pos_x', trial)));
%        X = U(1);
%        U = double(cell2mat(MW_getStimData(StimNames_New{i}, 'pos_y', trial)));
%        Y = U(1);
%        R = num2str(cell2mat(MW_getStimData(StimNames_New{i}, 'color_r', trial)));
%        G = num2str(cell2mat(MW_getStimData(StimNames_New{i}, 'color_g', trial)));
%        B = num2str(cell2mat(MW_getStimData(StimNames_New{i}, 'color_b', trial)));
%        ecc = num2str(round(10*sqrt((X^2) + (Y^2)))/10);
%        X = num2str(round(10*X)/10);
%        Y = num2str(round(10*Y)/10);
%        str1 = strcat('Coord.ecc.: (', X, ',', Y, ',', ecc, ')', '.', ' color :','[',R, ',', G, ',', B, ']');
%        
%     end
%     Str{i} = str1;
% end
% 
% Timeline.Properties = Str
% Timeline.StimNames =  StimNames_New


end

