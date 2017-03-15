% FILE ID INFO
ess_description='MagCap DCDC converter';
disp(['Data loaded: MagCap DCDC converter'])
% DCDC converter parameters
MC_Imax = 12; %A, maximum current either direction

rawcsv = csvread('../dcdc/MagCap_eff_data.csv');
Pin_col = rawcsv(:,1);
Vin_col = rawcsv(:,2);
Vout_col = rawcsv(:,3);
eff_col = rawcsv(:,4);
MC_max_eff = max(max(max(eff_col)))/100;

%% put into meshgrid format and interpolate/refine eff1(Pin,Vin,Vout)
col_length = size(rawcsv,1);
Pins = unique(Pin_col);
Vins = unique(Vin_col);
Vouts = unique(Vout_col);
[Xq,Yq,Zq] = meshgrid(Pins,Vins,Vouts);
Vq1 = Xq*0;
for i=1:1:col_length
    index_Xq = find(not(Pins-Pin_col(i)).*(1:1:size(Pins))');
    index_Yq = find(not(Vins-Vin_col(i)).*(1:1:size(Vins))');
    index_Zq = find(not(Vouts-Vout_col(i)).*(1:1:size(Vouts))');
    Vq1(index_Xq,index_Yq,index_Zq) = eff_col(i);
end
MC_Pins = min(Pins):((max(Pins)-min(Pins))/10):max(Pins);
MC_Vins = min(Vins):((max(Vins)-min(Vins))/10):max(Vins);
MC_Vouts = min(Vouts):((max(Vouts)-min(Vouts))/10):max(Vouts);
[Xq_refined,Yq_refined,Zq_refined] = meshgrid(MC_Pins, MC_Vins, MC_Vouts);
MC_eff1 = interp3(Xq,Yq,Zq,Vq1,Xq_refined,Yq_refined,Zq_refined,'spline')/100;
    %where Xq->Pin, Yq->Vin, Zq->Vout, Vq1->eff

%% re-format to: eff2(Pout,Vin,Vout)
Pout_col = Pin_col.*eff_col/100;
for Vin_index=1:1:size(Vins,1)
    for Vout_index=1:1:size(Vouts,1)
        indices = (Vin_col==Vins(Vin_index)) .* (Vout_col==Vouts(Vout_index));
        indices = find(indices .* (1:1:col_length)');
        Pin_col_small = Pin_col(indices);
        Pout_col_small = Pout_col(indices);
        p=polyfit(Pout_col_small,Pin_col_small,2);
        Pout_col_small_new = Pin_col_small;
        Pin_col_small_new = polyval(p,Pout_col_small_new);
        Pin_col(indices) = Pin_col_small_new;
        Pout_col(indices) = Pout_col_small_new;
    end
end
Pouts = unique(Pout_col);
eff_col = Pout_col./Pin_col;

%% put into meshgrid format and interpolate/refine eff2(Pout,Vin,Vout)
[Xq,Yq,Zq] = meshgrid(Pouts,Vins,Vouts);
Vq2 = Xq*0;
for i=1:1:col_length
    index_Xq = find(not(Pouts-Pout_col(i)).*(1:1:size(Pouts))');
    index_Yq = find(not(Vins-Vin_col(i)).*(1:1:size(Vins))');
    index_Zq = find(not(Vouts-Vout_col(i)).*(1:1:size(Vouts))');
    Vq2(index_Xq,index_Yq,index_Zq) = eff_col(i);
end
MC_Pouts = min(Pouts):((max(Pouts)-min(Pouts))/10):max(Pouts);
[Xq_refined,Yq_refined,Zq_refined] = meshgrid(MC_Pouts, MC_Vins, MC_Vouts);
MC_eff2 = interp3(Xq,Yq,Zq,Vq2,Xq_refined,Yq_refined,Zq_refined,'spline');
    %where Xq->Pout, Yq->Vin, Zq->Vout, Vq2->eff

% slice(MC_Pouts,MC_Vins,MC_Vouts,MC_eff2,70,22,21)
% colorbar


clear col_length eff_col i index_Xq index_Yq index_Zq indices p Pins... 
    Pin_col Pin_col_small Pin_col_small_new Pout_col Pout_col_small ... 
    Pout_col_small_new rawcsv Vin_col Vin_index Vin_mg Vout_col ... 
    Vout_index Vq1 Vq1_refined Vq2 Vq2_refined Xq Xq_refined Yq ... 
    Yq_refined Zq Zq_refined Pouts Vins Vouts