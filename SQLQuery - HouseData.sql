SELECT * FROM NashHousing

 -- Check for nulls in property address col

SELECT *
FROM NashHousing
-- WHERE PropertyAddress is null
ORDER BY ParcelID

 -- Finding missing addresses
SELECT a.ParcelID, a.PropertyAddress, b.ParcelId, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashHousing a
JOIN NashHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

 -- Replace Null addresses
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashHousing a
JOIN NashHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

SELECT PropertyAddress
FROM NashHousing
-- WHERE PropertyAddress is null
-- ORDER BY ParcelID

 -- Splitting PropertyAddress col
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM NashHousing

 -- Add new cols with split address
ALTER TABLE NashHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashHousing
ADD PropertySplitCity Nvarchar(255);

Update NashHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


 -- Splitting OwnerAddress col with diff method (easier to do)
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
, PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
, PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM NashHousing

 -- Add new cols with split address
ALTER TABLE NashHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashHousing
ADD OwnerSplitState Nvarchar(255);

Update NashHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

-- Remove Duplicates

WITH RowNumCTE AS(
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


FROM NashHousing
)
 -- Checked for any with row_num > 1 and changed select to delete to remove these rows
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


-- Delete unused cols

ALTER TABLE NashHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

SELECT *
FROM NashHousing

