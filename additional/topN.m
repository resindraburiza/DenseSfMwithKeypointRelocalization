function topN(matches_path,imgs,top)

N = length(imgs);
matchesMatrix = zeros(N,N);
dirgen([matches_path 'processed/'])

for i=1:N-1
    [head1,tail1] = str_cut(imgs{i},'.');
    flcnn_matchfn = fullfile(matches_path,[head1 '.match.mat']);
    match_data = load(flcnn_matchfn);
    numberofInlierData = zeros(1,N);
    for ii=1:length(match_data.inliers)
        numberofInlierData(ii) = size(match_data.inliers{ii},2);
    end
    matchesMatrix(i,:) = numberofInlierData;
end
matchesMatrix = triu(matchesMatrix) + triu(matchesMatrix,1)';

for i=1:N-1
    [head1,tail1] = str_cut(imgs{i},'.');
    flcnn_matchfn = fullfile(matches_path,[head1 '.match.mat']);
    
    match_data = load(flcnn_matchfn);
    matches = cell(1,N);
    inliers = cell(1,N);
    [sorted,index]=sort(matchesMatrix(i,:),'descend');
    for ii = index(1:top)
        matches{ii} = match_data.matches{ii};
        inliers{ii} = match_data.inliers{ii};
    end
    flcnn_matchfn_save = fullfile([matches_path 'processed/'],[head1 '.match.mat']);
    save('-v6',flcnn_matchfn_save,'matches','inliers');
end
