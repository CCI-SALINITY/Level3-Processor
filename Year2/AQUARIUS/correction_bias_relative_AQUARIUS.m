clear all;
close all;

load ('/net/nfs/home/chakroun/CCI_SSS/production_donnees/auxilary/corrbias2020.mat')  %fichier biais a mettre a jour
load('/net/nfs/home/chakroun/CCI_SSS/production_donnees/auxilary/latlon_ease.mat') %fichier grille
load ('/net/nfs/tmp15/tmpJLV/packCCI/CCI_soft_year2/aux_files/ERR_REP_50km1d_50km30d_smooth.mat') %variabilite hebdomadaire
output='/net/nfs/tmp15/chakroun/L3_output/Level3_intermediate/SSS_AQUARIUS_corrected/';%output directory
L4_dir=('/net/nfs/tmp15/tmpJLV/CCI/month_q2/');
input_dir=('/net/nfs/tmp15/tmpJLV/Meriem/aquarius/file_mat/');
dirL2=dir(input_dir);

for ii=3:length(dirL2)
	
	fic=([input_dir,dirL2(ii).name]);
	load(fic);
	yyyy=dirL2(ii).name(7:10);
	mm=dirL2(ii).name(11:12);
	orb=dirL2(ii).name(5);

	tSSS0=tSSS1;

	%on fait correction absolue
	SSS_corrabs=nan*ones(nlon,nlat);
	SSS_corrabs=SSS1-biais_absolu;

	%on fait correction relative
	biais_dwell=[];
	if orb=='A'
        	biais_dwell=biais_relative(:,:,73);
    	else
        	biais_dwell=biais_relative(:,:,74);
    	end

	SST0 = SST1;
	eSSS0 = eSSS1;

	SSS_corr=SSS_corrabs+biais_dwell;

	%estimer correction totale

	totalcorrection=[];
	totalcorrection=biais_dwell-biais_absolu;

	%estimer sss_qc_smos

	L4_file=([L4_dir,'ESACCI-SEASURFACESALINITY-L4-SSS-MERGED_OI_Monthly_CENTRED_15Day_25km-',yyyy,mm,'01-fv03.nc']);
	nc=netcdf.open(L4_file,'nowrite');

	sss_ID=netcdf.inqVarID(nc,'sss');
	sss_ref_L4=double(netcdf.getVar(nc,sss_ID));

	ssserror_ID=netcdf.inqVarID(nc,'sss_random_error');
	sss_erreur_L4=double(netcdf.getVar(nc,ssserror_ID));

	sss_qc_aquarius=zeros(nlon,nlat);
	hebdo=squeeze(errrepres(:,:,str2num(mm)));
	sigma=sqrt(eSSS0.^2+hebdo.^2+sss_erreur_L4.^2);

	II=[];
	II=find(abs(SSS_corr-sss_ref_L4)>3*sigma);

	sss_qc_aquarius(II)=1;

	output_file=([output,'aquariusL3corrected_',dirL2(ii).name(7:end-4),'_',orb])
	save(output_file,'SSS_corr', 'totalcorrection','SST0', 'eSSS0','tSSS0','sss_qc_aquarius');
	netcdf.close(nc)
end
