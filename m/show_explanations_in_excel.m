function [] = show_explanations_in_excel(list)
%% Open the Excel application
h = actxserver('Excel.Application');
% Show the Excel window
h.Visible = 1;

file = [pwd '\explanations.xls'];  %If it's in the current directory
sheet = 1;
workbook = h.Workbooks.Open( file );
Sheets = h.ActiveWorkBook.Sheets;
Sheets.Item(1).Activate;
Activesheet = h.Activesheet;
if exist(file)
    % erase everything
    range = 'A2:E10000';
    ActivesheetRange = get(Activesheet,'Range',range);
    set(ActivesheetRange, 'Value', '');
end
range = 'B1';

% insert cell array
[rows,~] = size(list);
range = ['A2:E' num2str(rows+1)];
ActivesheetRange = get(Activesheet,'Range',range);
set(ActivesheetRange, 'Value', list);

% sort by subobjective
end

