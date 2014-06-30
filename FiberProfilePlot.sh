#!/bin/bash
# test


#### CONST
red='\e[0;31m'
green='\e[1;32m'
orange='\e[0;33m'
blue='\e[1;34m'
purple='\e[1;35m'
NC='\e[0m' # No Color

### FUNCTIONS
f_writeMatlabFile()
{
MATLABfilepath=$1
CSVfilename=$2
PDFfilename=$3
cat > $MATLABfilepath <<EOL
function main
    close all;
    clear all;

%% READ FILE
    filename = '${CSVfilename}';
    %M = csvread(filename,1,0);
    data1 = importdata(filename);
    M = data1.data;
    N = data1.textdata;
    dim = size(M)

%% CREATE FIGURE AND LABELS
    scrsz = get(0,'ScreenSize');
    graph = figure('Position',[1 scrsz(4)/1.5 scrsz(3)/1.5 scrsz(4)/1.5]);
    set(graph,'Visible','off'); %should have disappeared, if not : supress
    hold on;
   
    title(filename,'FontSize',12,'Interpreter', 'none');            % title
    xlabel('Arclength','FontSize',12);                              % axis X
    type = strtok(filename,'_'); ylabel(type,'FontSize',12)         % axis Y

    
%% PLOT LINES
    set(gcf, 'userdata', []);
    for i = 2:dim(2)
	if i == dim(2)
	    atlas   = line(M(:,1),M(:,i),'LineWidth'    ,  4  ...
	                                ,'color'        , 'r' ...
	                                ,'userdata'     ,  i  );
	else
	    data(i) = line(M(:,1),M(:,i),'LineWidth'    ,  1  ...
	                                ,'color'        , 'b' ...
	                                ,'userdata'     ,  i  ...
	                                ,'ButtonDownFcn', @displayName );
	end
    end

    legend([atlas,data(3)],'Atlas','Subjects','Location','NorthWest');
    
    
%% DISPLAY NAME ON SELECTION
    function displayName(gcbo, EventData, handles)

        % Get userdata #    
        new = get(gcbo,'userdata'); % new  selected object ID
        old = get(gcf ,'userdata'); % last selected object ID

        % Set new line colors/Width
        set(data(old),'LineWidth', 1 ,'color', 'b' ); % erase old
        set(data(new)  ,'LineWidth', 3 ,'color', 'c' ); % new highlight

        % Set new legend
        S=char(N(new)); %subject name
        l=legend([atlas,data(new)],'Atlas',S,'Location','NorthWest');
        set(l, 'Interpreter', 'none');

        % Save old userdata #
        set(gcf, 'userdata', new);
        
    end

%% SAVE IN FILE
    graphname = '${PDFfilename}';
    set(graph,'PaperOrientation','landscape');
    set(graph,'PaperPositionMode','auto');
    set(graph,'Position',[50 50 1200 800]);
    print(graph,'-dpdf', graphname);

    exit; %should have disappeared, if not : supress
end
EOL
}

f_processCSVFile()
{
	CSVfilepath=$1
	echo -e ${orange}"[PROCESSING] "${NC}$CSVfilepath

	# Create variables
	MATLABfilepath="${CSVfilepath%.csv*}.m"
	PDFfilepath="${CSVfilepath%.csv*}.pdf"
	PDFfilename=$(basename $PDFfilepath)
	CSVdirectory=$(dirname $CSVfilepath)
	CSVfilename=$(basename $CSVfilepath)
	filename="${CSVfilename%.csv*}"

	if grep -q nan "$CSVfilepath";
	then
		# Create new file without "nan" (becomes 0)
		NANfilepath="${CSVfilepath%.csv*}.nanto0"
		NANfilename=$(basename $NANfilepath)
		echo -e "${orange}>${NC} Substitute NAN with 0"
		sed -e 's:nan:0:g' <$1 > $NANfilepath
	
		# check filename length
		length=${#NANfilename}
		if [ "$length" -gt "63" ];
		then	
			echo -e "${orange}>${red} .nanto0 filename exceeds the MATLAB maximum name length of 63 characters (${NC}$length${red})."${NC}
			return 1
		fi			
			
		# Write .m
		echo -e "${orange}>${NC} Creating Matlab file"
		f_writeMatlabFile $MATLABfilepath $NANfilename $PDFfilename
	else
		# check filename length
		length=${#CSVfilename}
		if [ "$length" -gt "63" ];
		then	
			echo -e "${orange}>${red} .csv filename exceeds the MATLAB maximum name length of 63 characters (${NC}$length${red})."${NC}
			return 1
		fi			

		# Write .m
		echo -e "${orange}>${NC} Creating Matlab file"
		f_writeMatlabFile $MATLABfilepath $CSVfilename $PDFfilename
	fi
		
	# Launch Matlab file
	echo -e "${orange}>${NC} Printing plots into PDF"
	actualDir=$(pwd)
	cd $CSVdirectory
	hide=$(matlab -r $filename -nodesktop -nosplash) # -nodisplay is faster but no axis on print pdf
	cd $actualDir
	echo -e "${orange}>${green} Completed"${NC}

	# Remove exit and visibility off
	sed -i "/exit;/d" $MATLABfilepath
	sed -i "/set(graph,'Visible','off');/d" $MATLABfilepath

}

f_processDir()
{
	search_dir=$1
	echo -e ${purple}"OPENING DIRECTORY $search_dir"${NC}

	for var in "$search_dir"/*
	do
		if [ -f $var ] && [ ${var: -4} == ".csv" ];
	    	then
			f_processCSVFile $var
		elif [ -d $var ];
		then
			f_processDir $var
		fi
	done
	echo -e ${purple}"CLOSING DIRECTORY $search_dir"${NC}
}


### MAIN

# Opening script
echo ""
echo -e ${blue}"-- Fiber Profile Plot -----------------------------------------------"${NC}
echo ""

# Analyze inputs
if [ "$#" == "0" ];
then
	echo -e ${red}"No input file (.csv) or directory"${NC}
else
	for var in "$@"
	do
		if [ -f $var ] && [ ${var: -4} == ".csv" ];
	    	then
			f_processCSVFile $var
		elif [ -f $var ];
		then
			echo -e ${red}"Not a CSV file : "${NC}$var
		elif [ -d $var ];
		then
			f_processDir $var
		else
			echo -e ${red}"Does not exist : "${NC}$var
		fi
	done
fi

# Ending script
echo ""
echo -e ${blue}"---------------------------------------------------------------------"${NC}
echo ""
