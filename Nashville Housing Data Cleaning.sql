-- CLEANING DATA IN SQL QUERIES
SELECT *
FROM nashville_housing;

-- Set the column to NULL if the trimmed value is an empty string.
UPDATE nashville_housing
SET
  UniqueID = NULLIF(TRIM(UniqueID), ''),
  ParcelID = NULLIF(TRIM(ParcelID), ''),
  LandUse = NULLIF(TRIM(LandUse), ''),
  PropertyAddress = NULLIF(TRIM(PropertyAddress), ''),
  SaleDate = NULLIF(TRIM(SaleDate), ''),
  SalePrice = NULLIF(TRIM(SalePrice), ''),
  LegalReference = NULLIF(TRIM(LegalReference), ''),
  SoldAsVacant = NULLIF(TRIM(SoldAsVacant), ''),
  OwnerName = NULLIF(TRIM(OwnerName), ''),
  OwnerAddress = NULLIF(TRIM(OwnerAddress), ''),
  Acreage = NULLIF(TRIM(Acreage), ''),
  TaxDistrict = NULLIF(TRIM(TaxDistrict), ''),
  LandValue = NULLIF(TRIM(LandValue), ''),
  BuildingValue = NULLIF(TRIM(BuildingValue), ''),
  TotalValue = NULLIF(TRIM(TotalValue), ''),
  YearBuilt = NULLIF(TRIM(YearBuilt), ''),
  Bedrooms = NULLIF(TRIM(Bedrooms), ''),
  FullBath = NULLIF(TRIM(FullBath), ''),
  HalfBath = NULLIF(TRIM(HalfBath), '');


-- Populate PropertyAddress column
SELECT *
FROM nashville_housing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
    AND a.`UniqueID` <> b.`UniqueID`
WHERE a.PropertyAddress IS NULL;

UPDATE nashville_housing a
JOIN nashville_housing b
    ON a.ParcelID = b.ParcelID
    AND a.`UniqueID` <> b.`UniqueID`
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress IS NULL;

-- Breaking out Address into Individual Columns (Address, City, State)
-- 1. PropertyAddress
SELECT PropertyAddress
FROM nashville_housing;

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1) AS City
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD PropertySplitAddress VARCHAR(255);

UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1);

ALTER TABLE nashville_housing
ADD PropertySplitCity VARCHAR(255);

UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1);

SELECT *
FROM nashville_housing;

-- 2. OwnerAddress
SELECT OwnerAddress
FROM nashville_housing;

SELECT
  TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)),
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)),
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1))
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD OwnerSplitAddress VARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1));

ALTER TABLE nashville_housing
ADD OwnerSplitCity VARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));

ALTER TABLE nashville_housing
ADD OwnerSplitState VARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitState = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1));

-- Change Y and N to Yes and No in "SoldAsVacant" field
SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
FROM nashville_housing;

UPDATE nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END;
    
-- Remove Duplicates
WITH RowNumCTE AS (
  SELECT 
    UniqueID
  FROM (
    SELECT 
      UniqueID,
      ROW_NUMBER() OVER(
        PARTITION BY ParcelID,
                     PropertyAddress,
                     SalePrice,
                     SaleDate,
                     LegalReference
        ORDER BY UniqueID
      ) AS row_num
    FROM nashville_housing
  ) AS sub
  WHERE row_num > 1
)
DELETE nh
FROM nashville_housing nh
JOIN RowNumCTE cte ON nh.UniqueID = cte.UniqueID;

-- Delete Unused Columns
ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

