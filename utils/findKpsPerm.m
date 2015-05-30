function kpsPerm = findKpsPerm(part_names)
leftInds = cellfun(@(x) ~isempty(x),strfind(part_names,'Left'));
leftInds = leftInds | cellfun(@(x) ~isempty(x),strfind(part_names,'L_'));
leftInds = leftInds | cellfun(@(x) ~isempty(x),strfind(part_names,'left'));

rightInds = cellfun(@(x) ~isempty(x),strfind(part_names,'Right'));
rightInds = rightInds | cellfun(@(x) ~isempty(x),strfind(part_names,'R_'));
rightInds = rightInds | cellfun(@(x) ~isempty(x),strfind(part_names,'right'));

flipNames = part_names;
flipNames(leftInds) = strrep(flipNames(leftInds),'L_','R_');
flipNames(leftInds) = strrep(flipNames(leftInds),'Left','Right');
flipNames(leftInds) = strrep(flipNames(leftInds),'left','right');

flipNames(rightInds) = strrep(flipNames(rightInds),'R_','L_');
flipNames(rightInds) = strrep(flipNames(rightInds),'Right','Left');
flipNames(rightInds) = strrep(flipNames(rightInds),'right','left');

kpsPerm = zeros(length(flipNames),1);
for i=1:length(flipNames)
    kpsPerm(i) = find(ismember(part_names,flipNames{i}));
end

end

