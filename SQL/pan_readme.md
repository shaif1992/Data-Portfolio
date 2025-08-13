# PAN Number Validation Project

## 📋 Overview

This project provides a comprehensive SQL-based solution for cleaning, validating, and analyzing Indian Permanent Account Number (PAN) datasets. The solution ensures data quality through systematic validation against official PAN format requirements.

## 🎯 Objective

Validate and categorize PAN numbers from a dataset to ensure compliance with Indian tax authority regulations, providing detailed reporting on data quality and validation results.

## 🏗️ Project Structure

```
PAN-Validation/
├── pan_validation_complete.sql    # Complete SQL solution
├── sample_data/
│   ├── sample_pan_data.xlsx       # Sample test data
│   └── validation_results.xlsx    # Sample output
├── documentation/
│   ├── validation_rules.md        # Detailed validation rules
│   └── database_schema.md         # Database schema documentation
└── README.md                      # This file
```

## 📊 PAN Validation Rules

### Format Requirements
A valid PAN number must satisfy ALL the following criteria:

1. **Length**: Exactly 10 characters
2. **Pattern**: `AAAAA1234A` format where:
   - First 5 characters: Uppercase alphabetic letters
   - Next 4 characters: Numeric digits  
   - Last character: Uppercase alphabetic letter

### Advanced Validation Rules

#### Alphabetic Characters (Positions 1-5):
- ❌ **Adjacent Same**: No two adjacent characters can be identical (e.g., `AABCD` is invalid)
- ❌ **Sequences**: Cannot form ascending/descending sequences (e.g., `ABCDE`, `EDCBA` are invalid)
- ✅ **Valid Example**: `AHGVE` (no adjacent same, no sequence)

#### Numeric Characters (Positions 6-9):
- ❌ **Adjacent Same**: No two adjacent digits can be identical (e.g., `1123` is invalid)
- ❌ **Sequences**: Cannot form ascending/descending sequences (e.g., `1234`, `4321` are invalid)
- ✅ **Valid Example**: `1276` (no adjacent same, no sequence)

#### Examples:
- ✅ **Valid**: `AHGVE1276K`
- ❌ **Invalid**: `AABCD1234E` (adjacent same alphabets)
- ❌ **Invalid**: `ABCDE1276K` (alphabetic sequence)
- ❌ **Invalid**: `AHGVE1123K` (adjacent same digits)
- ❌ **Invalid**: `AHGVE1234K` (numeric sequence)

## 🔧 Technical Implementation

### Database Schema

#### Core Tables:
1. **`pan_data_raw`**: Stores original imported data
2. **`pan_data_cleaned`**: Contains cleaned and preprocessed data
3. **`pan_validation_results`**: Stores detailed validation results

#### Key Procedures:
1. **`sp_CleanPANData`**: Handles data preprocessing and cleaning
2. **`sp_ValidatePANNumbers`**: Performs comprehensive PAN validation
3. **`sp_GeneratePANSummaryReport`**: Creates summary statistics
4. **`sp_GenerateDetailedValidationReport`**: Provides detailed validation results

### Validation Functions:
- `fn_HasAdjacentSameAlpha()`: Checks for adjacent identical alphabetic characters
- `fn_IsAlphaSequence()`: Detects alphabetic sequences
- `fn_HasAdjacentSameNumeric()`: Checks for adjacent identical digits
- `fn_IsNumericSequence()`: Detects numeric sequences

## 🚀 Getting Started

### Prerequisites
- Microsoft SQL Server 2016 or later
- SQL Server Management Studio (SSMS) or Azure Data Studio

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/shaif1992/Data-Portfolio.git
   cd Data-Portfolio/SQL/PAN-Validation
   ```

2. **Set up the database**:
   ```sql
   -- Create a new database
   CREATE DATABASE PAN_Validation;
   USE PAN_Validation;
   
   -- Execute the complete SQL script
   -- Run pan_validation_complete.sql
   ```

3. **Import your data**:
   ```sql
   -- Import your Excel data into pan_data_raw table
   -- Use SQL Server Import/Export Wizard or BULK INSERT
   ```

### Usage

#### Quick Start:
```sql
-- Execute the complete validation process
EXEC sp_ExecutePANValidationProject;

