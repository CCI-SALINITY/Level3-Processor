clear all;
close all;

avg=7;

input_dir=('/net/nfs/tmp15/chakroun/L2_output/Level2/Totallycorrected/');
dirL2c=dir(input_dir);
output_dir=('/net/nfs/tmp15/chakroun/L3_output/SSS_SMOS/');

input_file=([input_dir,dirL2c.name]);

%%%%%%%%%%%%%%%%compute and save 1st week%%%%%%%%%%%%%%%

YYYY0=str2num(dirL2c(3).name(17:20));
MM0=str2num(dirL2c(3).name(end-9:end-8));
jour0=str2num(dirL2c(3).name(end-7:end-6));
n0=datenum(YYYY0,MM0,jour0);

nend=n0+avg-1;
Aend=datestr(nend,30);
Dateend=Aend(1:8);

ncentral=(n0+nend)/2;
Acentral=datestr(ncentral,30);
Datecentral=Acentral(1:8);

for kk=3:3+2*avg-1
	YYYY=str2num(dirL2c(kk).name(17:20));
	MM=str2num(dirL2c(kk).name(end-9:end-8));
	jour=str2num(dirL2c(kk).name(end-7:end-6));
	nkk=datenum(YYYY,MM,jour);

	if (nkk>=n1)&(nkk<=nend)
		input_file=([input_dir,dirL2c(kk).name]);		
		load(input_file);
		SSScorrigee(kk-2,:,:)=SSS_corr;
		bias(kk-2,:,:)=-totalcorrection;
		randomerror(kk-2,:,:)=eSSS0;
 	end
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

output_file=([output_dir,'smosL3_weeklyaveraged_',Datecentral,'centred']);
save(output_file,'SSS_smos','SSS_smos_bias','SSS_smos_random') 

stop 

%%%%%%%%%%%%%%%%%%compute remaining weeks%%%%%%%%%%%%%%%%%%

for ii=1:length(dirL2C)-2*avg+1

	n1=n0+ii;
	A1=datestr(n1,30);
	Date1=A1(1:8);

	nendi=n1+avg-1;
	Ai=datestr(n1,30);
	Datei=Ai(1:8);

	if (nendi>=n1)&(nkk<=nend)
		input_file=([input_dir,dirL2c(kk).name]);		
		load(input_file);
		SSScorrigee(kk-2,:,:)=SSS_corr;
		bias(kk-2,:,:)=-totalcorrection;
		randomerror(kk-2,:,:)=eSSS0;
 	end
	%tenir compte des fichiers manquants: centrer sur le bon jour, ouvrir le bon fichier
	%pour faire propre, faut ouvrir a nouveau les 7 fichiers 

	ficlist=dir([input_dir,'smosL2corrected_',Datei,_,'*.mat']);
	if length(ficlist)>0
		for kk=1:length(ficlist)

			SSS_smos=[];
			SSS_smos_random=[];
			SSS_smos_bias=[];

			input_file=([input_dir,dirL2c(kk).name]);
			load(input_file);

			SSScorrigee(1,:,:)=SSS_corr;
			bias(1,:,:)=-totalcorrection;
			randomerror(1,:,:)=eSSS0;
		end
	end

	SSS_smos_random=sqrt(1./nansum(randomerror.^2),1);
	SSS_smos=nansum((SSScorrigee./(randomerror.^2)),1)./SSS_smos_random;
	SSS_smos_bias=nansum((SSScorrigee./(randomerror.^2)),1)./SSS_smos_random;

	output_file=[output,'smosL3averaged_',dirL2(kk-floor(avg/2)).name(9:end-4)];
	save(output_file,'SSS_smos','SSSbias','SSSrandom') 
end


