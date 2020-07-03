clear all;
close all;

avg=7;

load ('/net/nfs/home/chakroun/CCI_SSS/Level2/aux_files/lsc_flag_ease.mat') %fichier flag lsc

input_dir=('/net/nfs/tmp15/chakroun/L2_output/Level2/Totallycorrected/');
dirL2c=dir(input_dir);
output_dir=('/net/nfs/tmp15/chakroun/L3_output/SSS_SMOS/');

input_file=([input_dir,dirL2c.name]);

%%%%%%%%%%%%%%%%compute and save 1st week%%%%%%%%%%%%%%%

YYYY0=str2num(dirL2c(3).name(17:20));
MM0=str2num(dirL2c(3).name(end-9:end-8));
jour0=str2num(dirL2c(3).name(end-7:end-6));
n0=datenum(YYYY0,MM0,jour0);

YYYYend=str2num(dirL2c(end).name(17:20));
MMend=str2num(dirL2c(end).name(end-9:end-8));
jourend=str2num(dirL2c(end).name(end-7:end-6));
nend=datenum(YYYYend,MMend,jourend);

njours=nend-avg+1-n0;

for ii=30:30%toutes les semaines possibles entre t0 et end
	SSScorrigee=nan(7*2,1388,584);
	randomerror=nan(7*2,1388,584);
	bias=nan(7*2,1388,584);
	Date_kk=datestr(n0+ii-1:n0+ii+avg-1,30);%les dates d une semaine	
	cmpt=0;
	for uu=1:7
		list=dir([input_dir,'smosL2corrected_',Date_kk(uu,1:8),'_*.mat']);
		if (length(list)>0)
			for ff=1:length(list)
				SSS_corr=[];
				totalcorrection=[];
				eSSS0=[];
				Dg_Suspect_ice0=[];

				cmpt=cmpt+1;

				input_file=([input_dir,list(ff).name]);	
				load(input_file);

				%filtrage glace, cote

				II=[];
				II=find((Dg_Suspect_ice0>0)|(lsc_flag==1)|(WS0>16)|(abs(Acard_mod-Acard)>2));
				
				SSS_corr(II)=nan;
				totalcorrection(II)=nan;
				eSSS0(II)=nan;

				SSScorrigee(cmpt,:,:)=SSS_corr;
				bias(cmpt,:,:)=-totalcorrection;
				randomerror(cmpt,:,:)=eSSS0;
			end
		end
	end
	%filtre 3 sigma

	%keyboard%dbcont%dbquit
	JJ=[];
	JJ=find(SSScorrigee<1);
	SSScorrigee(JJ)=nan;

	SSS_moy=squeeze(nanmedian(SSScorrigee));%mediane
	SSS_moyenne=nan*ones(size(randomerror));

	for kk=1:length(SSS_moyenne(:,1,1))
		SSS_moyenne(kk,:,:)=SSS_moy;
	end

	KK=[];
	KK=find(abs(SSScorrigee-SSS_moyenne)>3*randomerror);


	SSScorrigee(KK)=nan;
	bias(KK)=nan;	
	randomerror(KK)=nan;	

	%calcul random error
	II=[];
	II=find((SSScorrigee==nan)|(SSScorrigee<30));
	randomerror(II)=nan;
	SSScorrigee(II)=nan;

	randomerror(randomerror==0)=nan;
	var_int=nansum(1./randomerror.^2,1);
	II=[];
	II=find(var_int==0);
	var_int(II)=nan;
	SSS_smos_random=squeeze(sqrt(1./var_int));

	JJ=[];
	JJ=find(SSS_smos_random==nan);

	%calcul SSS

	var_int=[];
	var_int=nansum(SSScorrigee./randomerror.^2,1);
	var_int(JJ)=nan;
	SSS_smos=squeeze(var_int).*SSS_smos_random.^2;
        ind=find(SSScorrigee<1 | randomerror <0.01 | isnan(SSScorrigee) | isnan(randomerror));
SSScorrigee(ind)=NaN;
randomerror(ind)=NaN;


        SSS_smos=squeeze(nansum(SSScorrigee./randomerror.^2,1)./(nansum(1./randomerror.^2,1)));


	%calcul biais

	var_int=[];
	var_int=nansum(bias./randomerror.^2,1);
	var_int(II)=nan;
	SSS_smos_bias=squeeze(var_int).*SSS_smos_random.^2;

	ncentral=(n0+ii+3);
	Acentral=datestr(ncentral,30);
	Datecentral=Acentral(1:8);

	output_file=([output_dir,'smosL3_weeklyaveraged_',Datecentral,'centred']);
	save(output_file,'SSS_smos','SSS_smos_bias','SSS_smos_random') 
end
