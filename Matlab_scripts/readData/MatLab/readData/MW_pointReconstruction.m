function dotsPos = MW_pointReconstruction(filename)
% function [] = MW_pointReconstruction(filename)

addpath('/Library/Application Support/MWorks/Scripting/Matlab');

tic;

% Check if twister.mex is installed on this machine
try twister();
catch err
    disp('ERROR: twister.mexmaci64 not found or not on a 64-bit system, aborting');
    ppositions = [];
    dotsPos = [];
    return;
end

%Check if point positions already extracted
dir_contents = dir(filename);
for eventCX=1:size(dir_contents,1)
    if strcmp(dir_contents(eventCX).name, 'ml_pp_v2.mat')
        disp('Found previously analyzed point positions, doing nothing -> exit.');
        hurz = open([filename '/ml_pp_v2.mat']);
        dotsPos = hurz.dotsPos;
        return;
    end
end
clear dir_contents;

% ----- Read the frames... -----
disp('Read & Sort events/data...');
    
% Get header & events
codecs=getCodecs(filename);
eventBuffer = getEvents(filename,codec_tag2code(codecs.codec,'#state_system_mode'));
code = codec_tag2code(codecs.codec, '#stimDisplayUpdate');
eventBuffer = getEvents(filename,code);
[~, order] = sort([eventBuffer(:).time_us],'ascend');
eventBuffer = eventBuffer(order);
clear order code;


% ##### Check EXP_version ####


stimulus_type = 'dynamic_random_dots';
% -----------------------------------
% write all data to "names" and "updates"
disp(['Reading ', num2str(size(eventBuffer,2)), ' frames...']);
updateCX = 0;
updates = zeros(20,size(eventBuffer,2));
names = cell(1,size(eventBuffer,2));
dotcolors = cell(1,size(eventBuffer,2));
failure = 0;
for eventCX=1:size(eventBuffer,2)
    for frameCX=1:size(eventBuffer(eventCX).data,2)
        if isstruct(eventBuffer(eventCX).data{1,frameCX})
            if strcmp(eventBuffer(eventCX).data{1,frameCX}.type,stimulus_type)
                try
                    eventBuffer(eventCX).data{1,frameCX}.lastDotPosition;
                    t = sscanf(eventBuffer(eventCX).data{1,frameCX}.lastDotPosition,'%f,%f,%f,%f,%f,%f')';
                    x=t(1); y=t(2); z=t(3); r=t(4); g=t(5); b=t(6);
