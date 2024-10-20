function CloseExcelConnection( Excel )

    Excel.ActiveWorkbook.Save;
    Excel.Quit;
    Excel.delete;

end