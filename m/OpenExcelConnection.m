function ret1 = OpenExcelConnection( file )
    
    Excel = actxserver( 'Excel.Application' );
    
    if ~exist( file, 'file' )
        ret1 = '';
    end
    
    Excel.Workbooks.Open( file );
    
    ret1 = Excel;

end