%                     updates(:,updateCX + 1) = ...
%                         [eventBuffer(eventCX).time_us;
%                         eventBuffer(eventCX).data{1,frameCX}.reset;
%                         eventBuffer(eventCX).data{1,frameCX}.mt19937_seed;
%                         eventBuffer(eventCX).data{1,frameCX}.num_dots;
%                         x; y; z;
%                         eventBuffer(eventCX).data{1,frameCX}.field_radius;
%                         eventBuffer(eventCX).data{1,frameCX}.field_center_x;
%                         eventBuffer(eventCX).data{1,frameCX}.field_center_y;
%                         eventBuffer(eventCX).data{1,frameCX}.dot_lifetime;
%                         eventBuffer(eventCX).data{1,frameCX}.speed;
%                         eventBuffer(eventCX).data{1,frameCX}.direction;
%                         eventBuffer(eventCX).data{1,frameCX}.update_delta;
%                         eventBuffer(eventCX).data{1,frameCX}.field_center_z;
%                         r; g; b;
%                         eventBuffer(eventCX).data{1,frameCX}.dot_size; 0 ];

                        updates(1,updateCX+1) = eventBuffer(eventCX).time_us;
                        updates(2,updateCX+1) = eventBuffer(eventCX).data{1,frameCX}.reset;
                        updates(3,updateCX+1) = eventBuffer(eventCX).data{1,frameCX}.mt19937_seed;
                        updates(4,updateCX+1) = eventBuffer(eventCX).data{1,frameCX}.num_dots;
                        updates(5,updateCX+1) = x;
                        updates(6,updateCX+1) = y;
                        updates(7,updateCX+1) = z;
                        updates(8,updateCX+1) = eventBuffer(eventCX).data{1,frameCX}.field_radius;
                        updates(9,updateCX+1) = eventBuffer(eventCX).data{1,frameCX}.field_center_x;
                        updates(10,updateCX+1) = eventBuffer(eventCX).data{1,frameCX}.field_center_y;
                        updates(11,updateCX+1) = eventBuffer(eventCX).data{1,frameCX}.dot_lifetime;
                        updates(12,updateCX+1) = eventBuffer(eventCX).data{1,frameCX}.speed;
                        updates(13,updateCX+1) = eventBuffer(eventCX).data{1,frameCX}.direction;
                        updates(14,updateCX+1) = eventBuffer(eventCX).data{1,frameCX}.update_delta;
                        updates(15,updateCX+1) = eventBuffer(eventCX).data{1,frameCX}.field_center_z;
                        updates(16,updateCX+1) = r;
                        updates(17,updateCX+1) = g;
                        updates(18,updateCX+1) = b;
                        updates(19,updateCX+1) = eventBuffer(eventCX).data{1,frameCX}.dot_size;         
                        updates(20,updateCX+1) = 0;

                    clear x y z r g b t;
                    dotcolors{updateCX+1} = eventBuffer(eventCX).data{1,frameCX}.color;
                    names{updateCX+1} = eventBuffer(eventCX).data{1,frameCX}.name;
                    switch eventBuffer(eventCX).data{1,frameCX}.RDP_type
                        case 'linear'
                            updates(20,updateCX + 1) = 1;
                        case 'linearMask'
                            updates(20,updateCX + 1) = 2;
                        case '3Dlinear'
                            updates(20,updateCX + 1) = 3;
                        case '3DlinearMask'
                            updates(20,updateCX + 1) = 4;
                        case 'spiral'
                            updates(20,updateCX + 1) = 5;
                        case 'spiralMask'
                            updates(20,updateCX + 1) = 6;
                        otherwise
                            disp('Unsupported RDP type')
                            throw('type error')
                    end
                catch err
                    updateCX = 0;
                    failure = 1;
                    disp('Read Error for this:')
                    eventBuffer(eventCX).data{1,frameCX}
                    %throw(err)
                    break;
                end
                updateCX = updateCX + 1;
            end
        end
    end
    if failure
        break
    end
end

num_updates = updateCX;
clear eventCX frameCX updateCX failure;


% -----------------------------------

% getting screen data
disp('Getting Screen Info ..')
code = codec_tag2code(codecs.codec, '#mainScreenInfo');
eventBuffer = getEvents(filename,code);
[~, order] = sort([eventBuffer(:).time_us],'ascend');
eventBuffer = eventBuffer(order);
screen = eventBuffer(size(eventBuffer,1)).data;

disp('Sorting ..')
clear code codecs eventBuffer order stimulus_type;


% -----------------------------------



updates = updates(:,1:num_updates);

step = floor(num_updates/100);
M_PI = 3.14159265358979323846264338327950288;
failure = 0;
names = names(1:num_updates);
unames = unique(names);

