clear all;
close all;

avg=14;

input_dir=('/net/nfs/tmp15/chakroun/L2_output/Level2/Totallycorrected/');
dirL2c=dir(input_dir);
output_dir=('/net/nfs/tmp15/chakroun/L3_output/SSS_SMOS/');

input_file=([input_dir,dirL2c.name]);
jour1=dirL2c(3).name(end-7:end-6);

for kk=3:3+avg-1
	input_file=([input_dir,dirL2c(kk).name]);
	load(input_file);
	SSScorrigee(kk-2,:,:)=SSS_corr;
	bias(kk-2,:,:)=-totalcorrection;
	randomerror(kk-2,:,:)=eSSS0;
end

%calcul random error

randomerror(randomerror==0)=nan;
var_int=nansum(1./randomerror.^2,1);
II=[];
II=find(var_int==0);
var_int(II)=nan;
SSS_smos_random=squeeze(sqrt(1./var_int));

%calcul SSS

var_int=[];
var_int=nansum(SSScorrigee./randomerror.^2,1);
var_int(II)=nan;
SSS_smos=squeeze(var_int).*SSS_smos_random.^2;

%calcul biais

var_int=[];
var_int=nansum(bias./randomerror.^2,1);
var_int(II)=nan;
SSS_smos_bias=squeeze(var_int).*SSS_smos_random.^2;

output_file=[output_dir,'smosL3averaged_',dirL2c(kk-floor(avg/2)).name(17:end-6)];
save(output_file,'SSS_smos','SSS_smos_bias','SSS_smos_random') 

stop

for ii=4:length(dirL2C)-avg

	SSS_smos=[];
	SSS_smos_random=[];
	SSS_smos_bias=[];

	kk=ii+avg;

	input_file=([input_dir,dirL2c(kk).name]);
	load(input_file);

	SSScorrigee(1,:,:)=SSS_corr;
	bias(1,:,:)=-totalcorrection;
	randomerror(1,:,:)=eSSS0;

	SSS_smos_random=sqrt(1./nansum(randomerror.^2),1);
	SSS_smos=nansum((SSScorrigee./(randomerror.^2)),1)./SSS_smos_random;
	SSS_smos_bias=nansum((SSScorrigee./(randomerror.^2)),1)./SSS_smos_random;

	output_file=[output,'smosL3averaged_',dirL2(kk-floor(avg/2)).name(9:end-4)];
	save(output_file,'SSS_smos','SSSbias','SSSrandom') 
end
