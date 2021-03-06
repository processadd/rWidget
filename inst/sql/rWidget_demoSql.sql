USE rWidget
GO

CREATE TABLE dygraphs_closePrices([Date] date, APPL smallmoney, MSFT smallmoney)
GO  

BULK INSERT dygraphs_closePrices
FROM 'rWidget\rWidget\closePrices.csv'  -- replace with real path
WITH (
    FIELDTERMINATOR = ',',
    FIRSTROW=2,  
    ROWTERMINATOR = '\n')
GO

CREATE PROCEDURE [dbo].[rWidgetDemo]
    @data nvarchar(MAX), 
    @url varchar(1000)='',
    @basePath_dygraphs varchar(1000)='',
    @basePath_DT varchar(1000)=''
AS
BEGIN
    SET NOCOUNT ON;
    -- DROP TABLE IF EXISTS #t 
    SELECT Date, APPL, MSFT INTO #t FROM OPENJSON (@data, '$') WITH (Date date, APPL money, MSFT money);
    
    EXECUTE sp_execute_external_script  
    @language = N'R',
    @script = N'
    library(dygraphs)
    library(DT)
    library(rWidget)
    library(htmltools)
        maxDate <- max(raw[,1])
        minDate <- min(raw[,1])
        title <- paste("rWidget demo - dygraphs for [", minDate, " - ", maxDate, "]")
        data <- raw
        rownames(data) <- data[, 1]
        data = data[,-1]
        d <- dygraph(data, main = title) %>% dyRangeSelector(dateWindow = c(minDate, maxDate))
        dWidget <- rWidget::getHtmlWidget(d, url, basePath_dygraphs)

        dt <- datatable(raw)
        dtWidget <- rWidget::getHtmlWidget(dt, url, basePath_DT)
        OutputDataSet <- data.frame(dWidget, dtWidget)
     '
  ,
  @input_data_1 = N'SELECT * FROM #t',
  @input_data_1_name = N'raw',
  @params = N'@url varchar(1000), @basePath_dygraphs varchar(1000), @basePath_DT varchar(1000)',
  @url = @url,
  @basePath_dygraphs = @basePath_dygraphs,
  @basePath_DT = @basePath_DT
  WITH RESULT SETS  ((dWidget nvarchar(max), dtWidget nvarchar(max)));
  
END
GO