for u=1:size(unames,2)
    w = 0;
    for i=1:num_updates
        if strcmp(names{i},unames{u})
            % ----- RDP wurde resetted -----
            if updates(2,i) == 1
                twister('state',updates(3,i));
                x=zeros(1,updates(4,i));
                y=x; d=x; lt=x;
                for a=1:updates(4,i) %for every dot
                    while 1
                        x(a) = -updates(8,i)+twister()*updates(8,i)*2;
                        y(a) = -updates(8,i)+twister()*updates(8,i)*2;
                        if ~(x(a)*x(a) + y(a)*y(a) > updates(8,i)*updates(8,i))
                            x(a) = x(a) + updates(9,i);
                            y(a) = y(a) + updates(10,i);
                            break
                        end
                    end
                end
                for a=1:updates(4,i) %for every dot perform the other randomizer steps
                    d(a)=twister()*360;
                    if updates(11,i) ~= -1
                        lt(a)=twister();
                    end
                end
                
                if updates(20,i) >= 5 && updates(20,i) <= 8 %spiral, spiralMask, 3Dspiral, 3DspiralMask
                    rIn = zeros(1,updates(4,i)); tetaIn = rIn; endPoint = rIn;
                    for dotNum = 1:updates(4,i)
                        verticesPerPolared = 1;
                        dotsPolared = zeros(1,updates(4,i)*3);
                        rIn(dotNum) = updates(8,i) * sqrt(twister());
                        tetaIn(dotNum) = 2.0 * M_PI * twister();
                        endPoint(dotNum) = rIn(dotNum) * sqrt(twister());
                        if updates(20,i) == 6
                            d(dotNum) = twister()*360;
                        end
                        x(dotNum) = rIn(dotNum) * cos(tetaIn(dotNum)) + updates(9,i);
                        y(dotNum) = rIn(dotNum) * sin(tetaIn(dotNum)) + updates(10,i);
                    end
                end
                
                if updates(20,i) == 3 || updates(20,i) == 4 %3dlinear or 3dlinearmask
                    width_unknown_units = double(screen.width);
                    distance_unknown_units = double(screen.distance);
                    half_width_deg = (double(180) / M_PI) * atan((width_unknown_units/double(2))/distance_unknown_units);
                    display_width = double(2) * half_width_deg;
                    metric_to_degrees = display_width / double(screen.width);
                    reye_x = (double(screen.eye_to_eye_dist) / double(2)) * metric_to_degrees;
                    reye_y = double(screen.eye_height) * metric_to_degrees;
                    leye_x = -reye_x;
                    leye_y = reye_y;
                    eye_distance = distance_unknown_units * metric_to_degrees;
                    
                    
                    x2=zeros(1,updates(4,i)*2);
                    y2=x2;
                    sizes=zeros(1,updates(4,i));
                    
                    for a=1:updates(4,i) %every dot
                        [x2(a) y2(a) x2(a+size(x2,2)/2) y2(a+size(x2,2)/2), sizes(a)] = make_ddots(x(a),y(a),updates(15,i),updates(19,i),reye_x,reye_y,leye_x,leye_y,eye_distance,display_width);
                    end
                end
            % ----- Normales Update des RDP -----
            else
                dr = updates(14,i) * updates(12,i);
                switch updates(20,i)
                    case {1,3} %linear %3Dlinear
                        theta = (double(90) - updates(13,i)) / double(180) * M_PI;
                        dx = dr * cos(theta);
                        dy = dr * sin(theta);
                        for a=1:updates(4,i) %for every dot
                            x(a) = x(a)+dx;
                            y(a) = y(a)+dy;
                            [x(a) y(a) ~] = check_point(x(a),y(a),dr,theta,updates(9,i),updates(10,i),updates(8,i));
                            if updates(20,i) == 3
                                [x2(a) y2(a) x2(a+size(x2,2)/2) y2(a+size(x2,2)/2) sizes(a)] = make_ddots(x(a),y(a),updates(15,i),updates(19,i),reye_x,reye_y,leye_x,leye_y,eye_distance,display_width);
                            end
                        end
                    case {2,4} %linearMask %3dlinearmask
                        for a=1:updates(4,i) %for every dot
                            theta = (double(90) - d(a)) / double(180) * M_PI;
                            dx = dr * cos(theta);
                            dy = dr * sin(theta);
                            x(a) = x(a)+dx;
                            y(a) = y(a)+dy;
                            [x(a), y(a), ~] = check_point(x(a),y(a),dr,theta,updates(9,i),updates(10,i),updates(8,i));
                            if updates(20,i) == 3
                                [x2(a), y2(a), x2(a+size(x2,2)/2), y2(a+size(x2,2)/2), sizes(a)] = make_ddots(x(a),y(a),updates(15,i),updates(19,i),reye_x,reye_y,leye_x,leye_y,eye_distance,display_width);
                            end
                        end
                    case {5,7} % spiral & 3Dspiral
                        cuttedDirection = (450 - updates(13,i)) - (floor(((450-updates(13,i)))/360)*360);
                        while cuttedDirection < 0
                            cuttedDirection = cuttedDirection + 360;
                        end
                        theta = -(450 - cuttedDirection) / 180 * M_PI;
                        for dotNum=1:updates(4,1)
                            lt(dotNum) = lt(dotNum)-updates(14,i);
                            if lt(dotNum) <= 0 && updates(11,i) ~= -1
                                disp('lifetime ~= -1');
                                rIn(dotNum) = updates(8,i) * sqrt(twister());
                                tetaIn(dotNum) = 2 * M_PI * twister();
                                endPoint(dotNum) = rIn(dotNum) * sqrt(twister());
                                lt(dotNum) = twister() * updates(11,i);
                            else
                                rIn(dotNum) = rIn(dotNum) + (rIn(dotNum)) * dr * cos(theta);
                                tetaIn(dotNum) = tetaIn(dotNum) + (dr * sin(theta));
                                if cuttedDirection > 180 % Contraction
                                    if rIn(dotNum) < endPoint(dotNum)
                                        endPoint(dotNum) = updates(8,i) * sqrt(twister());
                                        rIn(dotNum) = updates(8,i) + updates(8,i) * dr * cos(theta) * sqrt(twister());
                                        if (rIn(dotNum) < endPoint(dotNum))
                                            rIn(dotNum) = updates(8,i) * sqrt(twister());
                                            endPoint(dotNum) = rIn(dotNum) * sqrt(twister());
                                        end
                                        tetaIn(dotNum) = 2 * M_PI * twister();
                                    end
                                else % Expansion
                                    if (rIn(dotNum) > updates(8,i))
                                        rIn(dotNum) = updates(8,i) * sqrt(twister());
                                        endPoint(dotNum) = rIn(dotNum) * sqrt(twister());
                                        tetaIn(dotNum) = 2 * M_PI * twister();
                                    end
                                end
                            end
                            x(dotNum) = rIn(dotNum) * cos(tetaIn(dotNum)) + updates(9,i);
                            y(dotNum) = rIn(dotNum) * sin(tetaIn(dotNum)) + updates(10,i);
