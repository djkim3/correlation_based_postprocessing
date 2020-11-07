%The code reads the ground truth annotatinos of training dataset
%(GT_all.mat) to learn the correlation between objects, and then reads the
%detection resutls './out_matFiles/det_all' to remove FPs from detection
%results.

% output is saved as txt file ('./postprocessingResults/det_all_post.txt')

function makeHashRemoveFP(pred_file, hash_table_path)
    %-gt_annotation_file : txt file that contains all the ground truth
    %annotations in [img_pths obj_labels obj_confs xmin ymin xmax ymax]
    %format
    %-pred_file : txt file that contains all the detection results in
    %[img_pths obj_labels obj_confs xmin ymin xmax ymax] format
    %-num_imgs_gt : total number of ground truth images
    %-outfile : output file name with extension .txt
    %-outdir : output folder name
    
    if nargin < 2
        hash_table_path = 'hash_table.mat';
    end
    num_imgs_gt = 1;

    %[gt_labels, ~, gt_bboxes, img_paths, ~, ~, num_of_classes] = readAnnotationWriteMat(hash_table_path, num_imgs_gt);
    [obj_labels, obj_confs, obj_bboxes, ~, ~, ~] = readAnnotationWriteMat(pred_file, num_imgs_gt);

    %num_of_classes = 17;
    
    
    fn = strsplit(pred_file, '.txt');
    outfile1 = [fn{1}  '_sorted.txt'];
    
    outfile2 = [fn{1} '_FPremoved.txt'];
        
   
%     if(0)
%         num_of_imgs = size(gt_labels,2)
%         hash_table = zeros(num_of_classes,num_of_classes);
% 
% 
% 
% 
%         for i=1:num_of_imgs
%             labels = gt_labels{i};
% 
%             if(length(labels)>1)
%                 for j=1:length(labels)-1
%                     for k=j+1:length(labels)
%                         hash_table(labels(j), labels(k)) = hash_table(labels(j), labels(k)) + 1;
%                         hash_table(labels(k), labels(j)) = hash_table(labels(k), labels(j)) + 1;
%                     end
%                 end
%             else
%                 i
%                 labels
%                 hash_table(labels, labels) = hash_table(labels, labels) + 1;
%             end
%         end
% 
%         %save('./out_matFiles/hash_table.mat', 'hash_table');
%     end


    %load('./out_matFiles/hash_table.mat', 'hash_table');
    %load('./out_matFiles/det_all');
    
    
    fp2 = fopen(outfile2,'wt');
     for l=1:size(obj_labels,2)
         new_labels = obj_labels{l};
         new_confs = obj_confs{l};
         new_bboxes = obj_bboxes{l};
         for m = 1:length(new_labels)
            %fprintf(fp2, '%s %d %f %f %f %f %f\n', img_paths{l}, new_labels(m), new_confs(m), new_bboxes(1,m), new_bboxes(2,m),new_bboxes(3,m),new_bboxes(4,m));
            fprintf(fp2, '%d %f %f %f %f %f\n', new_labels(m), new_confs(m), new_bboxes(1,m), new_bboxes(2,m),new_bboxes(3,m),new_bboxes(4,m));
         end
     end
     
     fclose('all');
    
    
    num_of_imgs = length(obj_labels);
    fp1 = fopen(outfile1,'wt');
    
    load(hash_table_path);
    
    % fid_ = fopen(eval_file, 'r');

    % for i=1:num_of_imgs
    %     
    %     confs = obj_confs_cell{i};
    %     labels = obj_labels_cell{i};
    %     bboxes = obj_bboxes_cell{i};    
    %     [confs ind] = sort(confs,'descend');
    %     labels = labels(ind);
    %     bboxes = bboxes(:,ind);
    %     
    %     off_set = ceil((length(A.obj_confs_cell{i})));
    %     
    %      new_obj_labels_cell{i} = labels(1,1:off_set);
    %      new_obj_confs_cell{i} = confs(1,1:off_set);
    %      new_obj_bboxes_cell{i} = bboxes(:,1:off_set);
    % end


    for i=1:num_of_imgs
        a = 1;
        confs = obj_confs{i};
        labels = obj_labels{i};
        bboxes = obj_bboxes{i};    
        [confs ind] = sort(confs,'descend');
        labels = labels(ind);
        bboxes = bboxes(:,ind);

        off_set = 0; %ceil((length(A.obj_confs_cell{i})));

        if(~isempty(confs))
            master_label = labels(1);
        %     master_label2 = labels(2);
            a = 1;
            for j=off_set+1:length(confs)        
                label_this = labels(j);
                conf_this = confs(j);

                        if((hash_table(master_label, label_this) > 1 || hash_table(label_this, master_label) > 1) )
                            new_confs(a) = confs(j);
                            new_labels(a) = labels(j);
                            new_bboxes(:,a) = bboxes(:,j);
                            a = a + 1;
                        elseif((hash_table(master_label, label_this) == 1 || hash_table(label_this, master_label) == 1) && (conf_this < 0.1))
                            new_confs(a) = confs(j);
                            new_labels(a) = labels(j);
                            new_bboxes(:,a) = bboxes(:,j);
                            a = a + 1;
    %                     elseif((hash_table(master_label, label_this) == 0 || hash_table(label_this, master_label) == 0) && (conf_this > 0.7))
    %                         new_confs(a) = confs(j);
    %                         new_labels(a) = labels(j);
    %                         new_bboxes(:,a) = bboxes(:,j);
    %                         a = a + 1;
    %                     elseif((hash_table(master_label, label_this) == 0 || hash_table(label_this, master_label) == 0) && (conf_this < 0.7) && (conf_this > 0))
    %                         new_confs(a) = 0.01;
    %                         new_labels(a) = labels(j);
    %                         new_bboxes(:,a) = bboxes(:,j);
    %                         a = a + 1;
                        end


        %             end
    %                 end
            end

            if(a > 1)
                 obj_labels{i} = new_labels;
                 obj_confs{i} = new_confs;
                 obj_bboxes{i} = new_bboxes;
                 
    %                   obj_labels_cell{i} = [A.obj_labels_cell{i}, new_labels];
    %                   obj_confs_cell{i} = [A.obj_confs_cell{i}, new_confs];
    %                   obj_bboxes_cell{i} = [A.obj_bboxes_cell{i}, new_bboxes];

    %                   obj_labels_cell{i} = [new_obj_labels_cell{i}, new_labels];
    %                   obj_confs_cell{i} = [new_obj_confs_cell{i}, new_confs];
    %                   obj_bboxes_cell{i} = [new_obj_bboxes_cell{i}, new_bboxes];


                clear new_confs new_labels new_bboxes
            else
                1;
            end
    %     else
    %         1;
        end
    end
    
    
     for l=1:size(obj_labels,2)
         new_labels = obj_labels{l};
         new_confs = obj_confs{l};
         new_bboxes = obj_bboxes{l};
         for m = 1:length(new_labels)
            %fprintf(fp1, '%s %d %f %f %f %f %f\n', img_paths{l}, new_labels(m), new_confs(m), new_bboxes(1,m), new_bboxes(2,m),new_bboxes(3,m),new_bboxes(4,m));
            fprintf(fp1, '%d %f %f %f %f %f\n', new_labels(m), new_confs(m), new_bboxes(1,m), new_bboxes(2,m),new_bboxes(3,m),new_bboxes(4,m));
         end
     end
    
    fclose('all');
    