-- Generate summary report
EXEC sp_GeneratePANSummaryReport;

-- View detailed results
EXEC sp_GenerateDetailedValidationReport;
```

#### Step-by-Step Execution:
```sql
-- Step 1: Clean the data
EXEC sp_CleanPANData;

-- Step 2: Validate PAN numbers
EXEC sp_ValidatePANNumbers;

-- Step 3: Generate reports
EXEC sp_GeneratePANSummaryReport;
EXEC sp_GenerateDetailedValidationReport;
```

## 📈 Sample Output

### Summary Report:
```
Total Records Processed: 10,000
Total Valid PANs: 7,530 (75.3%)
Total Invalid PANs: 2,200 (22.0%)
Total Missing PANs: 270 (2.7%)
```

### Validation Breakdown:
```
Status    | Count | Percentage
----------|-------|----------
VALID     | 7,530 | 75.3%
INVALID   | 2,200 | 22.0%
MISSING   |   270 | 2.7%
```

### Top Failure Reasons:
```
Failure Reason                              | Count
--------------------------------------------|------
Invalid: Adjacent alphabetic chars same     | 890
Invalid: Numeric characters form sequence   | 445
Invalid length: 9 characters               | 334
Invalid: Adjacent numeric characters same   | 289
```

## 🔍 Data Cleaning Features

The solution automatically handles:

- **Missing Values**: Identifies and categorizes NULL or empty PAN numbers
- **Whitespace**: Removes leading/trailing spaces and tabs
- **Case Conversion**: Converts all letters to uppercase
- **Duplicate Detection**: Identifies and flags duplicate PAN numbers
- **Format Standardization**: Ensures consistent data format

## 📊 Validation Metrics

The system provides detailed metrics including:

- **Length Check**: Validates 10-character requirement
- **Format Check**: Ensures AAAAA1234A pattern compliance
- **Alpha Pattern Check**: Validates alphabetic character rules
- **Numeric Pattern Check**: Validates numeric character rules
- **Last Character Check**: Ensures final character is alphabetic

## 🛠️ Customization

### Adding Custom Validation Rules:
```sql
-- Example: Add state-specific validation
ALTER TABLE pan_validation_results 
ADD state_code_check BIT DEFAULT 0;

-- Create custom validation function
CREATE FUNCTION fn_ValidateStateCode(@pan NVARCHAR(10))
RETURNS BIT
AS
BEGIN
    -- Your custom validation logic here
    RETURN 1;
END;
```

### Performance Optimization:
```sql
-- Add indexes for better performance
CREATE INDEX IX_PAN_ValidationStatus 
ON pan_validation_results(validation_status);

CREATE INDEX IX_PAN_Number 
ON pan_data_cleaned(cleaned_pan);
```

## 🧪 Testing

The solution includes comprehensive test cases covering:

- Valid PAN formats
- All types of invalid patterns
- Edge cases and boundary conditions
- Data quality scenarios

Run tests using the sample data provided in the script comments.

## 📝 Best Practices

1. **Data Backup**: Always backup your data before running validation
2. **Batch Processing**: For large datasets, consider processing in batches
3. **Error Handling**: The solution includes comprehensive error handling
4. **Logging**: All procedures include detailed logging for troubleshooting

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## 📞 Contact

**Shaif** - [GitHub Profile](https://github.com/shaif1992)

Project Link: [https://github.com/shaif1992/Data-Portfolio/tree/main/SQL](https://github.com/shaif1992/Data-Portfolio/tree/main/SQL)

## 🙏 Acknowledgments

- Indian Income Tax Department for PAN format specifications
- SQL Server documentation and community
- Data validation best practices from industry standards

---

### 📊 Project Status: ✅ Complete and Production Ready

This solution has been tested with various datasets and handles edge cases effectively. It's suitable for both small-scale validation tasks and enterprise-level data processing requirements.