% RAB: INCLUDE 3DSPIRAL HERE!!!
%                           int didx = i*verticesPerDot;
%                           if (type == "3Dspiral")
%                                make_ddots(didx,dots[didx],dots[didx+1]); 
                        end
                    case {6,8} % spiralMask, 3DspiralMask
                        for dotCX = 1:updates(4,1)
                            lt(dotCX) = lt(dotCX) - updates(14,i);
                            cuttedDirection = (450 - d(dotCX)) - (floor(((450-d(dotCX)))/360)*360);
                            while cuttedDirection < 0
                                cuttedDirection = cuttedDirection + 360;
                            end
                            theta = -(450 - cuttedDirection) / 180 * M_PI;
                            if (lt(dotCX) <= 0) && (updates(11,i) ~= -1)
                                rIn(dotCX) = updates(8,i) * sqrt(twister());
                                tetaIn(dotCX) = 2 * M_PI * twister();
                                endPoint(dotCX) = rIn(dotCX) * sqrt(twister());
                                lt(dotCX) = twister() * update(11,i);
                            else
                                rIn(dotCX) = rIn(dotCX) + rIn(dotCX) * dr * cos(theta);
                                tetaIn(dotCX) = tetaIn(dotCX) + dr * sin(theta);
                                if (cuttedDirection > 180) % contraction
                                    if (rIn(dotCX) < endPoint(dotCX))
                                        endPoint(dotCX) = updates(8,i) * sqrt(twister());
                                        rIn(dotCX) = updates(8,i) + updates(8,i) * dr * cos(theta) * twister();
                                        if (rIn(dotCX) < endPoint(dotCX))
                                            rIn(dotCX) = updates(8,i) * sqrt(twister());
                                            endPoint(dotCX) = rIn(dotCX) * sqrt(twister());
                                        end
                                        tetaIn(dotCX) = 2 * M_PI * twister();
                                    end
                                else % expansion
                                    if (rIn(dotCX) > updates(8,i))
                                        rIn(dotCX) = updates(8,i) * sqrt(twister());
                                        endPoint(dotCX) = rIn(dotCX) * sqrt(twister());
                                        tetaIn(dotCX) = 2 * M_PI * twister();
                                    end
                                end
                            end
                            x(dotCX) = rIn(dotCX) * cos(tetaIn(dotCX)) + updates(9,i);
                            y(dotCX) = rIn(dotCX) * sin(tetaIn(dotCX)) + updates(10,i);
                            
% RAB spiralMASK 3D NOICH MACHEN!!!!                 
%                 int didx = i*verticesPerDot;
%                 if (type == "3Dspiral") make_ddots(didx,dots[didx],dots[didx+1]);
%             }
                        end
                        
                        
                end
            end
            
            if abs(diff([x(length(x)),updates(5,i)])) < 1e-4 && ... % 
                    abs(diff([y(length(y)),updates(6,i)])) < 1e-4 && ... % that's close enough (hence string parsing problem)
                    max(abs(diff([sscanf(dotcolors{i},'%f,%f,%f'),updates(16:18,i)]'))) < 1e-4
                switch updates(20,i)
                    case {1,2,5,6} %2D
                        ppositions(i) = struct('time_us',updates(1,i),'name',names{i},'num_dots',updates(4,i),'xpos',x','ypos',y');
                    case {3,4} %3D
                        ppositions(i) = struct('time_us',updates(1,i),'name',names{i},'num_dots',updates(4,i),'xpos',x2','ypos',y2','sizes',sizes);
                end
            else
                disp(['Update ' int2str(i) ' did not pass validation! ABORTING']);
                if abs(diff([x(length(x)),updates(5,i)])) >= 1e-4
                    disp(['FEHLER: x -> ', num2str( x(length(x)) ), ' <> ', num2str( updates(5,i) ), ' <-']);
                end
                if  abs(diff([y(length(y)),updates(6,i)])) >= 1e-4
                    disp(['FEHLER: y -> ', num2str( y(length(y)) ), ' <> ', num2str( updates(6,i) ), ' <-']);
                end
                if max(abs(diff([sscanf(dotcolors{i},'%f,%f,%f'),updates(16:18,i)]'))) >= 1e-4
                    disp(['FEHLER: color -> ', dotcolors{i}, ' <> ', num2str( updates(16,i) ), ',', ...
                    num2str( updates(17,i) ), ',', num2str( updates(18,i) ), ' <-']); %num2str( updates(16:18,i) )
                end
                failure = 1;
                break
            end
        end
        if i == 1
            fprintf('\nCalculating Positions of RDP %s -> ', unames{u});
        end
        if i>w*step
            w=w+10;
            fprintf('.'); % %s', ['Calculating Positions... ',  num2str(w), '%'])
        end
    end
    if failure == 1
        disp('FEHLER!')
        break
    end
end

fprintf('\n');

if failure == 0

    disp('Sort the dotpositions by trials');
    [exp, trial] = MW_readExperiment(filename);
    for trialCX = 1:length(trial)
        idx = find(([ppositions.time_us] >= trial(trialCX).ML_trialStart.time(1)) & ([ppositions.time_us] <= trial(trialCX).ML_trialEnd.time(1)));
        dotsPos(trialCX).data = ppositions([idx]);
        dotsPos(trialCX).data = rmfield(dotsPos(trialCX).data, 'num_dots');
    end
    fprintf('Saving...');
    save([filename '/ml_pp_v2.mat'],'dotsPos');
    
%DEBUG    clear a d dr dx dy i lt mpi names num_updates step theta updates w x y unames


    %save([filename '/ml_pp_v1.mat'],'ppositions');
    fprintf(' Done\n');
end



disp(['Point Position reconstruction done! (after ' num2str(toc) ' seconds)'])
disp(['Access point position data using "load ' filename '/ml_pp_v1.mat"'])

% -----------------------------------

toc



end







%% supporting functions

function [xout yout changed] = check_point(xin,yin,dr,theta,center_x,center_y,aperture_radius)

M_PI = 3.14159265358979323846264338327950288;

x1 = xin - center_x;
y1 = yin - center_y;

% im Folgenden die Wiedereintrittsfunktion nach Vera und Philipp Jul/2011
if x1*x1 + y1*y1 > aperture_radius*aperture_radius % wenn der Punkt jetzt ausserhalb des RDPs liegt
    ndr = dr;
    while 1
        %             % // beschreibe ein Dreieck mit den Eckpunkten :
        %             // A:Endpunkt der Punktbewegung (ausserhalb des RDP Kreises)
        %             // B:FieldCenter (ist immer 0,0 in x1 und y1 (siehe oben))
        %             // C:Austrittsstelle des Bewegungsvektors dieses Punktes (unbekannt)
        %             // gesucht wird die Seitenlaenge b (zurueckgelegte Distanz ausserhalb des Kreises) fuer den Wiedereintritt
        %             // bekannt sind: c (Betrag des Vektors vom Mittelpunkt zum Endpunkt) und a (FieldRadius)
        %
        %             // um b zu berechnen brauchen wir noch mindestens einen Winkel, der sich durch den Schnittwinkel des Vektors B->A und 'vorherige Position'->A ergibt.
        %
        alpha = acos( ( x1*(ndr*cos(theta)) + y1*(ndr*sin(theta)) ) / (sqrt(x1*x1 + y1*y1) * sqrt( (ndr*cos(theta))*(ndr*cos(theta)) + (ndr*sin(theta))*(ndr*sin(theta)) ) ) ); % a*b / |a|*|b| = cos(alpha) :: Winkel zwischen zwei Vektoren
        gamma = M_PI - asin((sqrt(x1*x1+y1*y1)*sin(alpha))/aperture_radius); % Sinussatz
        beta = M_PI - alpha - gamma; % Winkelsumme
        
        yk = twister2(-aperture_radius,aperture_radius); % Wiedereintrittspunkt y
        xk = -sqrt(aperture_radius*aperture_radius - yk*yk); % Wiedereintrittspunkt x
        
        x1 = xk * cos(theta) + yk * sin(theta); % Wiedereintrittspunkt x rotiert relativ zur Bewegungsrichtung des Punktes
        y1 = xk * sin(theta) - yk * cos(theta); % Wiedereintrittspunkt y -"-
        
        %debug
        %mwarning(M_IODEVICE_MESSAGE_DOMAIN,"xk:%f yk:%f xkr:%f ykr:%f theta=%f",xk,yk,x1,y1,theta*180/M_PI);
        
        ndr = (aperture_radius * sin(beta))/sin(alpha); % noch zu laufende Distanz nach Wiedereintritt = theoretisch zurueckgelegte Distanz ausserhalb des Kreises
        x1 = x1 + ndr * cos(theta);
        y1 = y1 + ndr * sin(theta);
        
        %debug
        %mwarning(M_IODEVICE_MESSAGE_DOMAIN,"ndr:%f x:%f y:%f",ndr,x1,y1);
        if isa(alpha,'single') disp('alpha is single!'); end
        if isa(gamma,'single') disp('gamma is single!'); end
        if isa(beta,'single') disp('beta is single!'); end
        if isa(yk,'single') disp('yk is single!'); end
        if isa(xk,'single') disp('xk is single!'); end
        if isa(x1,'single') disp('x1 is single!'); end
        if isa(y1,'single') disp('y1 is single!'); end
        if isa(ndr,'single') disp('ndr is single!'); end
        
        if ~(x1*x1 + y1*y1 > aperture_radius*aperture_radius) % wenn der Endpunkt wieder ausserhalb liegt, dann wiederholen
            break
        end
    end
    
    xout = x1 + center_x;
    yout = y1 + center_y;
    changed = 1;
else
    xout = xin;
    yout = yin;
    changed = 0;
end
end


function [xl yl xr yr size] = make_ddots(x,y,r,s,reye_x,reye_y,leye_x,leye_y,eye_distance,display_width)

M_PI = 3.14159265358979323846264338327950288;
alpha = x * M_PI/180.0;
beta = y * M_PI/180.0;
half_disparity = (r/2.0) * M_PI/180.0;

screenx = -reye_x*cos(-alpha-half_disparity) - eye_distance*sin(-alpha-half_disparity);
screenz = reye_x*sin(-alpha-half_disparity) - eye_distance*cos(-alpha-half_disparity);
screeny = -reye_y*cos(beta) - screenz*sin(beta);
screenz = -reye_y*sin(beta) + screenz*cos(beta);

lambda = -eye_distance / screenz;

xl   = (reye_x + lambda*screenx)/2.0 + (display_width/4.0);
if xl < 0
    xl = 0.0;
end
yl  = reye_y + lambda*screeny;

screenx = -leye_x*cos(-alpha+half_disparity) - eye_distance*sin(-alpha+half_disparity);
screenz = leye_x*sin(-alpha+half_disparity) - eye_distance*cos(-alpha+half_disparity);
screeny = -leye_y*cos(beta) - screenz*sin(beta);
screenz = -leye_y*sin(beta) + screenz*cos(beta);

lambda = -eye_distance / screenz;

xr    = (leye_x + lambda*screenx)/2.0 - (display_width/4.0);
if xr > 0
    xr = 0.0;
end
yr = leye_y + lambda*screeny;

half_dot_size = (s/2.0) * M_PI/180.0;
eccentricity = sqrt((alpha*alpha)+(beta*beta));
size = ( ((tan(eccentricity+half_dot_size)*eye_distance) - (tan(eccentricity-half_dot_size)*eye_distance)) / display_width ) / 2.0;
end


function out = twister2(a,b)
out =  a + (b-a) * twister();
end