%     if (0)
%         num_pos_per_class = zeros(num_of_classes, 1);
%         num_imgs = size(obj_labels, 2);
% 
%         for i=1:num_imgs
%             labels = gt_labels{i};
%             for j=1:length(labels)
%                 num_pos_per_class(labels(j)) = num_pos_per_class(labels(j)) + 1;
%             end
%         end
% 
% 
% 
%         tp_cell = cell(1,num_imgs);
%         fp_cell = cell(1,num_imgs);
%         gt_thr = 0.5;
%         ov_val = cell(1,num_imgs);
%         for i=1:num_imgs
%             gt_labels_ = gt_labels{i};
%             gt_bboxes_ = gt_bboxes{i};
%             num_gt_obj = length(gt_labels_);
%             gt_detected = zeros(1,num_gt_obj);
% 
%             labels = obj_labels{i};
%             bboxes = obj_bboxes{i};
% 
%             num_obj = length(labels);
%             tp = zeros(1,num_obj);
%             fp = zeros(1,num_obj);
%             ov_val_this = zeros(1,num_obj);
%             for j=1:num_obj
%                 bb = bboxes(:,j);        
%                 ovmax = -inf;
%                 kmax = -1;
%                 %a = 1;
%                 for k=1:num_gt_obj
% 
%                     if labels(j) ~= gt_labels_(k)
%                        continue;
%                     end
%                     if gt_detected(k) > 0
%                         continue;
%                     end
%                     bbgt = gt_bboxes_(:,k);
% 
% 
%                     bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
%                     iw=bi(3)-bi(1)+1;
%                     ih=bi(4)-bi(2)+1;
% 
% 
%                     if iw>0 & ih>0                
%                         % compute overlap as area of intersection / area of union
%                         ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
%                            (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
%                            iw*ih;
%                         ov=iw*ih/ua;
% 
%                         % makes sure that this object is detected according
%                         % to its individual threshold
%                         if ov >= gt_thr && ov > ovmax
%                             ovmax=ov;
%                             kmax=k;                    
%                         end
%                     end
%                 end
%                 if kmax > 0
%                     tp(j) = 1;
%                     gt_detected(kmax) = 1;
%                     ov_val_this(j) = ovmax;
%                 else
%                     fp(j) = 1;
%                 end
%             end
% 
%             % put back into global vector
%             tp_cell{i} = tp;
%             fp_cell{i} = fp;
% 
%             for k=1:num_gt_obj
%                 label = gt_labels_(k);
%             end
%         ov_val{i} = ov_val_this;
%         end
% 
% 
%         fprintf('eval_detection :: computing ap\n');
%         tp_all = [tp_cell{:}];
%         fp_all = [fp_cell{:}];
%         obj_labels = [obj_labels{:}];
%         confs = [obj_confs{:}];
% 
%         [confs ind] = sort(confs,'descend');
%         tp_all = tp_all(ind);
%         fp_all = fp_all(ind);
%         obj_labels = obj_labels(ind);
%         for c=1:num_of_classes
%             % compute precision/recall
%             tp = cumsum(tp_all(obj_labels==c));
%             fp = cumsum(fp_all(obj_labels==c));
%             recall{c}=(tp/num_pos_per_class(c))';
%             precision{c}=(tp./(fp+tp))';
%             ap(c) =VOCap(recall{c},precision{c});
%         %     figure; plot(recall{c}, precision{c})
%         %     title(['Class : ' synsets(c).name ',  AP : ' num2str(ap(c))])
%         %     xlabel('Recall')
%         %     ylabel('Precision')
%         %     axis([0 1 0 1])
%         %     saveas(gcf,[out_dir2 synsets(c).name '_4.png'])
%         %     close all
%         %  save([out_dir2 synsets(c).name '_stats_fusion_ACC_BN.mat'],'tp', 'fp');
%         end
% 
%         mean([ap(1:2) ap(4:end)])
%     end
end