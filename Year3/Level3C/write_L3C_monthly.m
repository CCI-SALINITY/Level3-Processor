% A, D, ou A+D. implementation year3, ACRI-ST


clear
close all;

window0='hebd'

if strcmp(window0,'hebd')==1
    nammat='weekly';
else
    nammat='monthly';
end

for orb=['A'];    % A = asc, D=desc , C=A+D
    
    if orb=='A'
        namf='_A';
    elseif orb=='D'
        namf='_D';
    elseif orb=='C'
        namf='';
    end
    
    fileversion='3.2';
    fillvalu=-1;
    days19700101=datenum(1970,1,1,0,0,0);
    
    load('F:\vergely\SMOS\CCI\livrables\CCI_soft_year3\aux_files\maskdmin_ease2.mat')                           %fichier grille distance min cote
    load ('F:\vergely\SMOS\CCI\livrables\CCI_soft_year3\aux_files\latlon_ease.mat')                             %fichier grille ease
    %load('mask_smos.mat')
    
    nlon=length(lon_ease);
    nlat=length(lat_ease);
    
    %chemin des input (produits corriges latitudinalement et de la SST)
    
    input_dir_smos=['J:\SSS\data\sat\dataSMOS\CCI_repro2020\Level3_intermediate\' nammat '3.2\'];%input directory
    dirL3_smos=dir(input_dir_smos);
    input_dir_smap=['J:\SSS\data\sat\SMAP_data\CCI_repro2020\Level3_intermediate\' nammat '3.2\'];%input directory
    dirL3_smap=dir(input_dir_smap);
    input_dir_aquarius=['J:\SSS\data\sat\Aquarius_data\CCI_repro2020\Level3_intermediate\' nammat '3.2\'];%input directory
    dirL3_aquarius=dir(input_dir_aquarius);
    
    %chemin output
    
    output_dir=['J:\SSS\CCI\2021\productL3_v' fileversion '\' nammat  namf  '\'];%output directory
    
    if exist(output_dir)==0; mkdir(output_dir); end;
    
    %on cree toutes les dates qu'on va parcourir
    
    YYYY0=str2num(dirL3_smos(4).name(end-21:end-18));
    MM0=str2num(dirL3_smos(4).name(end-17:end-16));
    jour0=str2num(dirL3_smos(4).name(end-15:end-14));
    n0=datenum(YYYY0,MM0,jour0);
    
    YYYYend=str2num(dirL3_smos(end).name(end-21:end-18));
    MMend=str2num(dirL3_smos(end).name(end-17:end-16));
    jourend=str2num(dirL3_smos(end).name(end-15:end-14));
    nend=datenum(YYYYend,MMend,jourend);
    
    njours=nend-n0;
    
    if strcmp(window0,'mens')==1   % produits mensuels : 1 produit tous les 15 jours
        cmpt1=1;
        cmpt15=2;
        for yy=1:YYYYend-YYYY0+1
            for MM=1:12
                YY=yy+YYYY0-1;
                
                ndate(cmpt1)=datenum(YY,MM,1);
                ndate(cmpt15)=datenum(YY,MM,15);
                
                cmpt1=cmpt1+2;
                cmpt15=cmpt15+2;
            end
        end
    else  % produits weekly : 1 produit par jour
        cmpt1=0;
        for ii=3:length(dirL3_smos)  % SMOS couvre toute la période
           cmpt1=cmpt1+1;  
           ddc=dirL3_smos(ii).name(17:24);
           ndate(cmpt1)=datenum(str2num(ddc(1:4)),str2num(ddc(5:6)),str2num(ddc(7:8)),0,0,0);
        end
        ndate=unique(ndate);
    end
    
    for kk=2:length(ndate)
        
        dates=datestr(ndate(kk),30);
        date_file=dates(1:8);
        
        %initialisation
        SSS_smos=nan(nlon,nlat);
        SSS_smap=nan(nlon,nlat);
        SSS_aquarius=nan(nlon,nlat);
        
        SSS_smos_bias=nan(nlon,nlat);
        SSS_smap_bias=nan(nlon,nlat);
        SSS_aquarius_bias=nan(nlon,nlat);
        
        SSS_smos_random=nan(nlon,nlat);
        SSS_smap_random=nan(nlon,nlat);
        SSS_aquarius_random=nan(nlon,nlat);
        
        sss_qc_smos=fillvalu*ones(nlon,nlat);
        sss_qc_smap=fillvalu*ones(nlon,nlat);
        sss_qc_aquarius=fillvalu*ones(nlon,nlat);
        
        nobs_smos=fillvalu*ones(nlon,nlat);
        nobs_smap=fillvalu*ones(nlon,nlat);
        nobs_aquarius=fillvalu*ones(nlon,nlat);
        
        noutliers_L4_smos=fillvalu*ones(nlon,nlat);
        noutliers_L4_smap=fillvalu*ones(nlon,nlat);
        noutliers_L4_aquarius=fillvalu*ones(nlon,nlat);
        
        %lecture des donnees
        
        input_smos_file=([input_dir_smos,'smosL3_averaged_',date_file,'_centred_' orb '.mat']);
        input_smap_file=([input_dir_smap,'smapL3_averaged_',date_file,'_centred_' orb '.mat']);
        input_aquarius_file=([input_dir_aquarius,'aquariusL3_averaged_',date_file,'_centred_' orb '.mat']);
        
        if exist(input_smos_file)
            load(input_smos_file);
        end
        if exist(input_smap_file)
            load(input_smap_file);
        end
        if exist(input_aquarius_file)
            load(input_aquarius_file);
        end
        
        %time definition
        
        date_start=datestr(ndate(kk)-15,30);
        date_end=datestr(ndate(kk)+15,30);
        
        YYYYtime=str2num(date_file(1:4));
        MMtime=str2num(date_file(5:6));
        JJtime=str2num(date_file(7:8));
        date_time=datenum(YYYYtime,MMtime,JJtime,0,0,0);
                
        %%%%%%%%%%%%%%%%%%%%
        
        KK=find(isnan(SSS_smos));
        sss_qc_smos(KK)=fillvalu;
        nobs_smos(KK)=fillvalu;
        noutliers_L4_smos(KK)=fillvalu;
        
        KK=find(isnan(SSS_smap));
        sss_qc_smap(KK)=fillvalu;
        nobs_smap(KK)=fillvalu;
        noutliers_L4_smap(KK)=fillvalu;
        
        KK=find(isnan(SSS_aquarius));
        sss_qc_aquarius(KK)=fillvalu;
        nobs_aquarius(KK)=fillvalu;
        noutliers_L4_aquarius(KK)=fillvalu;
        
        %ecriture des donnees
        
        if strcmp(window0,'hebd')   % year3
            L3P_ncfile=([output_dir,'ESACCI-SEASURFACESALINITY-L3C-SSS-SMOSSMAPAQUARIUS_7Day_runningmean_Daily_25km-',date_file,'-fv',fileversion,'.nc'])%output file
        else
            L3P_ncfile=([output_dir,'ESACCI-SEASURFACESALINITY-L3C-SSS-SMOSSMAPAQUARIUS' namf '_Monthly_Centred_15Day_25km-',date_file,'-fv',fileversion,'.nc']) %output file
        end
        
        delete(L3P_ncfile)
        nc=netcdf.create(L3P_ncfile,'netcdf4');
        
        %%%%%%%%%%%%%%%%%%%%%%%
        %dimensions
        
        dimidX = netcdf.defDim(nc,'time',1);
        dimidY = netcdf.defDim(nc,'lat',length(lat_ease));
        dimidZ = netcdf.defDim(nc,'lon',length(lon_ease));
        %%time  mettre a jour
        
        %%global attributes
        
        NC_GLOBAL = netcdf.getConstant('NC_GLOBAL');
        
        netcdf.putAtt(nc,NC_GLOBAL,'creation_time',datestr(now));
        
        Value= 'ACRI-ST; LOCEAN' ;
        netcdf.putAtt(nc,NC_GLOBAL,'institution',Value);
        
        Value =  'CF-1.8';   % year3 passage de la 1.7 a la 1.8
        netcdf.putAtt(nc,NC_GLOBAL,'Conventions',Value);
        
        Value =  'Ocean, Ocean Salinity, Sea Surface Salinity, Satellite';
        netcdf.putAtt(nc,NC_GLOBAL,'keywords',Value);
        
        Value =  'European Space Agency - ESA Climate Office';
        netcdf.putAtt(nc,NC_GLOBAL,'naming_authority',Value);
        
        Value =  'NASA Global Change Master Directory (GCMD) SCience Keywords';
        netcdf.putAtt(nc,NC_GLOBAL,'keywords_vocabulary',Value);
        
        Value =  'Grid';
        netcdf.putAtt(nc,NC_GLOBAL,'cdm_data_type',Value);
        
        Value= 'ACRI-ST; LOCEAN';
        netcdf.putAtt(nc,NC_GLOBAL,'creator_name',Value);
        
        Value= 'http://cci.esa.int/salinity';
        netcdf.putAtt(nc,NC_GLOBAL,'creator_url',Value);
        
        Value= 'Climate Change Initiative - European Space Agency';
        netcdf.putAtt(nc,NC_GLOBAL,'project',Value);
        
        Value= 'ESA CCI Data Policy: free and open access';%tocheck
        netcdf.putAtt(nc,NC_GLOBAL,'license',Value);
        
        Value= 'NetCDF Climate and Forecast (CF) Metadata Convention version 1.8';  % year3 passage de la 1.7 a la 1.8
        netcdf.putAtt(nc,NC_GLOBAL,'standard_name_vocabulary',Value);
        
        Value= 'PROTEUS,SAC-D,SMAP';  % year3
        netcdf.putAtt(nc,NC_GLOBAL,'platform',Value);
        
        Value= 'SMOS/MIRAS,Aquarius,SMAP';  % year3
        netcdf.putAtt(nc,NC_GLOBAL,'sensor',Value);
        
        Value= '50km';
        netcdf.putAtt(nc,NC_GLOBAL,'spatial_resolution',Value);
        
        Value= 'degrees_north';
        netcdf.putAtt(nc,NC_GLOBAL,'geospatial_lat_units',Value);
        
        Value= 'degrees_east';
        netcdf.putAtt(nc,NC_GLOBAL,'geospatial_lon_units',Value);
        
        Value= ' ';
        netcdf.putAtt(nc,NC_GLOBAL,'date_modified',Value);
        
        UUID = java.util.UUID.randomUUID;
        Value= char(UUID);
        netcdf.putAtt(nc,NC_GLOBAL,'tracking_id',Value);
        
        Value= 'jean-luc.vergely@acri-st.fr';%tocheck
        netcdf.putAtt(nc,NC_GLOBAL,'creator_email',Value);
        
        if strcmp(window0,'hebd')   % year2
            Value= 'P7D';
        else
            Value= 'P1M';
        end
        netcdf.putAtt(nc,NC_GLOBAL,'time_coverage_duration',Value);
        
        Value= lat_ease(1);  % year3 type ?
        netcdf.putAtt(nc,NC_GLOBAL,'geospatial_lat_min',Value);
        
        Value= lat_ease(end);  % year3 type ?
        netcdf.putAtt(nc,NC_GLOBAL,'geospatial_lat_max',Value);
        
        Value= lon_ease(1);  % year3 type ?
        netcdf.putAtt(nc,NC_GLOBAL,'geospatial_lon_min',Value);
        
        Value= lon_ease(end);  % year3 type ?
        netcdf.putAtt(nc,NC_GLOBAL,'geospatial_lon_max',Value);
        
        Value= datestr(now,30);
        netcdf.putAtt(nc,NC_GLOBAL,'date_created',Value);
        
        Value= [date_start 'Z'];;
        netcdf.putAtt(nc,NC_GLOBAL,'time_coverage_start',Value);
        
        if strcmp(window0,'mens')
            Value= 'ESA CCI Sea Surface Salinity ECV Product - Monthly Sea Surface Salinity L3 data from SMOS, SMAP and Aquarius';
        else
            Value= 'ESA CCI Sea Surface Salinity ECV Product - Weekly Sea Surface Salinity L3 data from SMOS, SMAP and Aquarius';
        end
        
        netcdf.putAtt(nc,NC_GLOBAL,'title',Value)
        
        % Value= ['SMOS ESAL2OSv622/CATDS RE05, SMAP L2Cv4/RSS, Aquarius L3 v5.0'];%tocheck
        Value= ['SMOS CCI v3 L2OS reprocessing (ERA5,ref OTT SSS:ISAS, RFI filtering) from DPGS L1 v620, L2OS v662 modified as in DOI:10.1109/tgrs.2020.3030488, SMAP L2 RSS v4.0 - DOI:10.5067/SMP40-2SOCS, Aquarius L3 v5.0 - DOI:10.5067/AQR50-3SQCS'];   % year3 DOI SMAP complete
        netcdf.putAtt(nc,NC_GLOBAL,'source',Value);
        
        Value= 'http://cci.esa.int/salinity - DOI:XXXXX';
        netcdf.putAtt(nc,NC_GLOBAL,'references',Value);
        
        
        Value=['This version of L3 CCI+SSS products is a preliminary version. ', ...     % year3 correction
            'This product has not been fully validated yet ', ...
            'and may contain flaws. In case you discover some, we ',...
            '(Mngt_CCI-Salinity@argans.co.uk) are very keen to get your feedback. ',...
            'In case you would like to use them in a presentation or publication, ',...
            'please contact us to get their correct reference (doi attribution in progress)'];
        netcdf.putAtt(nc,NC_GLOBAL,'comment',Value);
        
        [path,fname,extension]=fileparts(L3P_ncfile);
        Value= [fname extension];
        netcdf.putAtt(nc,NC_GLOBAL,'id',Value);
        
        if strcmp(window0,'hebd')   % year3
            Value= 'P1D';  % year3 correction
        else
            Value= 'P15D';  % year3 correction
        end
        netcdf.putAtt(nc,NC_GLOBAL,'time_coverage_resolution',Value);
        
        Value =  fileversion;
        netcdf.putAtt(nc,NC_GLOBAL,'product_version',Value);
        
        Value =  'sss,sss_random_error';  % year3
        netcdf.putAtt(nc,NC_GLOBAL,'key_variables',Value);
        
        
        % year3 not relevant
        %     Value= single(0.25);
        %     netcdf.putAtt(nc,NC_GLOBAL,'geospatial_lat_resolution',Value);
        %
        %     Value= single(0.25);
        %     netcdf.putAtt(nc,NC_GLOBAL,'geospatial_lon_resolution',Value);
        
        Value = '25km EASE 2 cylindrical grid';   %  year 3
        netcdf.putAtt(nc,NC_GLOBAL,'spatial_grid',Value);
        
        Value= single(0);
        netcdf.putAtt(nc,NC_GLOBAL,'geospatial_vertical_min',Value);
        
        Value= single(0);
        netcdf.putAtt(nc,NC_GLOBAL,'geospatial_vertical_max',Value);
        
        Value =  'ESA CCI Sea Surface Salinity';
        netcdf.putAtt(nc,NC_GLOBAL,'summary',Value);
        
        Value =  [date_end 'Z'];
        netcdf.putAtt(nc,NC_GLOBAL,'time_coverage_end',Value);
        
        Value =  ' ';
        netcdf.putAtt(nc,NC_GLOBAL,'history',Value);
        
        Value = 'CCI Data Standards v2.2' ;  % year3
        netcdf.putAtt(nc,NC_GLOBAL,'format_version',Value);
        
        
        %%%%%%variables%%%%%%%
        
        varid=netcdf.defVar(nc,'time','float',[dimidX]);
        netcdf.putAtt(nc,varid,'long_name','time');
        netcdf.putAtt(nc,varid,'units','days since 1970-01-01 00:00:00 UTC');
        netcdf.putAtt(nc,varid,'standard_name','time');
        netcdf.putAtt(nc,varid,'calendar','standard');
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,date_time-days19700101);
        
        varid=netcdf.defVar(nc,'lat','float',[dimidY]);
        netcdf.putAtt(nc,varid,'long_name','latitude');
        netcdf.putAtt(nc,varid,'units','degrees_north');
        netcdf.putAtt(nc,varid,'standard_name','latitude');
        netcdf.putAtt(nc,varid,'valid_min',single(-90));
        netcdf.putAtt(nc,varid,'valid_max',single(90));
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,lat_ease);
        
        varid=netcdf.defVar(nc,'lon','float',[dimidZ]);
        netcdf.putAtt(nc,varid,'long_name','longitude');
        netcdf.putAtt(nc,varid,'units','degrees_east');
        netcdf.putAtt(nc,varid,'standard_name','longitude');
        netcdf.putAtt(nc,varid,'valid_min', single(-180));
        netcdf.putAtt(nc,varid,'valid_max', single(180));
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,lon_ease);
        
        varid=netcdf.defVar(nc,'sss_smos','float',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Unbiased Sea Surface Salinity');
        %netcdf.putAtt(nc,varid,'units','');
        netcdf.putAtt(nc,varid,'standard_name','sea_surface_salinity');
        netcdf.putAtt(nc,varid,'valid_min',single(0));
        netcdf.putAtt(nc,varid,'valid_max',single(50));
        %netcdf.putAtt(nc,varid,'scale_factor',1);
        %netcdf.putAtt(nc,varid,'add_offset',0);
        netcdf.defVarFill(nc,varid,false,NaN);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,SSS_smos);
        netcdf.putAtt(nc,varid,'ancillary','Noutliers_L4_smos Total_nobs_smos sss_qc_smos sss_smos_bias');
        
        varid=netcdf.defVar(nc,'sss_smap','float',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Unbiased Sea Surface Salinity');
        %netcdf.putAtt(nc,varid,'units','');
        netcdf.putAtt(nc,varid,'standard_name','sea_surface_salinity');
        netcdf.putAtt(nc,varid,'valid_min',single(0));
        netcdf.putAtt(nc,varid,'valid_max',single(50));
        %netcdf.putAtt(nc,varid,'scale_factor',1);
        %netcdf.putAtt(nc,varid,'add_offset',0);
        netcdf.defVarFill(nc,varid,false,NaN);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,SSS_smap);
        netcdf.putAtt(nc,varid,'ancillary','Noutliers_L4_smap Total_nobs_smap sss_qc_smap sss_smap_bias');
        
        varid=netcdf.defVar(nc,'sss_aquarius','float',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Unbiased Sea Surface Salinity');
        %netcdf.putAtt(nc,varid,'units','');
        netcdf.putAtt(nc,varid,'standard_name','sea_surface_salinity');
        netcdf.putAtt(nc,varid,'valid_min',single(0));
        netcdf.putAtt(nc,varid,'valid_max',single(50));
        %netcdf.putAtt(nc,varid,'scale_factor',1);
        %netcdf.putAtt(nc,varid,'add_offset',0);
        netcdf.defVarFill(nc,varid,false,NaN);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,SSS_aquarius);
        netcdf.putAtt(nc,varid,'ancillary','Noutliers_L4_aquarius Total_nobs_aquarius sss_qc_aquarius sss_aquarius_bias');
        
        varid=netcdf.defVar(nc,'sss_smos_random_error','float',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Sea Surface Salinity Random Error');
        %netcdf.putAtt(nc,varid,'units','');
        %netcdf.putAtt(nc,varid,'standard_name','sea_surface_salinity_random_error');
        netcdf.putAtt(nc,varid,'valid_min',single(0));
        netcdf.putAtt(nc,varid,'valid_max',single(100));
        %netcdf.putAtt(nc,varid,'scale_factor',1);
        %netcdf.putAtt(nc,varid,'add_offset',0);
        netcdf.defVarFill(nc,varid,false,NaN);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,SSS_smos_random);
        
        varid=netcdf.defVar(nc,'sss_smap_random_error','float',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Sea Surface Salinity Random Error');
        %netcdf.putAtt(nc,varid,'units','');
        %netcdf.putAtt(nc,varid,'standard_name','sea_surface_salinity_random_error');
        netcdf.putAtt(nc,varid,'valid_min',single(0));
        netcdf.putAtt(nc,varid,'valid_max',single(100));
        %netcdf.putAtt(nc,varid,'scale_factor',1);
        %netcdf.putAtt(nc,varid,'add_offset',0);
        netcdf.defVarFill(nc,varid,false,NaN);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,SSS_smap_random);
        
        varid=netcdf.defVar(nc,'sss_aquarius_random_error','float',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Sea Surface Salinity Random Error');
        %netcdf.putAtt(nc,varid,'units','');
        %netcdf.putAtt(nc,varid,'standard_name','sea_surface_salinity_random_error');
        netcdf.putAtt(nc,varid,'valid_min',single(0));
        netcdf.putAtt(nc,varid,'valid_max',single(100));
        %netcdf.putAtt(nc,varid,'scale_factor',1);
        %netcdf.putAtt(nc,varid,'add_offset',0);
        netcdf.defVarFill(nc,varid,false,NaN);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,SSS_aquarius_random);
        
        varid=netcdf.defVar(nc,'sss_smos_bias','float',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Bias in Sea Surface Salinity');
        %netcdf.putAtt(nc,varid,'units','pss');
        %netcdf.putAtt(nc,varid,'standard_name','sea_surface_salinity_bias');
        netcdf.putAtt(nc,varid,'valid_min',single(-100));
        netcdf.putAtt(nc,varid,'valid_max',single(100));
        %netcdf.putAtt(nc,varid,'scale_factor',1);
        %netcdf.putAtt(nc,varid,'add_offset',0);
        netcdf.defVarFill(nc,varid,false,NaN);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,SSS_smos_bias);
        
        varid=netcdf.defVar(nc,'sss_smap_bias','float',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Bias in Sea Surface Salinity');
        %netcdf.putAtt(nc,varid,'units','pss');
        %netcdf.putAtt(nc,varid,'standard_name','sea_surface_salinity_bias');
        netcdf.putAtt(nc,varid,'valid_min',single(-100));
        netcdf.putAtt(nc,varid,'valid_max',single(100));
        %netcdf.putAtt(nc,varid,'scale_factor',1);
        %netcdf.putAtt(nc,varid,'add_offset',0);
        netcdf.defVarFill(nc,varid,false,NaN);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,SSS_smap_bias);
        
        varid=netcdf.defVar(nc,'sss_aquarius_bias','float',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Bias in Sea Surface Salinity');
        %netcdf.putAtt(nc,varid,'units','pss');
        %netcdf.putAtt(nc,varid,'standard_name','sea_surface_salinity_bias');
        netcdf.putAtt(nc,varid,'valid_min',single(-100));
        netcdf.putAtt(nc,varid,'valid_max',single(100));
        %netcdf.putAtt(nc,varid,'scale_factor',1);
        %netcdf.putAtt(nc,varid,'add_offset',0);
        netcdf.defVarFill(nc,varid,false,NaN);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,SSS_aquarius_bias);
        
        varid=netcdf.defVar(nc,'sss_qc_smos','short',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Sea Surface Salinity Quality Check, 0=Good; 1=Bad');
        %netcdf.putAtt(nc,varid,'units','');
        %netcdf.putAtt(nc,varid,'standard_name','SSS global quality flag');
        netcdf.putAtt(nc,varid,'valid_min',int16(0));
        netcdf.putAtt(nc,varid,'valid_max',int16(1));
        netcdf.defVarFill(nc,varid,false,fillvalu);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,int16(sss_qc_smos));  %a mettre a jour
        
        varid=netcdf.defVar(nc,'sss_qc_smap','short',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Sea Surface Salinity Quality Check, 0=Good; 1=Bad');
        %netcdf.putAtt(nc,varid,'units','');
        %netcdf.putAtt(nc,varid,'standard_name','SSS global quality flag');
        netcdf.putAtt(nc,varid,'valid_min',int16(0));
        netcdf.putAtt(nc,varid,'valid_max',int16(1));
        netcdf.defVarFill(nc,varid,false,fillvalu);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,int16(sss_qc_smap));  %a mettre a jour
        
        varid=netcdf.defVar(nc,'sss_qc_aquarius','short',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Sea Surface Salinity Quality Check, 0=Good; 1=Bad');
        %netcdf.putAtt(nc,varid,'units','');
        %netcdf.putAtt(nc,varid,'standard_name','SSS global quality flag');
        netcdf.putAtt(nc,varid,'valid_min',int16(0));
        netcdf.putAtt(nc,varid,'valid_max',int16(1));
        netcdf.defVarFill(nc,varid,false,fillvalu);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,int16(sss_qc_aquarius));  %a mettre a jour
        
        varid=netcdf.defVar(nc,'Total_nobs_smos','short',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Number of SMOS observations after filtering');
        %netcdf.putAtt(nc,varid,'units','');
        %netcdf.putAtt(nc,varid,'standard_name','Land sea contamination flag');
        netcdf.putAtt(nc,varid,'valid_min',int16(0));
        netcdf.putAtt(nc,varid,'valid_max',int16(100));
        netcdf.defVarFill(nc,varid,false,fillvalu);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,int16(nobs_smos));  %a mettre a jour
        
        varid=netcdf.defVar(nc,'Total_nobs_smap','short',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Number of SMAP observations after filtering');
        %netcdf.putAtt(nc,varid,'units','');
        %netcdf.putAtt(nc,varid,'standard_name','Ice sea contamination flag');
        netcdf.putAtt(nc,varid,'valid_min',int16(0));
        netcdf.putAtt(nc,varid,'valid_max',int16(100));
        netcdf.defVarFill(nc,varid,false,fillvalu);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,int16(nobs_smap));  %a mettre a jour
        
        varid=netcdf.defVar(nc,'Total_nobs_aquarius','short',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Number of AQUARIUS observations after filtering');
        %netcdf.putAtt(nc,varid,'units','');
        %netcdf.putAtt(nc,varid,'standard_name','Ice sea contamination flag');
        netcdf.putAtt(nc,varid,'valid_min',int16(0));
        netcdf.putAtt(nc,varid,'valid_max',int16(100));
        netcdf.defVarFill(nc,varid,false,fillvalu);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,int16(nobs_aquarius));  %a mettre a jour
        
        varid=netcdf.defVar(nc,'Noutliers_L4_smos','short',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Number of SMOS observations rejected in level 4');
        %netcdf.putAtt(nc,varid,'units','');
        %netcdf.putAtt(nc,varid,'standard_name','Land sea contamination flag');
        netcdf.putAtt(nc,varid,'valid_min',int16(0));
        netcdf.putAtt(nc,varid,'valid_max',int16(100));
        netcdf.defVarFill(nc,varid,false,fillvalu);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,int16(noutliers_L4_smos));  %a mettre a jour
        
        varid=netcdf.defVar(nc,'Noutliers_L4_smap','short',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Number of SMAP observations rejected in level 4');
        %netcdf.putAtt(nc,varid,'units','');
        %netcdf.putAtt(nc,varid,'standard_name','Ice sea contamination flag');
        netcdf.putAtt(nc,varid,'valid_min',int16(0));
        netcdf.putAtt(nc,varid,'valid_max',int16(100));
        netcdf.defVarFill(nc,varid,false,fillvalu);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,int16(noutliers_L4_smap));  %a mettre a jour
        
        varid=netcdf.defVar(nc,'Noutliers_L4_aquarius','short',[dimidZ dimidY dimidX]);
        netcdf.putAtt(nc,varid,'long_name','Number of AQUARIUS observations rejected in level 4');
        %netcdf.putAtt(nc,varid,'units','');
        %netcdf.putAtt(nc,varid,'standard_name','Ice sea contamination flag');
        netcdf.putAtt(nc,varid,'valid_min',int16(0));
        netcdf.putAtt(nc,varid,'valid_max',int16(100));
        netcdf.defVarFill(nc,varid,false,fillvalu);
        netcdf.defVarDeflate(nc,varid,false,true,6);
        netcdf.putVar(nc,varid,int16(noutliers_L4_aquarius));  %a mettre a jour
        
        netcdf.close(nc)
    end
end

