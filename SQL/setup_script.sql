-- =====================================================
-- PAN Validation Project - Quick Setup Script
-- Run this script to set up the complete environment
-- =====================================================

USE master;
GO

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'PAN_Validation')
BEGIN
    CREATE DATABASE PAN_Validation;
    PRINT 'Database PAN_Validation created successfully.';
END
ELSE
BEGIN
    PRINT 'Database PAN_Validation already exists.';
END
GO

USE PAN_Validation;
GO

-- Check if tables exist and drop them for fresh setup (optional)
PRINT 'Setting up database schema...';

-- Drop existing objects if they exist (for fresh setup)
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_ExecutePANValidationProject')
    DROP PROCEDURE sp_ExecutePANValidationProject;

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GenerateDetailedValidationReport')
    DROP PROCEDURE sp_GenerateDetailedValidationReport;

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GeneratePANSummaryReport')
    DROP PROCEDURE sp_GeneratePANSummaryReport;

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_ValidatePANNumbers')
    DROP PROCEDURE sp_ValidatePANNumbers;

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_CleanPANData')
    DROP PROCEDURE sp_CleanPANData;

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'fn_IsNumericSequence')
    DROP FUNCTION fn_IsNumericSequence;

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'fn_HasAdjacentSameNumeric')
    DROP FUNCTION fn_HasAdjacentSameNumeric;

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'fn_IsAlphaSequence')
    DROP FUNCTION fn_IsAlphaSequence;

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'fn_HasAdjacentSameAlpha')
    DROP FUNCTION fn_HasAdjacentSameAlpha;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'pan_validation_results')
    DROP TABLE pan_validation_results;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'pan_data_cleaned')
    DROP TABLE pan_data_cleaned;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'pan_data_raw')
    DROP TABLE pan_data_raw;

PRINT 'Database cleanup completed.';
PRINT '======================================';
PRINT 'Ready for fresh installation.';
PRINT '======================================';
PRINT 'Next steps:';
PRINT '1. Run the complete PAN validation SQL script';
PRINT '2. Import your Excel data into pan_data_raw table';
PRINT '3. Execute: EXEC sp_ExecutePANValidationProject';
PRINT '======================================';

-- You can also add sample data insertion here if needed
/*
-- Uncomment this section to add sample test data

PRINT 'Adding sample test data...';

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
('TOOLONGPANNUMBER'), -- Invalid (too long)
(''),             -- Missing (empty)
(NULL),           -- Missing (null)
('AHGVE1276K'),   -- Duplicate
('CDEFG5678M'),   -- Valid
('HIJKL9012N');   -- Valid

PRINT 'Sample data added successfully.';
PRINT 'You can now run the validation process.';
*/