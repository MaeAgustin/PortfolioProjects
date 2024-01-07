SELECT *
FROM NashvilleHousing

-- Standardize date format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHousing

-- Populate Property Address data

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

-- Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing 

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress)) AS City
FROM NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar (255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar (255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress))

SELECT *
FROM NashvilleHousing 

SELECT OwnerAddress
FROM NashvilleHousing 

SELECT
PARSENAME (REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME (REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME (REPLACE(OwnerAddress, ',','.'), 1)
FROM NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar (255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar (255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar (255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',','.'), 1)

SELECT *
FROM NashvilleHousing 

-- Change Y to N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
         WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END
FROM NashvilleHousing 

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
END

-- Remove duplicates

WITH RowNumCTE AS( 
SELECT *, 
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, 
                     PropertyAddress,
                     SalePrice,
                     SaleDate,
                     LegalReference
                     ORDER BY UniqueID) row_num 
FROM NashvilleHousing 
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Delete unused columns

SELECT *
FROM NashvilleHousing 

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate