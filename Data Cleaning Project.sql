
--------------------------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM [Cleaning Project].dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

---------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address

SELECT PropertyAddress
FROM [Cleaning Project].dbo.NashvilleHousing

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Cleaning Project].dbo.NashvilleHousing a
JOIN [Cleaning Project].dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM [Cleaning Project].dbo.NashvilleHousing a
JOIN [Cleaning Project].dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Break the Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM [Cleaning Project].dbo.NashvilleHousing

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM [Cleaning Project].dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM [Cleaning Project].dbo.NashvilleHousing

SELECT OwnerAddress
FROM [Cleaning Project].dbo.NashvilleHousing

SELECT 
PARSENAME (REPLACE(OwnerAddress, ',','.'), 3)
, PARSENAME (REPLACE(OwnerAddress, ',','.'), 2)
, PARSENAME (REPLACE(OwnerAddress, ',','.'), 1)
FROM [Cleaning Project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',','.'), 1)


SELECT *
FROM [Cleaning Project].dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Change the Y and N in "Sold as Vacant" field to Yes and No

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM [Cleaning Project].dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [Cleaning Project].dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE As(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [Cleaning Project].dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1


--------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Unused Columns

ALTER TABLE [Cleaning Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--------------------------------------------------------------------------------------------------------------------------------------------------

SELECT *
FROM [Cleaning Project].dbo.NashvilleHousing










