function EYEdata = MW_eyeCreate(figHandle)
EYEdata = struct('endOfExperiment', 0, 'eye_dwl', [], 'Pupil_Right', [], 'Pupil_Left', [], 'Eye_X', [], ...
        'Eye_Y', [], 'slope', 0, 'goodnessOfFit', 0, 'calculated', false, 'figHandle', figHandle);
end