USE portfolio_projects;

-- Create columns for the table
CREATE TABLE nashville_housing (
    UniqueID INT,
    ParcelID VARCHAR(50),
    LandUse VARCHAR(100),
    PropertyAddress VARCHAR(255),
    SaleDate VARCHAR(50),
    SalePrice DECIMAL(15,2),
    LegalReference VARCHAR(255),
    SoldAsVacant VARCHAR(10),
    OwnerName VARCHAR(255),
    OwnerAddress VARCHAR(255),
    Acreage DECIMAL(10,4),
    TaxDistrict VARCHAR(100),
    LandValue DECIMAL(15,2),
    BuildingValue DECIMAL(15,2),
    TotalValue DECIMAL(15,2),
    YearBuilt INT,
    Bedrooms INT,
    FullBath INT,
    HalfBath INT
);

-- Check to see if table exists and if columns
SHOW TABLES;
SELECT * FROM nashville_housing;

-- Load the file into MySql
LOAD DATA LOCAL INFILE 'C:\\Users\\B\\Documents\\Portfolio_projects\\Nashville Housing Data for Data Cleaning.csv'
INTO TABLE nashville_housing
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(UniqueID, ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference,
 SoldAsVacant, OwnerName, OwnerAddress, Acreage, TaxDistrict, LandValue,
 BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath);
 
-- Check The table to see if it has loaded correctly with 56477 rows
SELECT COUNT(*) FROM nashville_housing;
SELECT * FROM nashville_housing LIMIT 10;

-- Make changes to the SaleDate column so that we use it as a DATE datatype instead of string
ALTER TABLE nashville_housing ADD COLUMN SaleDate_correct DATE;
UPDATE nashville_housing
SET SaleDate_correct = STR_TO_DATE(SaleDate, '%m/%d/%Y')
WHERE SaleDate REGEXP '^[0-9]+/[0-9]+/[0-9]+$';

ALTER TABLE nashville_housing
DROP COLUMN SaleDate;

ALTER TABLE nashville_housing
CHANGE COLUMN SaleDate_Correct SaleDate DATE;

ALTER TABLE nashville_housing
MODIFY COLUMN SaleDate DATE AFTER PropertyAddress;
