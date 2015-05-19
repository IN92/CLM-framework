% Working out corrections for head pose and model correlations
clear
%%
% first need to run run_clm_head_pose_tests_clnf
if(exist([getenv('USERPROFILE') '/Dropbox/AAM/test data/'], 'file'))
    database_root = [getenv('USERPROFILE') '/Dropbox/AAM/test data/'];    
else
    database_root = 'F:/Dropbox/Dropbox/AAM/test data/';
end
buDir = [database_root, '/bu/uniform-light/'];
resFolderBUccnf_general = [database_root, '/bu/uniform-light/CLMr3/'];
[~, pred_hp_bu, gt_hp_bu, ~, rels_bu] = calcBUerror(resFolderBUccnf_general, buDir);

biwi_dir = '/biwi pose/';
biwi_results_root = '/biwi pose results/';
res_folder_ccnf_general = '/biwi pose results//CLMr4/';
[~, pred_hp_biwi, gt_hp_biwi, ~, ~, rels_biwi] = calcBiwiError([database_root res_folder_ccnf_general], [database_root biwi_dir]);

ict_dir = ['ict/'];
ict_results_root = ['ict results/'];
res_folder_ict_ccnf_general = 'ict results//CLMr4/';
[~, pred_hp_ict, gt_hp_ict, ~, ~, rel_ict] = calcIctError([database_root res_folder_ict_ccnf_general], [database_root ict_dir]);

all_hps = cat(1, pred_hp_bu, pred_hp_biwi, pred_hp_ict);
all_gts = cat(1, gt_hp_bu, gt_hp_biwi, gt_hp_ict);
all_rels = cat(1, rels_bu, rels_biwi, rel_ict);

rel_cutoff = 0.8;

rel_frames = all_rels > rel_cutoff;
fprintf('Proportion of reliable frames: %.2f\n', sum(rel_frames)/numel(rel_frames));

err_bu = abs(pred_hp_bu(rels_bu > rel_cutoff,:) - gt_hp_bu(rels_bu > rel_cutoff,:));
err_biwi = abs(pred_hp_biwi(rels_biwi > rel_cutoff,:) - gt_hp_biwi(rels_biwi > rel_cutoff,:));
err_ict = abs(pred_hp_ict(rel_ict > rel_cutoff,:) - gt_hp_ict(rel_ict > rel_cutoff,:));

all_err = mean(abs(all_gts - all_hps), 2);

all_gts_rel = all_gts(rel_frames,:);
all_hps_rel = all_hps(rel_frames,:);

%% Pitch 1D errors
pitch_ids = abs(all_gts_rel(:,2)) < 4 & abs(all_gts_rel(:,3)) < 4;
pitch_errs = abs(all_gts_rel(pitch_ids,1) - all_hps_rel(pitch_ids,1));

yaw_ids = abs(all_gts_rel(:,1)) < 4 & abs(all_gts_rel(:,3)) < 4;
yaw_errs = abs(all_gts_rel(yaw_ids,1) - all_hps_rel(yaw_ids,1));

roll_ids = abs(all_gts_rel(:,1)) < 4 & abs(all_gts_rel(:,2)) < 4;
roll_errs = abs(all_gts_rel(roll_ids,1) - all_hps_rel(roll_ids,1));

pitch_bins  = [0, 5, 10, 15, 20, 30, 40, 50];
err_pitch = zeros(size(pitch_bins));
std_pitch = zeros(size(pitch_bins));

pitch_bin = bsxfun(@plus, abs(all_gts_rel(pitch_ids,1)), -pitch_bins);
[~, ids] = min(abs(pitch_bin'));
ids = ids';

for i=1:numel(pitch_bins)
    rel_bins = ids == i;
    err_pitch(i) = mean(pitch_errs(rel_bins));
    std_pitch(i) = std(pitch_errs(rel_bins));
end
errorbar(pitch_bins, err_pitch, std_pitch);