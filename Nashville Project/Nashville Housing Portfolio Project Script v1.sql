Select *
From PortfolioDatabase.dbo.NashvilleHousing

------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioDatabase.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDateCoverted

------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioDatabase.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID



Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioDatabase.dbo.NashvilleHousing a
JOIN PortfolioDatabase.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioDatabase.dbo.NashvilleHousing a
JOIN PortfolioDatabase.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City, State)

Select PropertyAddress
From PortfolioDatabase.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address1
From PortfolioDatabase.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))



Select OwnerAddress
From PortfolioDatabase.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioDatabase.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' field

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From PortfolioDatabase.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' Then 'Yes'
	  When SoldAsVacant = 'N' Then 'No'
	  ELSE SoldAsVacant
	  END
From PortfolioDatabase.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	  When SoldAsVacant = 'N' Then 'No'
	  ELSE SoldAsVacant
	  END

------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate, 
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioDatabase.dbo.NashvilleHousing
--order by ParcelID
)
Select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


Select *
From PortfolioDatabase.dbo.NashvilleHousing


------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioDatabase.dbo.NashvilleHousing


ALTER TABLE PortfolioDatabase.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioDatabase.dbo.NashvilleHousing
DROP COLUMN SaleDate



