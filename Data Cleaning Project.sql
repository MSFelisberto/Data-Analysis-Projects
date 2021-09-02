
-- Data Cleaning with SQL Queries

SELECT *
FROM PortifolioProject..NashvilleHousing


-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortifolioProject.dbo.NashvilleHousing

ALTER TABLE PortifolioProject..NashvilleHousing
add SaleDateConverted Date;

UPDATE PortifolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address data
-- This dataset has some nulls in the property address colunm, in the script below i've done a populate those nulls with the right data.

SELECT *
FROM PortifolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortifolioProject.dbo.NashvilleHousing a
JOIN PortifolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortifolioProject.dbo.NashvilleHousing a
JOIN PortifolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortifolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM PortifolioProject.dbo.NashvilleHousing

ALTER TABLE PortifolioProject..NashvilleHousing
add Address nvarchar(255);

UPDATE PortifolioProject.dbo.NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE PortifolioProject..NashvilleHousing
add City nvarchar(255);

UPDATE PortifolioProject.dbo.NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

SELECT Address, City
FROM PortifolioProject.dbo.NashvilleHousing







SELECT OwnerAddress
FROM PortifolioProject.dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortifolioProject.dbo.NashvilleHousing


ALTER TABLE PortifolioProject..NashvilleHousing
add OwnerStreetAddress nvarchar(255);

UPDATE PortifolioProject.dbo.NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortifolioProject..NashvilleHousing
add OwnerCity nvarchar(255);

UPDATE PortifolioProject.dbo.NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortifolioProject..NashvilleHousing
add OwnerState nvarchar(255);

UPDATE PortifolioProject.dbo.NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortifolioProject.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) as Count
FROM PortifolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC


SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortifolioProject.dbo.NashvilleHousing


UPDATE PortifolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END




-- Removing Duplicates 

WITH RowNumCTE as(
SELECT *
, ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

FROM PortifolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress






-- Delete Unused Columns


SELECT *
FROM PortifolioProject.dbo.NashvilleHousing


ALTER TABLE PortifolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate