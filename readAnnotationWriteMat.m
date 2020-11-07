%Use this code to convert the detection and ground truth annotation from
%.txt file (where each line is : [img_pths obj_labels obj_confs xmin ymin xmax ymax]) to .mat format for further processed by post-processing code.

%class numbers (labels) start from 1


function [obj_labels_cell, obj_confs_cell, obj_bboxes_cell, img_ids, num_imgs, num_of_classes] = readAnnotationWriteMat(pred_file, num_imgs)
    %GT = 0; %if GT annotations, GT = 1, else its detection results
    %num_imgs = 1; %number of images
    %pred_file =
    %'G:/CUImage/VTT_2020/post_processing_code/matlab_code/det/results -
    %Copy.txt'; % file with all the detection results or ground truth
    %annotations
    
    % readAnnotationWriteMat
    % - predict_file: each line is a single predicted object in the
    %   format
    %    <image_id> <ILSVRC2014_DET_ID> <confidence> <xmin> <ymin> <xmax> <ymax>
    % - num_imgs: number of images in the detection or ground truth pred_file (optional), if known then the computation will be fast: to save the ground truth data and avoid

    if nargin > 1        
        obj_labels_cell = cell(1,num_imgs);
        obj_confs_cell = cell(1,num_imgs);
        obj_bboxes_cell = cell(1,num_imgs);
    end
    
    
    %[img_pths obj_labels obj_confs xmin ymin xmax ymax] = textread(pred_file,'%s %d %f %f %f %f %f');
    [obj_labels obj_confs xmin ymin xmax ymax] = textread(pred_file,'%d %f %f %f %f %f');
    
    obj_bboxes = [xmin ymin xmax ymax]';


    idx = 1;
    img_ids = idx;
%     for i=1:size(obj_labels,1)
% 
%         img_ids(i) = idx;
% 
%         if i < size(obj_labels,1)
%             if strcmp(img_pths{i},img_pths{i+1}) == 0
%                 idx = idx + 1;
%             end
%         end
%     end

%     start_i = 1;
%     id = img_ids(1);
%     tic
%     for i=1:length(img_ids)
%         if toc > 60
%             fprintf('               :: on %0.2fM of %0.2fM\n',...
%                     i/10^6,length(img_ids)/10^6);
%             tic
%         end
%         if (i == length(img_ids)) || (img_ids(i+1) ~= id)
%             % i is the last element of this group
%             obj_labels_cell{id} = obj_labels(start_i:i)';
%             obj_confs_cell{id} = obj_confs(start_i:i)';
%             obj_bboxes_cell{id} = obj_bboxes(:,start_i:i);
%             img_paths_cell{id} = img_pths{i};
%             if i < length(img_ids)
%                 % start next group
%                 id = img_ids(i+1);
%                 start_i = i+1;
%             end
%         end
%     end

    [obj_confs, idx] = sort(obj_confs, 'descend');
    obj_labels = obj_labels(idx);
    obj_bboxes = obj_bboxes(:, idx);
    
    obj_labels_cell{1} = obj_labels(1:end)';
    obj_confs_cell{1} = obj_confs(1:end)';
    obj_bboxes_cell{1} = obj_bboxes(:,1:end);

    num_imgs = 1;
    num_of_classes = length(unique(obj_labels));
    
     for l=1:size(obj_labels_cell,2)
         if(obj_labels_cell{l}(1) == 0)
            obj_labels_cell{l} = [];
            obj_confs_cell{l} = [];
            obj_bboxes_cell{l} = [];
         end
     end

end
