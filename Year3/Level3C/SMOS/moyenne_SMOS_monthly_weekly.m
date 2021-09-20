
% unique programme pour créer les weekly et les monthly
% mise a jour 2021
% A+D, A, D


clear
close all;

window0='hebd'  % mens ou hebd
for AD=1:3;           % 2 pour A+D; 1 pour A; 0 pour D
    
    if AD==2
        tabAD=['A' 'D']
        fAB=2;
    elseif AD==1
        tabAD=['A']
        fAB=1;
    else
        tabAD=['D']
        fAB=1;
    end
    
    load('F:\vergely\SMOS\CCI\livrables\CCI_soft_year3\aux_files\maskdmin_ease2.mat')                           %fichier grille distance min cote
    load ('F:\vergely\SMOS\CCI\livrables\CCI_soft_year3\aux_files\latlon_ease.mat')                             %fichier grille ease
    load ('F:\vergely\SMOS\CCI\livrables\CCI_soft_year3\aux_files\ERR_REP\ERR_REP_1d50km_30d50km_mr2_ctm.mat')  %variabilite hebdomadaire
    
    %load('/net/nfs/home/chakroun/CCI_SSS/Level2/aux_files/latlon_ease.mat') %fichier grille
    %load ('/net/nfs/home/chakroun/CCI_SSS/Level2/aux_files/lsc_flag_ease.mat') %fichier flag lsc
    %load ('/net/nfs/tmp15/tmpJLV/packCCI/CCI_soft_year2/aux_files/ERR_REP_50km1d_50km30d_smooth.mat') %variabilite hebdomadaire
    
    nlon=length(lon_ease);
    nlat=length(lat_ease);
    
    input_dir='J:\SSS\data\sat\dataSMOS\CCI_repro2020\Totallycorrected_smos_v3.2\';                 %output directory
    input_dir2='J:\SSS\data\sat\dataSMOS\CCI_repro2020\file_mat_full_corrRR\';                 %output directory
    
    
    %input_dir=('/net/nfs/tmp15/chakroun/L2_output/Level2_intermediate/Totallycorrected_smos/');
    dirL2c=dir(input_dir);
    output_dir=('J:\SSS\data\sat\dataSMOS\CCI_repro2020\Level3_intermediate\');
    if exist(output_dir)==0; mkdir(output_dir); end;
    
    L4_dir=('J:\SSS\CCI\2021\res3\30days\');
    
    %%%%%%%%%%%%%%%%compute and save 1st week%%%%%%%%%%%%%%%
    
    YYYY0=str2num(dirL2c(4).name(7:10));
    MM0=str2num(dirL2c(4).name(11:12));
    jour0=str2num(dirL2c(4).name(13:14));
    n0=datenum(YYYY0,MM0,jour0);
    
    YYYYend=str2num(dirL2c(end).name(7:10));
    MMend=str2num(dirL2c(end).name(11:12));
    jourend=str2num(dirL2c(end).name(13:14));
    nend=datenum(YYYYend,MMend,jourend);
    
    %creer liste de dates 1er et 15 de chaque mois
    if strcmp(window0,'mens')
        avg=15;   % demi-largeur de la fenetre
        cmpt1=1;
        cmpt15=2;
        for yy=1:YYYYend-YYYY0+1
            for MM=1:12
                YY=yy+YYYY0-1;
                ndate(cmpt1)=datenum(YY,MM,1);  % echantillonne sur 15 jours
                ndate(cmpt15)=datenum(YY,MM,15);
                cmpt1=cmpt1+2;
                cmpt15=cmpt15+2;
            end
        end
        nam1='monthly3.2';
    elseif strcmp(window0,'hebd')
        avg=3;
        ndate=n0:1:nend;     % echantillonne sur 1 jour
        nam1='weekly3.2';
    end
    
    output_dir=[output_dir nam1 '\'];
    if exist(output_dir)==0; mkdir(output_dir); end;
    
    ndate=ndate(find((ndate<=nend-avg)&(ndate>=n0+avg)));
    
    for ii=1:length(ndate)% tous les 1er et 15 du mois ou tous les jours
        SSScorrigee=nan(fAB*8*avg,nlon,nlat);
        randomerror=nan(fAB*8*avg,nlon,nlat);
        noutliers_L4_smos=zeros(nlon,nlat);
        bias=nan(fAB*8*avg,nlon,nlat);
        vvc=datevec(ndate(ii));
        yyyc=num2str(vvc(1));
        Date_kk=datestr(ndate(ii)-avg:ndate(ii)+avg,30);%les dates d un mois
        Date_kk=Date_kk(:,1:8);
        cmpt=0;
        
        for uu=1:size(Date_kk,1)
            for orb=tabAD
                fic1=[input_dir 'smos' orb '_' Date_kk(uu,:) '.mat'];
                fic2=[input_dir2 'smos' orb '_' Date_kk(uu,:) '.mat'];
                if exist(fic1)~=0
                    fic1;
                    load(fic1);
                    load(fic2,'WS0','flag_many_outlier','Acard0_mod','Acard0');
                    %filtrage glace, cote
                    nplan=size(SSS_corr,3);
                    
                    II=find((isc_qc==1)|(lsc_qc==1)|(WS0>16)|(abs(Acard0_mod-Acard0)>2)|(flag_many_outlier==1));  % on ne met pas sss_qc car ça filtre trop les fleuves
                    SSS_corr(II)=nan;
                    totalcorrection(II)=nan;
                    SSS_random(II)=nan;
                    for iplan=1:nplan
                        cmpt=cmpt+1;
                        SSScorrigee(cmpt,:,:)=SSS_corr(:,:,iplan);
                        bias(cmpt,:,:)=-totalcorrection(:,:,iplan);
                        randomerror(cmpt,:,:)=SSS_random(:,:,iplan);
                        nn=squeeze(sss_qc_smos(:,:,iplan));
                        ind=find(nn==1);
                        noutliers_L4_smos(ind)=noutliers_L4_smos(ind)+1;
                    end
                end
            end
        end
        SSScorrigee=SSScorrigee(1:cmpt,:,:);
        bias=bias(1:cmpt,:,:);
        randomerror=randomerror(1:cmpt,:,:);
        
        if (cmpt>0)
            %nobs_total
            
            indok=find(SSScorrigee>=0);
            mask=zeros(size(SSScorrigee,1),size(SSScorrigee,2),size(SSScorrigee,3));
            mask(indok)=1;
            nobs_smos=squeeze(sum(mask));
            
            %filtre 3 sigma
            
            %keyboard%dbcont%dbquit
            SSS_moy=squeeze(nanmedian(SSScorrigee));%temps,lon, lat
            SSS_moyenne=nan*ones(size(randomerror));
            
            for kk=1:length(SSS_moyenne(:,1,1))
                SSS_moyenne(kk,:,:)=SSS_moy;
            end
            
            KK=find(abs(SSScorrigee-SSS_moyenne)>3*randomerror);
            
            SSScorrigee(KK)=nan;
            bias(KK)=nan;
            randomerror(KK)=nan;
            
            %noutliers
            indok=find(SSScorrigee>=0 & SSScorrigee<=100);
            mask=zeros(size(SSScorrigee,1),size(SSScorrigee,2),size(SSScorrigee,3));
            mask(indok)=1;
            noutliers_smos=squeeze(sum(mask));
            
            %calcul random error
            ind=find(isnan(SSScorrigee));
            SSScorrigee(ind)=NaN;
            randomerror(ind)=NaN;
            bias(ind)=NaN;
            
            var_int=nansum(1./randomerror.^2,1);   % attention, nansum(NaN)=0
            SSS_smos_random=squeeze(sqrt(1./var_int));
            
            %calcul SSS
            var_int=nansum(SSScorrigee./randomerror.^2,1);
            SSS_smos=squeeze(var_int).*SSS_smos_random.^2;
            
            %calcul biais
            %var_int=[];
            var_int=nansum(bias./randomerror.^2,1);
            %var_int(II)=nan;
            SSS_smos_bias=squeeze(var_int).*SSS_smos_random.^2;
            
            TT=find(abs(SSS_smos_bias)>20 | SSS_smos_random>20);% ajoute le 05/10/2020
            SSS_smos_bias(TT)=nan;% ajoute le 05/10/2020
            SSS_smos(TT)=nan;% ajoute le 05/10/2020
            SSS_smos_random(TT)=nan;% ajoute le 05/10/2020
            
            
            ncentral=ndate(ii);
            Acentral=datestr(ncentral,30);
            Datecentral=Acentral(1:8);
            
            %estimer sss_qc_smos
            
            yyyy=Acentral(1:4);
            mm=Acentral(5:6);
            
            L4_file=([L4_dir yyyc '\ESACCI-SEASURFACESALINITY-L4-SSS-MERGED_OI_Monthly_CENTRED_15Day_25km-',yyyy,mm,'15-fv3.2.nc']);
            nc=netcdf.open(L4_file,'nowrite');
            
            sss_ID=netcdf.inqVarID(nc,'sss');
            sss_ref_L4=double(netcdf.getVar(nc,sss_ID));
            
            ssserror_ID=netcdf.inqVarID(nc,'sss_random_error');
            sss_erreur_L4=double(netcdf.getVar(nc,ssserror_ID));
            
            sss_qc_smos=nan(nlon,nlat);
            sigma=sqrt(SSS_smos_random.^2+sss_erreur_L4.^2);
            
            JJ=find(SSS_smos>0);
            sss_qc_smos(JJ)=0;
            
            II=find(abs(SSS_smos-sss_ref_L4)>3*sigma | isnan(sss_ref_L4) | isnan(sigma) | SSS_smos_random>3);
            sss_qc_smos(II)=1;
            
            ind=find(isnan(SSS_smos));
            nobs_smos(ind)=-1;   % fill value si la SSS n'est pas renseignee
            noutliers_L4_smos(ind)=-1;   % fill value
            sss_qc_smos(ind)=-1;
            
            if AD==2;
                output_file=([output_dir 'smosL3_averaged_',Datecentral,'_centred_C']);
            elseif AD==1
                output_file=([output_dir 'smosL3_averaged_',Datecentral,'_centred_A']);
            else
                output_file=([output_dir 'smosL3_averaged_',Datecentral,'_centred_D']);
            end
            save(output_file,'SSS_smos','SSS_smos_bias','SSS_smos_random','nobs_smos','noutliers_L4_smos','sss_qc_smos')
            netcdf.close(nc)
                        
        end
    end
    
    
    load coast
    
    
    figure(10)
    subplot(2,3,1)
    pcolor(lon_ease,lat_ease,SSS_smos')
    hold on
    plot(long,lat)
    shading flat
    colorbar
    caxis([32 38])
    title('a. SSS')
    
    subplot(2,3,2)
    pcolor(lon_ease,lat_ease,SSS_smos_random')
    shading flat
    hold on
    plot(long,lat)
    colorbar
    caxis([0 0.5])
    title('b. SSS sigma')
    
    II=[];
    II=find(sss_qc_smos==1);
    SSS_smos(II)=nan;
    
    subplot(2,3,3)
    pcolor(lon_ease,lat_ease,SSS_smos')
    hold on
    plot(long,lat)
    shading flat
    colorbar
    caxis([32 38])
    title('c. SSS bias')
    
    subplot(2,3,4)
    pcolor(lon_ease,lat_ease,nobs_smos')
    hold on
    plot(long,lat)
    shading flat
    colorbar
    title('d. SSS count')
    
    subplot(2,3,5)
    pcolor(lon_ease,lat_ease,noutliers_L4_smos')
    hold on
    plot(long,lat)
    shading flat
    colorbar
    title('e. SSS outliers')
    
    subplot(2,3,6)
    pcolor(lon_ease,lat_ease,sss_qc_smos')
    hold on
    plot(long,lat)
    shading flat
    caxis([-2 2])
    colorbar
    title('f. sss QC')
    
end

% sss_qc_smos
