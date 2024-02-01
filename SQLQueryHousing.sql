Select *
From PortfolioProject..NashvilleHousing

-- Changing Sale Date

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

--If not working

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address Data

Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null
Order by ParcelID

Select nh1.ParcelID, nh1.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress, ISNULL(nh1.PropertyAddress, nh2.PropertyAddress)
From PortfolioProject..NashvilleHousing nh1
Join PortfolioProject..NashvilleHousing nh2
	On nh1.ParcelID = nh2.ParcelID
	AND nh1.[UniqueID ] <> nh2.[UniqueID ]
Where nh1.PropertyAddress is null

Update nh1
SET PropertyAddress = ISNULL(nh1.PropertyAddress, nh2.PropertyAddress)
From PortfolioProject..NashvilleHousing nh1
Join PortfolioProject..NashvilleHousing nh2
	On nh1.ParcelID = nh2.ParcelID
	AND nh1.[UniqueID ] <> nh2.[UniqueID ]
Where nh1.PropertyAddress is null

--Breaking out address into individual columns (address, city, state)

Select *
From PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--Owner Address

Select OwnerAddress
From PortfolioProject..NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From PortfolioProject..NashvilleHousing





ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


--Changing Yes to Y and No to N

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


--Remove Duplicates


WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
--Order by ParcelID
)

Select *
From RowNumCTE
where row_num >1

-- Delete unused columns

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate