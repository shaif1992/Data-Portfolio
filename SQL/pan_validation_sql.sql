-- =====================================================
-- PAN Number Validation Project - Complete SQL Solution
-- Author: Data Portfolio Project
-- Description: Comprehensive validation of Indian PAN numbers
-- =====================================================

-- Step 1: Create the main table (assuming data is imported from Excel)
CREATE TABLE pan_data_raw (
    id INT IDENTITY(1,1) PRIMARY KEY,
    pan_number NVARCHAR(50),
    import_date DATETIME DEFAULT GETDATE()
);

-- Step 2: Create a cleaned data table
CREATE TABLE pan_data_cleaned (
    id INT IDENTITY(1,1) PRIMARY KEY,
    original_pan NVARCHAR(50),
    cleaned_pan NVARCHAR(10),
    is_duplicate BIT DEFAULT 0,
    cleaning_notes NVARCHAR(255),
    processed_date DATETIME DEFAULT GETDATE()
);

-- Step 3: Create validation results table
CREATE TABLE pan_validation_results (
    id INT IDENTITY(1,1) PRIMARY KEY,
    pan_number NVARCHAR(10),
    validation_status NVARCHAR(20), -- 'VALID', 'INVALID', 'MISSING'
    validation_reason NVARCHAR(255),
    length_check BIT,
    format_check BIT,
    alpha_pattern_check BIT,
    numeric_pattern_check BIT,
    last_char_check BIT,
    validation_date DATETIME DEFAULT GETDATE()
);

-- =====================================================
-- DATA CLEANING PROCEDURES
-- =====================================================

-- Procedure 1: Clean and preprocess PAN data
CREATE PROCEDURE sp_CleanPANData
AS
BEGIN
    -- Clear previous results
    DELETE FROM pan_data_cleaned;
    
    -- Insert cleaned data with comprehensive cleaning
    INSERT INTO pan_data_cleaned (original_pan, cleaned_pan, cleaning_notes)
    SELECT 
        pan_number as original_pan,
        CASE 
            WHEN pan_number IS NULL OR LTRIM(RTRIM(pan_number)) = '' THEN NULL
            ELSE UPPER(LTRIM(RTRIM(REPLACE(REPLACE(pan_number, CHAR(9), ''), CHAR(160), ' '))))
        END as cleaned_pan,
        CASE 
            WHEN pan_number IS NULL THEN 'NULL value'
            WHEN LTRIM(RTRIM(pan_number)) = '' THEN 'Empty string'
            WHEN pan_number != LTRIM(RTRIM(pan_number)) THEN 'Had leading/trailing spaces'
            WHEN UPPER(pan_number) != pan_number THEN 'Had lowercase characters'
            ELSE 'No cleaning required'
        END as cleaning_notes
    FROM pan_data_raw;
    
    -- Mark duplicates
    UPDATE pan_data_cleaned 
    SET is_duplicate = 1
    WHERE cleaned_pan IN (
        SELECT cleaned_pan 
        FROM pan_data_cleaned 
        WHERE cleaned_pan IS NOT NULL
        GROUP BY cleaned_pan 
        HAVING COUNT(*) > 1
    );
    
    PRINT 'Data cleaning completed successfully.';
END;

-- =====================================================
-- PAN VALIDATION FUNCTIONS AND PROCEDURES
-- =====================================================

-- Function to check if adjacent alphabetic characters are same
CREATE FUNCTION fn_HasAdjacentSameAlpha(@pan_alpha NVARCHAR(5))
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT = 0;
    DECLARE @i INT = 1;
    
    WHILE @i < LEN(@pan_alpha)
    BEGIN
        IF SUBSTRING(@pan_alpha, @i, 1) = SUBSTRING(@pan_alpha, @i + 1, 1)
        BEGIN
            SET @result = 1;
            BREAK;
        END
        SET @i = @i + 1;
    END
    
    RETURN @result;
END;

-- Function to check if alphabetic characters form a sequence
CREATE FUNCTION fn_IsAlphaSequence(@pan_alpha NVARCHAR(5))
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT = 1;
    DECLARE @i INT = 1;
    
    -- Check if it's an ascending sequence
    WHILE @i < LEN(@pan_alpha)
    BEGIN
        IF ASCII(SUBSTRING(@pan_alpha, @i + 1, 1)) != ASCII(SUBSTRING(@pan_alpha, @i, 1)) + 1
        BEGIN
            SET @result = 0;
            BREAK;
        END
        SET @i = @i + 1;
    END
    
    -- If not ascending, check descending
    IF @result = 0
    BEGIN
        SET @result = 1;
        SET @i = 1;
        WHILE @i < LEN(@pan_alpha)
        BEGIN
            IF ASCII(SUBSTRING(@pan_alpha, @i + 1, 1)) != ASCII(SUBSTRING(@pan_alpha, @i, 1)) - 1
            BEGIN
                SET @result = 0;
                BREAK;
            END
            SET @i = @i + 1;
        END
    END
    
    RETURN @result;
END;

-- Function to check if adjacent numeric characters are same
CREATE FUNCTION fn_HasAdjacentSameNumeric(@pan_numeric NVARCHAR(4))
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT = 0;
    DECLARE @i INT = 1;
    
    WHILE @i < LEN(@pan_numeric)
    BEGIN
        IF SUBSTRING(@pan_numeric, @i, 1) = SUBSTRING(@pan_numeric, @i + 1, 1)
        BEGIN
            SET @result = 1;
            BREAK;
        END
        SET @i = @i + 1;
    END
    
    RETURN @result;
END;

-- Function to check if numeric characters form a sequence
CREATE FUNCTION fn_IsNumericSequence(@pan_numeric NVARCHAR(4))
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT = 1;
    DECLARE @i INT = 1;
    
    -- Check ascending sequence
    WHILE @i < LEN(@pan_numeric)
    BEGIN
        IF CAST(SUBSTRING(@pan_numeric, @i + 1, 1) AS INT) != CAST(SUBSTRING(@pan_numeric, @i, 1) AS INT) + 1
        BEGIN
            SET @result = 0;
            BREAK;
        END
        SET @i = @i + 1;
    END
    
    -- If not ascending, check descending
    IF @result = 0
    BEGIN
        SET @result = 1;
        SET @i = 1;
        WHILE @i < LEN(@pan_numeric)
        BEGIN
            IF CAST(SUBSTRING(@pan_numeric, @i + 1, 1) AS INT) != CAST(SUBSTRING(@pan_numeric, @i, 1) AS INT) - 1
            BEGIN
                SET @result = 0;
                BREAK;
            END
            SET @i = @i + 1;
        END
    END
    
    RETURN @result;
END;

-- Main validation procedure
CREATE PROCEDURE sp_ValidatePANNumbers
AS
BEGIN
    -- Clear previous validation results
    DELETE FROM pan_validation_results;
    
    -- Validate each PAN number
    INSERT INTO pan_validation_results (
        pan_number, validation_status, validation_reason,
        length_check, format_check, alpha_pattern_check, 
        numeric_pattern_check, last_char_check
    )
    SELECT 
        cleaned_pan,
        CASE 
            WHEN cleaned_pan IS NULL THEN 'MISSING'
            WHEN LEN(cleaned_pan) != 10 THEN 'INVALID'
            WHEN cleaned_pan NOT LIKE '[A-Z][A-Z][A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][A-Z]' THEN 'INVALID'
            WHEN dbo.fn_HasAdjacentSameAlpha(LEFT(cleaned_pan, 5)) = 1 THEN 'INVALID'
            WHEN dbo.fn_IsAlphaSequence(LEFT(cleaned_pan, 5)) = 1 THEN 'INVALID'
            WHEN dbo.fn_HasAdjacentSameNumeric(SUBSTRING(cleaned_pan, 6, 4)) = 1 THEN 'INVALID'
            WHEN dbo.fn_IsNumericSequence(SUBSTRING(cleaned_pan, 6, 4)) = 1 THEN 'INVALID'
            ELSE 'VALID'
        END as validation_status,
        
        -- Detailed validation reason
        CASE 
            WHEN cleaned_pan IS NULL THEN 'Missing PAN number'
            WHEN LEN(cleaned_pan) != 10 THEN 'Invalid length: ' + CAST(LEN(cleaned_pan) AS VARCHAR(5)) + ' characters'
            WHEN cleaned_pan NOT LIKE '[A-Z][A-Z][A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][A-Z]' THEN 'Invalid format: Does not match AAAAA1234A pattern'
            WHEN dbo.fn_HasAdjacentSameAlpha(LEFT(cleaned_pan, 5)) = 1 THEN 'Invalid: Adjacent alphabetic characters are same'
            WHEN dbo.fn_IsAlphaSequence(LEFT(cleaned_pan, 5)) = 1 THEN 'Invalid: Alphabetic characters form a sequence'
            WHEN dbo.fn_HasAdjacentSameNumeric(SUBSTRING(cleaned_pan, 6, 4)) = 1 THEN 'Invalid: Adjacent numeric characters are same'
            WHEN dbo.fn_IsNumericSequence(SUBSTRING(cleaned_pan, 6, 4)) = 1 THEN 'Invalid: Numeric characters form a sequence'
            ELSE 'Valid PAN number'
        END as validation_reason,
        
        -- Individual check results
        CASE WHEN LEN(ISNULL(cleaned_pan, '')) = 10 THEN 1 ELSE 0 END as length_check,
        CASE WHEN cleaned_pan LIKE '[A-Z][A-Z][A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][A-Z]' THEN 1 ELSE 0 END as format_check,
        CASE WHEN dbo.fn_HasAdjacentSameAlpha(LEFT(cleaned_pan, 5)) = 0 AND dbo.fn_IsAlphaSequence(LEFT(cleaned_pan, 5)) = 0 THEN 1 ELSE 0 END as alpha_pattern_check,
        CASE WHEN dbo.fn_HasAdjacentSameNumeric(SUBSTRING(cleaned_pan, 6, 4)) = 0 AND dbo.fn_IsNumericSequence(SUBSTRING(cleaned_pan, 6, 4)) = 0 THEN 1 ELSE 0 END as numeric_pattern_check,
        CASE WHEN RIGHT(cleaned_pan, 1) LIKE '[A-Z]' THEN 1 ELSE 0 END as last_char_check
        
    FROM pan_data_cleaned;
    
    PRINT 'PAN validation completed successfully.';
END;

-- =====================================================
-- REPORTING PROCEDURES
-- =====================================================

-- Summary report procedure
CREATE PROCEDURE sp_GeneratePANSummaryReport
AS
BEGIN
    SELECT 
        'PAN Validation Summary Report' as ReportTitle,
        GETDATE() as GeneratedOn;
    
    -- Overall statistics
    SELECT 
        COUNT(*) as TotalRecordsProcessed,
        SUM(CASE WHEN validation_status = 'VALID' THEN 1 ELSE 0 END) as TotalValidPANs,
        SUM(CASE WHEN validation_status = 'INVALID' THEN 1 ELSE 0 END) as TotalInvalidPANs,
        SUM(CASE WHEN validation_status = 'MISSING' THEN 1 ELSE 0 END) as TotalMissingPANs,
        ROUND(
            (SUM(CASE WHEN validation_status = 'VALID' THEN 1.0 ELSE 0 END) / COUNT(*)) * 100, 2
        ) as ValidPANPercentage
    FROM pan_validation_results;
    
    -- Detailed breakdown by validation status
    SELECT 
        validation_status as Status,
        COUNT(*) as Count,
        ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM pan_validation_results), 2) as Percentage
    FROM pan_validation_results
    GROUP BY validation_status
    ORDER BY COUNT(*) DESC;
    
    -- Top validation failure reasons
    SELECT TOP 10
        validation_reason as FailureReason,
        COUNT(*) as Count
    FROM pan_validation_results
    WHERE validation_status != 'VALID'
    GROUP BY validation_reason
    ORDER BY COUNT(*) DESC;
    
    -- Data quality metrics
    SELECT 
        'Data Quality Metrics' as MetricType,
        SUM(CASE WHEN length_check = 1 THEN 1 ELSE 0 END) as PassedLengthCheck,
        SUM(CASE WHEN format_check = 1 THEN 1 ELSE 0 END) as PassedFormatCheck,
        SUM(CASE WHEN alpha_pattern_check = 1 THEN 1 ELSE 0 END) as PassedAlphaPatternCheck,
        SUM(CASE WHEN numeric_pattern_check = 1 THEN 1 ELSE 0 END) as PassedNumericPatternCheck,
        SUM(CASE WHEN last_char_check = 1 THEN 1 ELSE 0 END) as PassedLastCharCheck
    FROM pan_validation_results;
END;

-- Detailed validation report
CREATE PROCEDURE sp_GenerateDetailedValidationReport
AS
BEGIN
    SELECT 
        ROW_NUMBER() OVER (ORDER BY validation_date) as SerialNo,
        pan_number as PANNumber,
        validation_status as Status,
        validation_reason as Reason,
        CASE WHEN length_check = 1 THEN 'PASS' ELSE 'FAIL' END as LengthCheck,
        CASE WHEN format_check = 1 THEN 'PASS' ELSE 'FAIL' END as FormatCheck,
        CASE WHEN alpha_pattern_check = 1 THEN 'PASS' ELSE 'FAIL' END as AlphaPatternCheck,
        CASE WHEN numeric_pattern_check = 1 THEN 'PASS' ELSE 'FAIL' END as NumericPatternCheck,
        CASE WHEN last_char_check = 1 THEN 'PASS' ELSE 'FAIL' END as LastCharCheck,
        validation_date as ValidationDate
    FROM pan_validation_results
    ORDER BY 
        CASE validation_status 
            WHEN 'VALID' THEN 1 
            WHEN 'INVALID' THEN 2 
            WHEN 'MISSING' THEN 3 
        END,
        pan_number;
END;

-- =====================================================
-- MAIN EXECUTION PROCEDURE
-- =====================================================

CREATE PROCEDURE sp_ExecutePANValidationProject
AS
BEGIN
    BEGIN TRY
        PRINT '====================================================';
        PRINT 'Starting PAN Number Validation Project';
        PRINT '====================================================';
        
        -- Step 1: Clean data
        PRINT 'Step 1: Cleaning and preprocessing data...';
        EXEC sp_CleanPANData;
        
        -- Step 2: Validate PAN numbers
        PRINT 'Step 2: Validating PAN numbers...';
        EXEC sp_ValidatePANNumbers;
        
        -- Step 3: Generate reports
        PRINT 'Step 3: Generating validation reports...';
        EXEC sp_GeneratePANSummaryReport;
        
        PRINT '====================================================';
        PRINT 'PAN Number Validation Project completed successfully!';
        PRINT '====================================================';
        
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred during PAN validation process:';
        PRINT ERROR_MESSAGE();
    END CATCH
END;

-- =====================================================
-- SAMPLE DATA FOR TESTING
-- =====================================================

-- Insert sample test data (remove this section when using real data)
/*
INSERT INTO pan_data_raw (pan_number) VALUES
('AHGVE1276K'),    -- Valid
('ahgve1276k'),    -- Valid (after cleaning)
(' BHCPK9876L '),  -- Valid (after cleaning)
('AABCD1234E'),    -- Invalid (adjacent same alpha)
('ABCDE1234F'),    -- Invalid (alpha sequence)
('AXBCD1123G'),    -- Invalid (adjacent same numeric)
('BXCDY1234H'),    -- Invalid (numeric sequence)
('INVALID123'),    -- Invalid (wrong format)
('ABC123'),        -- Invalid (too short)
(''),             -- Missing (empty)
(NULL),           -- Missing (null)
('AHGVE1276K');   -- Duplicate

-- Execute the complete validation process
EXEC sp_ExecutePANValidationProject;

-- View detailed results
EXEC sp_GenerateDetailedValidationReport;
*/