clear;

for j=1:9
    disp(j);
    cur_model = load_model_edit(j);
    ant_sep = min(cur_model.lambda)/2;
    dist_ant = (-4:5)'*ant_sep;
    ap{1}(:,1) = 5+dist_ant;
    ap{1}(:,2) = 0;

    ap{2}(:,1) = 5+dist_ant;
    ap{2}(:,2) = 8;
    
    ap{3}(:,2) = 4+dist_ant;
    ap{3}(:,1) = 0;

    ap{4}(:,2) = 4+dist_ant;
    ap{4}(:,1) = 10;

    max_x =max(cur_model.walls(:,1));
    max_y =max(cur_model.walls(:,2));

    n_points = 10000;
%     labels_gaussian = zeros(size(labels,1),n_xlabels*n_ylabels);
%     map_X = repmat((1:n_xlabels)'*output_grid_size,1,n_ylabels);
%     map_Y = repmat((1:n_ylabels)*output_grid_size,n_xlabels,1);
    n_lambda=size(cur_model.lambda,2);
    n_ap=4;
    n_ant=length(ap{1});
    channels = zeros(n_points,n_lambda,n_ap,n_ant);

    opt.freq = 3e8./(cur_model.lambda);
    opt.ant_sep = abs(ap{1}(2,1)-ap{1}(1,1));
    labels_discrete = zeros(n_points,2);
    i=0;
    
    parfor i=1:n_points    

        pos = [rand()*max_x,rand()*max_y];
        for l=1:n_ap
            for k=1:n_ant
                channels(i,:,l,k)=get_channels_from_model_edit(cur_model,pos,ap{l}(k,:),false);
                channels(i,:,l,k)=awgn(squeeze(channels(i,:,l,k)),20,0,'db');
            end
        end
        
        labels_discrete(i,:) = pos;
    %         d = (map_X-labels(i,1)).^2+(map_Y-labels(i,2)).^2;
    %         cur_gaussian = exp(-d/output_sigma/output_sigma)*1/sqrt(2*pi)/output_sigma;
    %         labels_gaussian(i,:)=cur_gaussian(:);
        if(mod(i,1000)==0)
            disp(i);
        end 
    end   
    stri = ['datasets/channel20_10_',num2str(j),'.mat'];
    save(stri,'channels','labels_discrete','cur_model','ap','-v7.3');
    clear
end